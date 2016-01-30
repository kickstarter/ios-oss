import XCTest
@testable import kickstartertv
import KsApi
import ReactiveCocoa
import Models

final class HomeViewModelTests : XCTestCase {

  func testFocusingAndSelectingPlaylists() {
    let scheduler = TestScheduler()
    withEnvironment(apiService: MockService(), debounceScheduler: scheduler) {

      let viewModel = HomeViewModel()

      let playlistsTest = TestObserver<[HomePlaylistViewModel], NoError>()
      viewModel.outputs.playlists.start(playlistsTest.observer)

      let nowPlayingTest = TestObserver<(projectName: String, videoUrl: NSURL), NoError>()
      viewModel.outputs.nowPlayingInfo.observe(nowPlayingTest.observer)

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

      viewModel.inputs.focusedPlaylist(playlist)

      XCTAssert(!nowPlayingTest.didEmitValue, "Focusing a playlist doesn't play it immediately")
      scheduler.advanceByInterval(0.5)
      XCTAssert(!nowPlayingTest.didEmitValue, "After a little bit of time the playlist should still not play")
      scheduler.advanceByInterval(0.55)
      XCTAssert(nowPlayingTest.didEmitValue, "After waiting enough time the playlist should play.")

      viewModel.inputs.clickedPlaylist(playlist)
      XCTAssert(selectProjectTest.didEmitValue, "Clicking the playlist should select a project.")
      XCTAssertEqual(nowPlayingTest.nextValues.last?.projectName, selectProjectTest.nextValues.last?.name,
        "Clicking the playlist should select the project that was currently playing.")

      viewModel.inputs.focusedPlaylist(otherPlaylist)
      XCTAssertEqual(1, nowPlayingTest.nextValues.count, "Focusing another playlist shouldn't play it " +
        "immediately")

      scheduler.advanceByInterval(0.5)
      XCTAssertEqual(1, nowPlayingTest.nextValues.count, "After a little bit of time the playlist should " +
        "still not play.")

      viewModel.inputs.clickedPlaylist(otherPlaylist)
      XCTAssertEqual(1, selectProjectTest.nextValues.count, "Clicking this playlist before it has begun " +
        "playing shoudl not select the project.")

      scheduler.advanceByInterval(0.55)
      XCTAssertEqual(2, nowPlayingTest.nextValues.count, "Waiting enough time the playlist should play.")

      viewModel.inputs.clickedPlaylist(otherPlaylist)
      XCTAssertEqual(nowPlayingTest.nextValues.last?.projectName, selectProjectTest.nextValues.last?.name,
        "Clicking on the playing playlist should select the project.")
    }
  }
}
