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
  private let viewModel: CuratedProjectsViewModelType = CuratedProjectsViewModel()

  override func setUp() {
    super.setUp()
    self.viewModel.outputs.dismissViewController.observe(self.dismissViewController.observer)
    self.viewModel.outputs.loadProjects.observe(self.loadProjects.observer)
  }

  func testDismissViewController_OnButtonTap() {
    self.dismissViewController.assertDidNotEmitValue()

    self.viewModel.inputs.doneButtonTapped()

    self.dismissViewController.assertValueCount(1)
  }

  func testLoadProjects() {
    let artProjects = (1...5).map {
      .template
        |> Project.lens.id .~ $0
        |> Project.lens.category .~ Project.Category.art
    }
    let gamesProjects = (1...5).map {
      .template
        |> Project.lens.id .~ $0
        |> Project.lens.category .~ Project.Category.games
    }
    let projects = (artProjects + gamesProjects)

    let envelope = .template
      |> DiscoveryEnvelope.lens.projects .~ (artProjects + gamesProjects)

    let apiService = MockService(fetchDiscoveryResponse: envelope)
    withEnvironment(apiService: apiService) {
      self.viewModel.inputs.configure(with: [Category.art, Category.tabletopGames])

      self.viewModel.inputs.viewDidLoad()

      self.loadProjects.assertValues([projects, projects + projects])
    }
  }
}
