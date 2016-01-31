import XCTest
@testable import kickstartertv
import KsApi
import ReactiveCocoa
import Result
import Models
import Prelude

final class HomeViewModelTests : XCTestCase {

  /**
   Tests the mechanics of focusing and clicking on playlists in order to guarantee that the currently
   playing video is properly debounced and that clicking a playlist selects the correct project.
   */
  func testFocusingAndSelectingPlaylists() {
    let scheduler = TestScheduler()
    withEnvironment(apiService: MockService(), debounceScheduler: scheduler) {

      let viewModel = HomeViewModel()

      let playlistsTest = TestObserver<[HomePlaylistViewModel], NoError>()
      viewModel.outputs.playlists.start(playlistsTest.observer)

      let nowPlayingTest = TestObserver<String?, NoError>()
      viewModel.outputs.nowPlayingProjectName.start(nowPlayingTest.observer)

      let selectProjectTest = TestObserver<Project, NoError>()
      viewModel.outputs.selectProject.observe(selectProjectTest.observer)

      XCTAssert(playlistsTest.didEmitValue, "Right off the bat we should get some playlists to display.")

      viewModel.inputs.isActive(true)

      guard let
        playlist = playlistsTest.nextValues.first?.first?.playlist,
        otherPlaylist = playlistsTest.nextValues.first?.last?.playlist
      where playlist != otherPlaylist
      else {
        XCTAssert(false, "We should have gotten at least 2 different playlists back.")
        return
      }

      print(nowPlayingTest.nextValues)
      XCTAssertTrue(nowPlayingTest.nextValues == [nil], "The now play signal should emit immediately to " +
        "indicate that nothing is currently playing.")

      viewModel.inputs.focusedPlaylist(playlist)

      XCTAssertEqual(1, nowPlayingTest.nextValues.count, "Focusing a playlist doesn't play it immediately")
      scheduler.advanceByInterval(0.5)
      XCTAssertEqual(1, nowPlayingTest.nextValues.count, "After a little bit of time the playlist should still not play")
      scheduler.advanceByInterval(1.0)
      XCTAssertEqual(2, nowPlayingTest.nextValues.count, "After waiting enough time the playlist should play.")

      let nowPlayingProjectName = nowPlayingTest.lastValue!

      viewModel.inputs.clickedPlaylist(playlist)
      XCTAssertTrue(selectProjectTest.didEmitValue, "Clicking the playlist should select a project.")
      XCTAssertEqual(nowPlayingProjectName, selectProjectTest.nextValues.last?.name,
        "Clicking the playlist should select the project that was currently playing.")

      viewModel.inputs.focusedPlaylist(otherPlaylist)
      XCTAssertEqual(2, nowPlayingTest.nextValues.count, "Focusing another playlist shouldn't play it " +
        "immediately")

      scheduler.advanceByInterval(0.5)
      XCTAssertEqual(2, nowPlayingTest.nextValues.count, "After a little bit of time the playlist should " +
        "still not play.")

      viewModel.inputs.clickedPlaylist(otherPlaylist)
      XCTAssertEqual(1, selectProjectTest.nextValues.count, "Clicking this playlist before it has begun " +
        "playing should not select the project.")

      scheduler.advanceByInterval(2.0)
      XCTAssertEqual(3, nowPlayingTest.nextValues.count, "Waiting enough time the playlist should play.")

      viewModel.inputs.clickedPlaylist(otherPlaylist)
      XCTAssertEqual(nowPlayingTest.nextValues.last!, selectProjectTest.nextValues.last?.name,
        "Clicking on the playing playlist should select the project.")
    }
  }

  func testInterfaceImportance() {
    let scheduler = TestScheduler()
    withEnvironment(apiService: MockService(), debounceScheduler: scheduler) {

      let viewModel = HomeViewModel()

      let videoIsPlayingTest = TestObserver<Bool, NoError>()
      viewModel.outputs.videoIsPlaying.observe(videoIsPlayingTest.observer)

      let interfaceImportanceTest = TestObserver<Bool, NoError>()
      viewModel.outputs.interfaceImportance.observe(interfaceImportanceTest.observer)

      viewModel.outputs.playlists.start()
      viewModel.inputs.focusedPlaylist(.Featured)

      scheduler.advanceByInterval(1.5)
      XCTAssertTrue(videoIsPlayingTest.nextValues.last!, "Video begins playing after a few moments.")
      XCTAssertTrue(interfaceImportanceTest.nextValues.last!, "Interface remains important immediately " +
        "video begins playing.")

      scheduler.advanceByInterval(6.0)
      XCTAssertFalse(interfaceImportanceTest.nextValues.last!, "After some time passes the interface " +
        "becomes less important.")

      viewModel.inputs.pauseVideoClick()
      XCTAssertTrue(interfaceImportanceTest.nextValues.last!, "Interface becomes important immediately " +
        "upon pausing the video.")

      viewModel.inputs.playVideoClick()
      XCTAssertFalse(interfaceImportanceTest.nextValues.last!, "Interface becomes not important " +
        "immediately upon playing the video.")
    }
  }
}
