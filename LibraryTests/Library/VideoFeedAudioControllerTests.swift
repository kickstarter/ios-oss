import AVFoundation
@testable import Library
@testable import LibraryTestHelpers
import XCTest

final class MockAudioSession: AudioSessionManaging {
  private(set) var categories: [AVAudioSession.Category] = []
  private(set) var activeStates: [Bool] = []

  var lastCategory: AVAudioSession.Category? { self.categories.last }

  func setCategory(_ category: AVAudioSession.Category, mode _: AVAudioSession.Mode) throws {
    self.categories.append(category)
  }

  func setActive(_ active: Bool) throws {
    self.activeStates.append(active)
  }

  func setActive(_ active: Bool, options _: AVAudioSession.SetActiveOptions) throws {
    self.activeStates.append(active)
  }
}

final class VideoFeedAudioControllerTests: TestCase {
  func testConfigure() {
    let mock = MockAudioSession()
    let controller = VideoFeedAudioController(session: mock)

    controller.configure()

    if #available(iOS 26, *) {
      XCTAssertEqual(mock.lastCategory, .soloAmbient)
    } else {
      XCTAssertEqual(mock.lastCategory, .playback)
    }

    XCTAssertEqual(mock.activeStates.last, true)
  }

  func testVolumeUp_SwitchesToPlaybackAndSetsFlag() {
    let mock = MockAudioSession()
    let controller = VideoFeedAudioController(session: mock)

    controller.handleVolumeUp()

    XCTAssertEqual(mock.lastCategory, .playback)
    XCTAssertTrue(controller.isPlaybackSessionActive)
  }

  func testVolumeUp_IsBlockedDuringSessionReset() {
    let mock = MockAudioSession()
    let controller = VideoFeedAudioController(session: mock)

    controller.handleSilentSwitchChange()

    let categoryAfterReset = mock.lastCategory

    controller.handleVolumeUp()

    XCTAssertEqual(mock.lastCategory, categoryAfterReset)
    XCTAssertFalse(controller.isPlaybackSessionActive)
  }

  func testSilentSwitch_ResetsTSoloAmbient() {
    let mock = MockAudioSession()
    let controller = VideoFeedAudioController(session: mock)

    controller.handleVolumeUp() /// puts us in .playback
    controller.handleSilentSwitchChange()

    XCTAssertEqual(mock.lastCategory, .soloAmbient)
  }

  func testSilentSwitch_ClearsPlaybackFlag() {
    let mock = MockAudioSession()
    let controller = VideoFeedAudioController(session: mock)

    controller.handleVolumeUp()
    XCTAssertTrue(controller.isPlaybackSessionActive)

    controller.handleSilentSwitchChange()

    XCTAssertFalse(controller.isPlaybackSessionActive)
  }

  func testOverlayUnmute_SwitchesToPlayback() {
    let mock = MockAudioSession()
    let controller = VideoFeedAudioController(session: mock)

    controller.handleOverlayUnmute()

    XCTAssertEqual(mock.lastCategory, .playback)
    XCTAssertTrue(controller.isPlaybackSessionActive)
  }

  func testDismiss_ResetsTSoloAmbient() {
    let mock = MockAudioSession()
    let controller = VideoFeedAudioController(session: mock)

    controller.handleVolumeUp()
    controller.handleDismiss()

    XCTAssertEqual(mock.lastCategory, .soloAmbient)
  }
}
