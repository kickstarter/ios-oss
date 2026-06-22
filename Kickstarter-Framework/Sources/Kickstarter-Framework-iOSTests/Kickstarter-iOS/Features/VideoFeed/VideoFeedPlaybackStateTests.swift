@testable import Kickstarter_Framework
@testable import LibraryTestHelpers
import XCTest

final class VideoFeedPlaybackStateTests: TestCase {
  private let state = VideoFeedPlaybackState()

  func testPause_SetsIsPlaying() {
    self.state.pause()

    XCTAssertFalse(self.state.isPlaying)

    self.state.resume()

    XCTAssertTrue(self.state.isPlaying)
  }

  func testReset_RestoresDefaultState() {
    self.state.pause()
    self.state.videoDidBecomeReady()
    self.state.videoDidFail()
    self.state.hasSaveFailed = true

    self.state.reset()

    XCTAssertTrue(self.state.isPlaying)
    XCTAssertFalse(self.state.isVideoReady)
    XCTAssertFalse(self.state.hasFailed)
    XCTAssertFalse(self.state.hasSaveFailed)
  }

  func testVideoDidBecomeReady_SetsIsVideoReadyTrue() {
    self.state.videoDidBecomeReady()

    XCTAssertTrue(self.state.isVideoReady)
  }

  func testVideoDidFail_SetsHasFailedTrue() {
    XCTAssertFalse(self.state.hasFailed)

    self.state.videoDidFail()

    XCTAssertTrue(self.state.hasFailed)
  }

  func testIsPlayButtonVisible_TrueWhenReadyAndPaused_FalseWhenPlaying() {
    self.state.videoDidBecomeReady()
    self.state.pause()

    XCTAssertTrue(self.state.isPlayButtonVisible)

    self.state.resume()

    XCTAssertFalse(self.state.isPlayButtonVisible)
  }

  func testIsPlayButtonVisible_FalseWhenNotReady() {
    self.state.pause()

    XCTAssertFalse(self.state.isPlayButtonVisible)
  }

  func testIsPlayButtonVisible_FalseWhenFailed() {
    self.state.videoDidBecomeReady()
    self.state.pause()
    self.state.videoDidFail()

    XCTAssertFalse(self.state.isPlayButtonVisible)
  }
}
