import XCTest
import ReactiveCocoa
import Result
@testable import ReactiveExtensions
@testable import ReactiveExtensions_TestHelpers
@testable import LiveStream

private struct TestStreamType: OTStreamType {}
private class TestErrorType: NSError, OTErrorType {}

internal final class LiveVideoViewModelTests: XCTestCase {
  private let vm: LiveVideoViewModelType = LiveVideoViewModel()

  private let addAndConfigureSubscriber = TestObserver<OTStreamType, NoError>()
  private let addAndConfigureHLSPlayerWithStreamUrl = TestObserver<String, NoError>()
  private let createAndConfigureSessionWithConfig = TestObserver<OpenTokSessionConfig, NoError>()
  private let notifyDelegateOfPlaybackStateChange = TestObserver<LiveVideoPlaybackState, NoError>()
  private let removeSubscriber = TestObserver<OTStreamType, NoError>()

  override func setUp() {
    super.setUp()
    self.vm.outputs.addAndConfigureSubscriber.observe(self.addAndConfigureSubscriber.observer)
    self.vm.outputs.createAndConfigureSessionWithConfig.observe(
      self.createAndConfigureSessionWithConfig.observer)
    self.vm.outputs.addAndConfigureHLSPlayerWithStreamUrl.observe(
      self.addAndConfigureHLSPlayerWithStreamUrl.observer)
    self.vm.outputs.notifyDelegateOfPlaybackStateChange.observe(self.notifyDelegateOfPlaybackStateChange.observer)
    self.vm.outputs.removeSubscriber.observe(self.removeSubscriber.observer)
  }

  override func tearDown() {
    super.tearDown()
  }

  func testHLSStream() {
    let streamUrl = "http://www.kickstarter.com"

    // Step 1: Configure the HLS stream url
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.configureWith(liveStreamType: .hlsStream(hlsStreamUrl: streamUrl))
    self.addAndConfigureHLSPlayerWithStreamUrl.assertValue(streamUrl)

    // Step 2: Test state changes
    self.vm.inputs.hlsPlayerStateChanged(state: .Unknown)
    self.vm.inputs.hlsPlayerStateChanged(state: .ReadyToPlay)
    self.vm.inputs.hlsPlayerStateChanged(state: .Failed)

    let errorState = LiveVideoPlaybackState.error(error: .failedToConnect)

    self.notifyDelegateOfPlaybackStateChange.assertValues([.loading, .playing, errorState])
  }

  func testOpentokSessionConfig() {
    let sessionConfig = OpenTokSessionConfig(apiKey: "123", sessionId: "123", token: "123")

    // Step 1: Configure the OpenTok session, playback state should become loading
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.configureWith(liveStreamType: .openTok(sessionConfig: sessionConfig))
    self.createAndConfigureSessionWithConfig.assertValue(sessionConfig)
    self.notifyDelegateOfPlaybackStateChange.assertValue(.loading)

    // Step 2: Connect the session, playback state should change to playing
    self.vm.inputs.sessionDidConnect()
    self.notifyDelegateOfPlaybackStateChange.assertValues([.loading, .playing])

    // Step 3: A stream is created and a subscriber view should be configured
    let testStream1 = TestStreamType()
    self.vm.inputs.sessionStreamCreated(stream: testStream1)
    XCTAssertNotNil(self.addAndConfigureSubscriber.lastValue)
    XCTAssertTrue(self.addAndConfigureSubscriber.lastValue is TestStreamType)

    // Step 4: Another stream is created and a subscriber view should be configured
    let testStream2 = TestStreamType()
    self.vm.inputs.sessionStreamCreated(stream: testStream2)
    XCTAssertNotNil(self.addAndConfigureSubscriber.lastValue)
    XCTAssertTrue(self.addAndConfigureSubscriber.lastValue is TestStreamType)
    self.addAndConfigureSubscriber.assertValueCount(2)

    // Step 5: A stream is destroyed, subscriber view should be removed
    self.vm.inputs.sessionStreamDestroyed(stream: testStream1)
    XCTAssertNotNil(self.removeSubscriber.lastValue)
    XCTAssertTrue(self.removeSubscriber.lastValue is TestStreamType)
    self.removeSubscriber.assertValueCount(1)

    // Step 6: Another stream is destroyed, subscriber view should be removed
    self.vm.inputs.sessionStreamDestroyed(stream: testStream2)
    XCTAssertNotNil(self.removeSubscriber.lastValue)
    XCTAssertTrue(self.removeSubscriber.lastValue is TestStreamType)
    self.removeSubscriber.assertValueCount(2)

    let errorState = LiveVideoPlaybackState.error(error: .sessionInterrupted)

    // Step 7: The stream encounters an error, all video views should be removed
    let testError = TestErrorType(domain: "", code: 0, userInfo: nil)
    self.vm.inputs.sessionDidFailWithError(error: testError)
    self.notifyDelegateOfPlaybackStateChange.assertValues([.loading, .playing, errorState])
  }
}
