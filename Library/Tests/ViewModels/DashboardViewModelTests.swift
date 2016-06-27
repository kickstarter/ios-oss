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
  internal let videoStats = TestObserver<ProjectStatsEnvelope.VideoStats, NoError>()

  internal override func setUp() {
    super.setUp()
    self.vm.outputs.goToProject.map { $0.0 }.observe(goToProject.observer)
    self.vm.outputs.project.observe(project.observer)
    self.vm.outputs.projects.observe(projects.observer)
    self.vm.outputs.videoStats.observe(videoStats.observer)
  }

  func testGoToProject() {
    let project = Project.template
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.projectContextTapped(project)
    self.goToProject.assertValues([project], "Go to project screen.")
  }

  func testProjectsEmit() {
    let mostRecentProject = .template |> Project.lens.id .~ 1738
    let memberProjects = [mostRecentProject, .template]

    withEnvironment(apiService: MockService(fetchProjectsResponse: memberProjects)) {
      self.vm.inputs.viewDidLoad()
      self.projects.assertValues([memberProjects], "Projects emitted.")
      self.project.assertValues([mostRecentProject], "Most recent project emitted.")
    }
  }

  func testProjectStatsEmit() {
    let statsEnvelope = .template
      |> ProjectStatsEnvelope.lens.videoStats .~ .template

    withEnvironment(apiService: MockService(fetchProjectStatsResponse: statsEnvelope)) {
      self.vm.inputs.viewDidLoad()
      self.videoStats.assertValueCount(1, "Video stats emitted")
    }
  }
}
