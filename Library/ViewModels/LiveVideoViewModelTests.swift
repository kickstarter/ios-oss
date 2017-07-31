import XCTest
import ReactiveSwift
import Result
@testable import ReactiveExtensions
@testable import ReactiveExtensions_TestHelpers
@testable import Library
@testable import LiveStream

private struct TestOTStream: OTStreamType {
  fileprivate let streamId: String
}
private class TestOTError: NSError, OTErrorType {}
private struct TestOTSubscriberVideoEventReason: OTSubscriberVideoEventReasonType {
  let isQualityChangedReason: Bool

  public init(_ isQualityChangedReason: Bool = true) {
    self.isQualityChangedReason = isQualityChangedReason
  }
}

internal final class LiveVideoViewModelTests: TestCase {
  private let vm: LiveVideoViewModelType = LiveVideoViewModel()

  private let addAndConfigureSubscriberStreamId = TestObserver<String, NoError>()
  private let addAndConfigureHLSPlayerWithStreamUrl = TestObserver<String, NoError>()
  private let createAndConfigureSessionWithConfig = TestObserver<OpenTokSessionConfig, NoError>()
  private let notifyDelegateOfPlaybackStateChange = TestObserver<LiveVideoPlaybackState, NoError>()
  private let removeSubscriberStreamId = TestObserver<String, NoError>()
  private let resubscribeAllSubscribersToSession = TestObserver<(), NoError>()
  private let shouldPauseHlsPlayer = TestObserver<Bool, NoError>()
  private let unsubscribeAllSubscribersFromSession = TestObserver<(), NoError>()

  override func setUp() {
    super.setUp()
    self.vm.outputs.addAndConfigureSubscriber.map { $0.streamId }
      .observe(self.addAndConfigureSubscriberStreamId.observer)
    self.vm.outputs.createAndConfigureSessionWithConfig.observe(
      self.createAndConfigureSessionWithConfig.observer)
    self.vm.outputs.addAndConfigureHLSPlayerWithStreamUrl.observe(
      self.addAndConfigureHLSPlayerWithStreamUrl.observer)
    self.vm.outputs.notifyDelegateOfPlaybackStateChange
      .observe(self.notifyDelegateOfPlaybackStateChange.observer)
    self.vm.outputs.removeSubscriber.map { $0.streamId }.observe(self.removeSubscriberStreamId.observer)
    self.vm.outputs.resubscribeAllSubscribersToSession.observe(
      self.resubscribeAllSubscribersToSession.observer)
    self.vm.outputs.shouldPauseHlsPlayer.observe(self.shouldPauseHlsPlayer.observer)
    self.vm.outputs.unsubscribeAllSubscribersFromSession.observe(
      self.unsubscribeAllSubscribersFromSession.observer)
  }

  override func tearDown() {
    super.tearDown()
  }

  func testHLSStream() {
    let streamUrl = "http://www.kickstarter.com"

    // Step 1: Configure the HLS stream url
    self.vm.inputs.configureWith(liveStreamType: .hlsStream(hlsStreamUrl: streamUrl))
    self.vm.inputs.viewDidLoad()

    self.addAndConfigureHLSPlayerWithStreamUrl.assertValues([streamUrl])

    // Step 2: Test state changes
    self.notifyDelegateOfPlaybackStateChange.assertValues([.loading])

    self.vm.inputs.hlsPlayerStateChanged(state: .readyToPlay)
    self.notifyDelegateOfPlaybackStateChange.assertValues([.loading, .playing(videoEnabled: true)])

    self.vm.inputs.hlsPlayerStateChanged(state: .failed)
    self.notifyDelegateOfPlaybackStateChange.assertValues([
      .loading, .playing(videoEnabled: true), .error(error: .failedToConnect)
    ])
  }

  func testOpenTokSessionConfig() {
    let sessionConfig = OpenTokSessionConfig(apiKey: "123", sessionId: "123", token: "123")

    // Step 1: Configure the OpenTok session, playback state should become loading
    self.vm.inputs.configureWith(liveStreamType: .openTok(sessionConfig: sessionConfig))
    self.vm.inputs.viewDidLoad()

    self.createAndConfigureSessionWithConfig.assertValue(sessionConfig)
    self.notifyDelegateOfPlaybackStateChange.assertValue(.loading)

    // Step 2: Connect the session, playback state should change to playing
    self.vm.inputs.sessionDidConnect()
    self.notifyDelegateOfPlaybackStateChange.assertValues([.loading, .playing(videoEnabled: true)])

    // Step 3: A stream is created and a subscriber view should be configured
    let testStream1 = TestOTStream(streamId: "1")
    self.vm.inputs.sessionStreamCreated(stream: testStream1)
    self.addAndConfigureSubscriberStreamId.assertValues(["1"])

    // Step 4: Another stream is created and a subscriber view should be configured
    let testStream2 = TestOTStream(streamId: "2")
    self.vm.inputs.sessionStreamCreated(stream: testStream2)
    self.addAndConfigureSubscriberStreamId.assertValues(["1", "2"])

    // Step 5: A stream is destroyed, subscriber view should be removed
    self.vm.inputs.sessionStreamDestroyed(stream: testStream1)
    self.removeSubscriberStreamId.assertValues(["1"])

    // Step 6: Another stream is destroyed, subscriber view should be removed
    self.vm.inputs.sessionStreamDestroyed(stream: testStream2)
    self.removeSubscriberStreamId.assertValues(["1", "2"])

    // Step 7: The stream encounters an error, all video views should be removed
    self.vm.inputs.sessionDidFailWithError(error: TestOTError(domain: "", code: 0, userInfo: nil))
    self.notifyDelegateOfPlaybackStateChange.assertValues(
      [.loading, .playing(videoEnabled: true), .error(error: .sessionInterrupted)]
    )

    self.addAndConfigureSubscriberStreamId.assertValues(["1", "2"])
    self.removeSubscriberStreamId.assertValues(["1", "2"])
  }

  func testOpenTok_Unsubscribe_Resubscribe() {
    let sessionConfig = OpenTokSessionConfig(apiKey: "123", sessionId: "123", token: "123")

    self.createAndConfigureSessionWithConfig.assertValueCount(0)
    self.resubscribeAllSubscribersToSession.assertValueCount(0)
    self.shouldPauseHlsPlayer.assertValueCount(0)
    self.unsubscribeAllSubscribersFromSession.assertValueCount(0)

    self.vm.inputs.configureWith(liveStreamType: .openTok(sessionConfig: sessionConfig))
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear()

    self.createAndConfigureSessionWithConfig.assertValue(sessionConfig)
    self.resubscribeAllSubscribersToSession.assertValueCount(0)
    self.shouldPauseHlsPlayer.assertValueCount(0)
    self.unsubscribeAllSubscribersFromSession.assertValueCount(0)

    self.vm.inputs.viewDidDisappear()

    self.resubscribeAllSubscribersToSession.assertValueCount(0)
    self.shouldPauseHlsPlayer.assertValueCount(0)
    self.unsubscribeAllSubscribersFromSession.assertValueCount(1)

    self.vm.inputs.viewWillAppear()

    self.resubscribeAllSubscribersToSession.assertValueCount(1)
    self.shouldPauseHlsPlayer.assertValueCount(0)
    self.unsubscribeAllSubscribersFromSession.assertValueCount(1)

    self.vm.inputs.didEnterBackground()

    self.resubscribeAllSubscribersToSession.assertValueCount(1)
    self.shouldPauseHlsPlayer.assertValueCount(0)
    self.unsubscribeAllSubscribersFromSession.assertValueCount(2)

    self.vm.inputs.willEnterForeground()

    self.resubscribeAllSubscribersToSession.assertValueCount(2)
    self.shouldPauseHlsPlayer.assertValueCount(0)
    self.unsubscribeAllSubscribersFromSession.assertValueCount(2)
  }

  func testHls_TogglePause() {
    let streamUrl = "http://www.kickstarter.com"

    self.addAndConfigureHLSPlayerWithStreamUrl.assertValueCount(0)
    self.resubscribeAllSubscribersToSession.assertValueCount(0)
    self.shouldPauseHlsPlayer.assertValueCount(0)
    self.unsubscribeAllSubscribersFromSession.assertValueCount(0)

    self.vm.inputs.configureWith(liveStreamType: .hlsStream(hlsStreamUrl: streamUrl))
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear()

    self.addAndConfigureHLSPlayerWithStreamUrl.assertValues([streamUrl])
    self.resubscribeAllSubscribersToSession.assertValueCount(0)
    self.shouldPauseHlsPlayer.assertValueCount(0)
    self.unsubscribeAllSubscribersFromSession.assertValueCount(0)

    self.vm.inputs.viewDidDisappear()

    self.resubscribeAllSubscribersToSession.assertValueCount(0)
    self.shouldPauseHlsPlayer.assertValues([true])
    self.unsubscribeAllSubscribersFromSession.assertValueCount(0)

    self.vm.inputs.viewWillAppear()

    self.resubscribeAllSubscribersToSession.assertValueCount(0)
    self.shouldPauseHlsPlayer.assertValues([true, false])
    self.unsubscribeAllSubscribersFromSession.assertValueCount(0)

    self.vm.inputs.didEnterBackground()

    self.resubscribeAllSubscribersToSession.assertValueCount(0)
    self.shouldPauseHlsPlayer.assertValues([true, false, true])
    self.unsubscribeAllSubscribersFromSession.assertValueCount(0)

    self.vm.inputs.willEnterForeground()

    self.resubscribeAllSubscribersToSession.assertValueCount(0)
    self.shouldPauseHlsPlayer.assertValues([true, false, true, false])
    self.unsubscribeAllSubscribersFromSession.assertValueCount(0)
  }

  func testPlaybackStateChange_VideoEnabledDisabled() {
    let sessionConfig = OpenTokSessionConfig(apiKey: "123", sessionId: "123", token: "123")

    self.notifyDelegateOfPlaybackStateChange.assertValueCount(0)

    self.vm.inputs.configureWith(liveStreamType: .openTok(sessionConfig: sessionConfig))
    self.vm.inputs.viewDidLoad()

    self.notifyDelegateOfPlaybackStateChange.assertValues([.loading])

    let testReason = TestOTSubscriberVideoEventReason()
    let ignoredReason = TestOTSubscriberVideoEventReason(false)

    let playingVideoEnabled = LiveVideoPlaybackState.playing(videoEnabled: true)
    let playingVideoDisabled = LiveVideoPlaybackState.playing(videoEnabled: false)

    self.vm.inputs.subscriberVideoDisabled(reason: testReason)

    self.notifyDelegateOfPlaybackStateChange.assertValues([.loading, playingVideoDisabled])

    self.vm.inputs.subscriberVideoEnabled(reason: testReason)

    self.notifyDelegateOfPlaybackStateChange.assertValues([.loading, playingVideoDisabled,
                                                           playingVideoEnabled])

    self.vm.inputs.subscriberVideoDisabled(reason: ignoredReason)

    self.notifyDelegateOfPlaybackStateChange.assertValues([.loading, playingVideoDisabled,
                                                           playingVideoEnabled])
  }
}
