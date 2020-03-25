@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class CuratedProjectsViewModelTests: TestCase {
  private let dismissViewController = TestObserver<Void, Never>()
  private let isLoading = TestObserver<Bool, Never>()
  private let loadProjectsCount = TestObserver<Int, Never>()
  private let viewModel: CuratedProjectsViewModelType = CuratedProjectsViewModel()

  override func setUp() {
    super.setUp()
    self.viewModel.outputs.dismissViewController.observe(self.dismissViewController.observer)
    self.viewModel.outputs.isLoading.observe(self.isLoading.observer)
    self.viewModel.outputs.loadProjects.map { $0.count }.observe(self.loadProjectsCount.observer)
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

      // We configured the viewModel with 2 categories,
      // therefore, the request was made 2x, returning 10 projects
      self.loadProjectsCount.assertValue(10)
    }
  }

  func testIsLoading() {
    let category = Project.Category.art
    let projects = (1...5).map {
      .template
        |> Project.lens.id .~ $0
        |> Project.lens.category .~ category
    }
    let envelope = .template
      |> DiscoveryEnvelope.lens.projects .~ projects

    let apiService = MockService(fetchDiscoveryResponse: envelope)

    withEnvironment(apiService: apiService) {
      self.isLoading.assertDidNotEmitValue()

      self.viewModel.inputs.viewDidLoad()

      self.isLoading.assertValues([true])

      self.viewModel.inputs.configure(with: [Category.art])

      self.isLoading.assertValues([true, false])
    }
  }
}
