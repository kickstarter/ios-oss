@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class CuratedProjectsViewModelTests: TestCase {
  private let dismissViewController = TestObserver<Void, Never>()
  private let loadProjects = TestObserver<[Project], Never>()
  private let showErrorMessage = TestObserver<String, Never>()
  private let viewModel: CuratedProjectsViewModelType = CuratedProjectsViewModel()

  override func setUp() {
    super.setUp()
    self.viewModel.outputs.dismissViewController.observe(self.dismissViewController.observer)
    self.viewModel.outputs.loadProjects.observe(self.loadProjects.observer)
    self.viewModel.outputs.showErrorMessage.observe(self.showErrorMessage.observer)
  }

  func testDismissViewController_OnButtonTap() {
    self.dismissViewController.assertDidNotEmitValue()

    self.viewModel.inputs.doneButtonTapped()

    self.dismissViewController.assertValueCount(1)
  }

  func testLoadProjects() {
    let projects = (1...5).map {
      .template
        |> Project.lens.id .~ $0
        |> Project.lens.category .~ Project.Category.art
    }

    let envelope = .template
      |> DiscoveryEnvelope.lens.projects .~ projects

    let apiService = MockService(fetchDiscoveryResponse: envelope)
    withEnvironment(apiService: apiService) {
      self.viewModel.inputs.configure(with: [Category.art, Category.tabletopGames])

      self.viewModel.inputs.viewDidLoad()

      // We configured the viewModel with 2 categories, therefore the request was made 2x.
      self.loadProjects.assertValue(projects + projects)
    }
  }

  func testShowErrorMessage_WhenServerError() {
    let apiService = MockService(fetchDiscoveryError: .couldNotParseJSON)

    withEnvironment(apiService: apiService) {
      self.viewModel.inputs.configure(with: [Category.art, Category.tabletopGames])

      self.showErrorMessage.assertDidNotEmitValue()

      self.viewModel.inputs.viewDidLoad()

      self.showErrorMessage.assertValue("Something went wrong.", "Should show a generic error message")
    }
  }

  func testShowErrorMessage_WhenNoProjectsReturned() {
    let emptyEnvelope = .template
      |> DiscoveryEnvelope.lens.projects .~ []

    let apiService = MockService(fetchDiscoveryResponse: emptyEnvelope)

    withEnvironment(apiService: apiService) {
      self.viewModel.inputs.configure(with: [Category.art, Category.tabletopGames])

      self.showErrorMessage.assertDidNotEmitValue()

      self.viewModel.inputs.viewDidLoad()

      self.showErrorMessage.assertValue("Something went wrong.", "Should show a generic error message")
    }
  }
}
