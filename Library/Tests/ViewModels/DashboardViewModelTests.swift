import Prelude
import ReactiveCocoa
import Result
import XCTest
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions
@testable import ReactiveExtensions_TestHelpers

internal final class DashboardViewModelTests: TestCase {
  internal let vm: DashboardViewModelType = DashboardViewModel()
  internal let goToProject = TestObserver<Project, NoError>()
  internal let project = TestObserver<Project, NoError>()
  internal let projects = TestObserver<[Project], NoError>()
  internal let referrerCumulativeStats = TestObserver<ProjectStatsEnvelope.Cumulative, NoError>()
  internal let referrerStats = TestObserver<[ProjectStatsEnvelope.ReferrerStats], NoError>()
  internal let rewardStats = TestObserver<[ProjectStatsEnvelope.RewardStats], NoError>()
  internal let videoStats = TestObserver<ProjectStatsEnvelope.VideoStats, NoError>()

  internal override func setUp() {
    super.setUp()
    self.vm.outputs.goToProject.map { $0.0 }.observe(self.goToProject.observer)
    self.vm.outputs.project.observe(self.project.observer)
    self.vm.outputs.projects.observe(self.projects.observer)
    self.vm.outputs.referrerData
      .map { cumulative, _, _ in cumulative }
      .observe(self.referrerCumulativeStats.observer)
    self.vm.outputs.referrerData.map { _, _, stats in stats }.observe(self.referrerStats.observer)
    self.vm.outputs.rewardStats.map { stats, _ in stats }.observe(self.rewardStats.observer)
    self.vm.outputs.videoStats.observe(self.videoStats.observer)
  }

  func testTracking() {
    let projects = [Project.template]

    withEnvironment(apiService: MockService(fetchProjectsResponse: projects)) {
      XCTAssertEqual([], self.trackingClient.events)

      self.vm.inputs.viewDidLoad()

      XCTAssertEqual(["Dashboard View"], self.trackingClient.events)
      XCTAssertEqual([1], self.trackingClient.properties.map { $0["project_pid"] as! Int? })
    }
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
    let projects = [Project.template]

    let statsEnvelope = .template
      |> ProjectStatsEnvelope.lens.cumulative .~ .template
      |> ProjectStatsEnvelope.lens.referrerStats .~ [.template]
      |> ProjectStatsEnvelope.lens.rewardStats .~ [.template]
      |> ProjectStatsEnvelope.lens.videoStats .~ .template

    withEnvironment(apiService: MockService(fetchProjectsResponse: projects,
      fetchProjectStatsResponse: statsEnvelope)) {
        self.vm.inputs.viewDidLoad()
        self.scheduler.advance()

        self.videoStats.assertValues([.template], "Video stats emitted.")
        self.referrerCumulativeStats.assertValues([.template], "Cumulative stats emitted.")
        self.referrerStats.assertValues([[.template]], "Referrer stats emitted.")
        self.rewardStats.assertValues([[.template]], "Reward stats emitted.")
    }
  }
}
