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

    func testDismissViewController_OnBUttonTap() {
      self.dismissViewController.assertDidNotEmitValue()

      self.viewModel.inputs.doneButtonTapped()

      self.dismissViewController.assertValueCount(1)
    }

    func testLoadProjects() {
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

        let scheduler = QueueScheduler(qos: .userInteractive, name: "com.kickstarter.ksapi", targeting: nil)


        _ = self.viewModel.outputs.loadProjects
          .observe(on: scheduler)


        self.viewModel.inputs.configure(with: [Category.art])

        self.viewModel.inputs.viewDidLoad()

        self.loadProjects.assertDidEmitValue()
      }
    }
}
