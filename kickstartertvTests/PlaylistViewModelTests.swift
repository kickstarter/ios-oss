import XCTest
@testable import kickstartertv
import ReactiveCocoa
import KsApi
import Models

internal final class PlaylistViewModelTests : XCTestCase {

  func testInitialLoad() {
    let service = MockService()
    let playlist = Playlist.Featured
    let currentProject = service.fetchProject(DiscoveryParams()).first()!.value!

    withEnvironment(apiService: service) {

      let viewModel = PlaylistViewModel(initialPlaylist: playlist, currentProject: currentProject)

      let categoryNameTest = TestObserver<String, NoError>()
      viewModel.outputs.categoryName.start(categoryNameTest.observer)

      XCTAssertEqual(categoryNameTest.lastValue, currentProject.category.name, "Should emit a category immediately.")
    }
  }
}
