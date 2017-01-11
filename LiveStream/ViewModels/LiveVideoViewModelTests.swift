import XCTest
import ReactiveSwift
import Result
@testable import ReactiveExtensions
@testable import ReactiveExtensions_TestHelpers
@testable import LiveStream

private struct TestOTStreamType: OTStreamType {
  fileprivate let streamId: String!
}
private class TestOTErrorType: NSError, OTErrorType {}

internal final class LiveVideoViewModelTests: XCTestCase {
  private let vm: LiveVideoViewModelType = LiveVideoViewModel()

  private let addAndConfigureSubscriberStreamId = TestObserver<String, NoError>()
  private let addAndConfigureHLSPlayerWithStreamUrl = TestObserver<String, NoError>()
  private let createAndConfigureSessionWithConfig = TestObserver<OpenTokSessionConfig, NoError>()
  private let notifyDelegateOfPlaybackStateChange = TestObserver<LiveVideoPlaybackState, NoError>()
  private let removeSubscriberStreamId = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()
    self.vm.outputs.addAndConfigureSubscriber.map { $0.streamId }.observe(self.addAndConfigureSubscriberStreamId.observer)
    self.vm.outputs.createAndConfigureSessionWithConfig.observe(
      self.createAndConfigureSessionWithConfig.observer)
    self.vm.outputs.addAndConfigureHLSPlayerWithStreamUrl.observe(
      self.addAndConfigureHLSPlayerWithStreamUrl.observer)
    self.vm.outputs.notifyDelegateOfPlaybackStateChange.observe(self.notifyDelegateOfPlaybackStateChange.observer)
    self.vm.outputs.removeSubscriber.map { $0.streamId }.observe(self.removeSubscriberStreamId.observer)
  }

  override func tearDown() {
    super.tearDown()
  }

  func testHLSStream() {
    let streamUrl = "http://www.kickstarter.com"

    // Step 1: Configure the HLS stream url
    self.vm.inputs.configureWith(liveStreamType: .hlsStream(hlsStreamUrl: streamUrl))
    self.vm.inputs.viewDidLoad()

    self.addAndConfigureHLSPlayerWithStreamUrl.assertValue(streamUrl)

    // Step 2: Test state changes
    self.vm.inputs.hlsPlayerStateChanged(state: .unknown)
    self.notifyDelegateOfPlaybackStateChange.assertValues([.loading])

    self.vm.inputs.hlsPlayerStateChanged(state: .readyToPlay)
    self.notifyDelegateOfPlaybackStateChange.assertValues([.loading, .playing])

    self.vm.inputs.hlsPlayerStateChanged(state: .failed)
    self.notifyDelegateOfPlaybackStateChange.assertValues([
      .loading, .playing, .error(error: .failedToConnect)
    ])
  }

  func testOpentokSessionConfig() {
    let sessionConfig = OpenTokSessionConfig(apiKey: "123", sessionId: "123", token: "123")

    // Step 1: Configure the OpenTok session, playback state should become loading
    self.vm.inputs.configureWith(liveStreamType: .openTok(sessionConfig: sessionConfig))
    self.vm.inputs.viewDidLoad()

    self.createAndConfigureSessionWithConfig.assertValue(sessionConfig)
    self.notifyDelegateOfPlaybackStateChange.assertValue(.loading)

    // Step 2: Connect the session, playback state should change to playing
    self.vm.inputs.sessionDidConnect()
    self.notifyDelegateOfPlaybackStateChange.assertValues([.loading, .playing])

    // Step 3: A stream is created and a subscriber view should be configured
    let testStream1 = TestOTStreamType(streamId: "1")
    self.vm.inputs.sessionStreamCreated(stream: testStream1)
    self.addAndConfigureSubscriberStreamId.assertValues(["1"])

    // Step 4: Another stream is created and a subscriber view should be configured
    let testStream2 = TestOTStreamType(streamId: "2")
    self.vm.inputs.sessionStreamCreated(stream: testStream2)
    self.addAndConfigureSubscriberStreamId.assertValues(["1", "2"])

    // Step 5: A stream is destroyed, subscriber view should be removed
    self.vm.inputs.sessionStreamDestroyed(stream: testStream1)
    self.removeSubscriberStreamId.assertValues(["1"])

    // Step 6: Another stream is destroyed, subscriber view should be removed
    self.vm.inputs.sessionStreamDestroyed(stream: testStream2)
    self.removeSubscriberStreamId.assertValues(["1", "2"])

    // Step 7: The stream encounters an error, all video views should be removed
    self.vm.inputs.sessionDidFailWithError(error: TestOTErrorType(domain: "", code: 0, userInfo: nil))
    self.notifyDelegateOfPlaybackStateChange.assertValues(
      [.loading, .playing, .error(error: .sessionInterrupted)]
    )

    self.addAndConfigureSubscriberStreamId.assertValues(["1", "2"])
    self.removeSubscriberStreamId.assertValues(["1", "2"])
  }
}
