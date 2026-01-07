@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class CuratedProjectsViewModelTests: TestCase {
  private let dismissViewController = TestObserver<Void, Never>()
  private let goToProjectProject = TestObserver<Project, Never>()
  private let goToProjectProjects = TestObserver<[Project], Never>()
  private let goToProjectRefTag = TestObserver<RefTag, Never>()
  private let isLoading = TestObserver<Bool, Never>()
  private let loadProjectsCount = TestObserver<Int, Never>()
  private let showErrorMessage = TestObserver<String, Never>()
  private let viewModel: CuratedProjectsViewModelType = CuratedProjectsViewModel()

  override func setUp() {
    super.setUp()
    self.viewModel.outputs.dismissViewController.observe(self.dismissViewController.observer)
    self.viewModel.outputs.isLoading.observe(self.isLoading.observer)
    self.viewModel.outputs.loadProjects.map { $0.count }.observe(self.loadProjectsCount.observer)
    self.viewModel.outputs.goToProject.map(first).observe(self.goToProjectProject.observer)
    self.viewModel.outputs.goToProject.map(second).observe(self.goToProjectProjects.observer)
    self.viewModel.outputs.goToProject.map(third).observe(self.goToProjectRefTag.observer)
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

      self.scheduler.advance()

      // We configured the viewModel with 2 categories,
      // therefore, the request was made 2x, returning 10 projects
      self.loadProjectsCount.assertValue(10)
    }
  }

  func testLoadProjects_WhenCategoryListIsEmpty() {
    let envelope = .template
      |> DiscoveryEnvelope.lens.projects .~ []

    let apiService = MockService(fetchDiscoveryResponse: envelope)
    withEnvironment(apiService: apiService) {
      self.viewModel.inputs.configure(with: [])
      self.viewModel.inputs.viewDidLoad()

      self.scheduler.advance()

      self.loadProjectsCount.assertDidNotEmitValue()
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

      self.scheduler.advance()

      self.isLoading.assertValues([true, false])
    }
  }

  func testShowErrorMessage_WhenServerError() {
    let apiService = MockService(fetchDiscoveryError: .couldNotParseJSON)

    withEnvironment(apiService: apiService) {
      self.viewModel.inputs.configure(with: [Category.art, Category.tabletopGames])

      self.showErrorMessage.assertDidNotEmitValue()

      self.viewModel.inputs.viewDidLoad()

      self.scheduler.advance()

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

      self.scheduler.advance()

      self.showErrorMessage.assertValue("Something went wrong.", "Should show a generic error message")
    }
  }

  func testGoToProject() {
    let discoveryEnvelope = .template
      |> DiscoveryEnvelope.lens.projects .~ [.template]

    let apiService = MockService(fetchDiscoveryResponse: discoveryEnvelope)

    withEnvironment(apiService: apiService) {
      self.viewModel.inputs.configure(with: [.art])
      self.viewModel.inputs.viewDidLoad()

      self.scheduler.advance()

      self.goToProjectProject.assertDidNotEmitValue()
      self.goToProjectProjects.assertDidNotEmitValue()
      self.goToProjectRefTag.assertDidNotEmitValue()

      self.viewModel.inputs.projectTapped(.template)

      self.goToProjectProject.assertValues([.template])
      self.goToProjectProjects.assertValues([[.template]])
      self.goToProjectRefTag.assertValues([.onboarding])
    }
  }
}
