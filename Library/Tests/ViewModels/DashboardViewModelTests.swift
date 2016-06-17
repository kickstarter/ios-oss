import Prelude
import ReactiveCocoa
import Result
import XCTest
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions
@testable import ReactiveExtensions_TestHelpers

internal final class DashboardViewModelTests: TestCase {
  internal let vm = DashboardViewModel()
  internal let goToProject = TestObserver<Project, NoError>()
  internal let project = TestObserver<Project, NoError>()
  internal let projects = TestObserver<[Project], NoError>()

  internal override func setUp() {
    super.setUp()
    self.vm.outputs.goToProject.map { $0.0 }.observe(goToProject.observer)
    self.vm.outputs.project.observe(project.observer)
    self.vm.outputs.projects.observe(projects.observer)
  }

  func testProjectsEmit() {
    self.vm.inputs.viewDidLoad()
    self.projects.assertValueCount(1, "Projects emitted.")
    self.project.assertValueCount(1)
  }

  func testGoToProject() {
    let project = Project.template
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.projectContextTapped(project)
    self.goToProject.assertValues([project], "Go to project screen.")
  }
}
