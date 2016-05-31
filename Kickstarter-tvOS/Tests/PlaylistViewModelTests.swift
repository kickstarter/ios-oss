import XCTest
@testable import Kickstarter_tvOS
import ReactiveCocoa
import Result
@testable import KsApi
@testable import Models
@testable import Models_TestHelpers
import Prelude
import Library
@testable import KsApi_TestHelpers
@testable import ReactiveExtensions_TestHelpers

internal final class PlaylistViewModelTests: XCTestCase {
  let playlist = Playlist.Featured
  var project = Project.template

  override func setUp() {
    AppEnvironment.pushEnvironment(
      apiService: MockService(),
      assetImageGeneratorType: MockSuccessAssetImageGenerator.self
    )
  }

  override func tearDown() {
    AppEnvironment.popEnvironment()
  }

  func testInitialLoad() {
    withEnvironment(assetImageGeneratorType: MockSuccessAssetImageGenerator.self) {

      let viewModel = PlaylistViewModel(initialPlaylist: playlist, currentProject: project)

      let projectNameTest = TestObserver<String, NoError>()
      viewModel.outputs.projectName.start(projectNameTest.observer)

      let categoryNameTest = TestObserver<String, NoError>()
      viewModel.outputs.categoryName.start(categoryNameTest.observer)

      let backgroundImageTest = TestObserver<UIImage?, NoError>()
      viewModel.outputs.backgroundImage.start(backgroundImageTest.observer)

      XCTAssertEqual(projectNameTest.lastValue, project.name, "Should emit a project immediately.")
      XCTAssertEqual(categoryNameTest.lastValue, project.category.name, "Should emit a category immediately.")
      XCTAssertNotNil(flattenOptional(backgroundImageTest.lastValue), "Should emit a background image")
    }
  }

  func testBackgroundImageFailure() {
    withEnvironment(assetImageGeneratorType: MockFailureAssetImageGenerator.self) {

      let viewModel = PlaylistViewModel(initialPlaylist: playlist, currentProject: project)

      let backgroundImageTest = TestObserver<UIImage?, NoError>()
      viewModel.outputs.backgroundImage.start(backgroundImageTest.observer)

      XCTAssertEqual(1, backgroundImageTest.values.count, "Should emit a nil background image")
      XCTAssertNil(flattenOptional(backgroundImageTest.lastValue), "Should emit a nil background image")
      XCTAssertFalse(backgroundImageTest.didComplete)
    }
  }

  func testBackgroundImageNeverCompleting() {
    let scheduler = TestScheduler()

    withEnvironment(scheduler: scheduler,
                    assetImageGeneratorType: MockNeverFinishingAssetImageGenerator.self) {

      let viewModel = PlaylistViewModel(initialPlaylist: playlist, currentProject: project)

      let backgroundImageTest = TestObserver<UIImage?, NoError>()
      viewModel.outputs.backgroundImage.start(backgroundImageTest.observer)

      XCTAssertFalse(backgroundImageTest.didEmitValue, "Should not have emitted a background image yet.")

      scheduler.advanceByInterval(6.0)

      XCTAssertEqual(1, backgroundImageTest.values.count, "Should emit a nil background image")
      XCTAssertNil(flattenOptional(backgroundImageTest.lastValue), "Should emit a nil background image")
      XCTAssertFalse(backgroundImageTest.didComplete)
    }
  }

  func testLongRunningBackgroundImage() {
    let scheduler = TestScheduler()

    withEnvironment(scheduler: scheduler, assetImageGeneratorType: MockLongRunningAssetImageGenerator.self) {

      let viewModel = PlaylistViewModel(initialPlaylist: playlist, currentProject: project)

      let backgroundImageTest = TestObserver<UIImage?, NoError>()
      viewModel.outputs.backgroundImage.start(backgroundImageTest.observer)

      XCTAssertFalse(backgroundImageTest.didEmitValue, "Should not have emitted a background image yet.")

      scheduler.advanceByInterval(8.0)

      XCTAssertEqual(1, backgroundImageTest.values.count, "Should have emitted a background image.")
      XCTAssertNil(flattenOptional(backgroundImageTest.lastValue), "Should emit a nil background image")
      XCTAssertFalse(backgroundImageTest.didComplete)

      scheduler.run()

      XCTAssertEqual(1, backgroundImageTest.values.count, "Should not have emitted any more values.")
      XCTAssertFalse(backgroundImageTest.didComplete)
    }
  }

  func testSwiping() {
    let viewModel = PlaylistViewModel(initialPlaylist: playlist, currentProject: project)

    let projectNameTest = TestObserver<String, NoError>()
    viewModel.outputs.projectName.start(projectNameTest.observer)

    XCTAssertEqual(1, projectNameTest.values.count, "A project is emitted immediately.")

    viewModel.inputs.swipeEnded(translation: CGPoint(x: 100.0, y: 0.0))
    XCTAssertEqual(1, projectNameTest.values.count, "A new project should not be emitted.")

    viewModel.inputs.swipeEnded(translation: CGPoint(x: 2_000.0, y: 0.0))
    XCTAssertEqual(2, projectNameTest.values.count, "A new project should be emitted.")

    viewModel.inputs.swipeEnded(translation: CGPoint(x: -2_000.0, y: 0.0))
    XCTAssertEqual(3, projectNameTest.values.count, "A new project should be emitted.")
  }
}
