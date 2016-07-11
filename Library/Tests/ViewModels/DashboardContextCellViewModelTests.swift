import Prelude
import ReactiveCocoa
import Result
import XCTest
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions
@testable import ReactiveExtensions_TestHelpers

internal final class DashboardContextCellViewModelTests: TestCase {
  internal let vm = DashboardContextCellViewModel()
  internal let goToProject = TestObserver<Project, NoError>()
  internal let projectName = TestObserver<String, NoError>()

  internal override func setUp() {
    super.setUp()
    self.vm.outputs.goToProject.map { $0.0 }.observe(self.goToProject.observer)
    self.vm.outputs.projectName.observe(projectName.observer)
  }

  func testGoToProject() {
    let project = Project.template
    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewProjectTapped()
    self.goToProject.assertValues([project], "Go to project screen.")
  }

  func testProjectDataEmits() {
    let project = .template |> Project.lens.name .~ "Super Sick Project"

    self.vm.inputs.configureWith(project: project)
    self.projectName.assertValues(["Super Sick Project"])
  }
}
