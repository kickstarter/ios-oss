import Prelude
import ReactiveSwift
import Result
import XCTest
@testable import KsApi
@testable import LiveStream
@testable import Library
@testable import ReactiveExtensions_TestHelpers

internal final class BackerDashboardProjectsViewModelTests: TestCase {
  private let vm: BackerDashboardProjectsViewModelType = BackerDashboardProjectsViewModel()

  private let emptyStateIsVisible = TestObserver<Bool, NoError>()
  private let emptyStateProjectsType = TestObserver<ProfileProjectsType, NoError>()
  private let isRefreshing = TestObserver<Bool, NoError>()
  private let goToProject = TestObserver<Project, NoError>()
  private let goToProjectRefTag = TestObserver<RefTag, NoError>()
  private let projects = TestObserver<[Project], NoError>()
  private let scrollToProjectRow = TestObserver<Int, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.emptyStateIsVisible.map(first).observe(self.emptyStateIsVisible.observer)
    self.vm.outputs.emptyStateIsVisible.map(second).observe(self.emptyStateProjectsType.observer)
    self.vm.outputs.isRefreshing.observe(self.isRefreshing.observer)
    self.vm.outputs.goToProject.map(first).observe(self.goToProject.observer)
    self.vm.outputs.goToProject.map(third).observe(self.goToProjectRefTag.observer)
    self.vm.outputs.projects.observe(self.projects.observer)
    self.vm.outputs.scrollToProjectRow.observe(self.scrollToProjectRow.observer)
  }

  func testProjects() {
    let projects = (1...3).map { .template |> Project.lens.id .~ $0 }
    let projectsWithNewProject = (1...4).map { .template |> Project.lens.id .~ $0 }
    let projectsWithNewestProject = (1...5).map { .template |> Project.lens.id .~ $0 }
    let env = .template |> DiscoveryEnvelope.lens.projects .~ projects
    let env2 = .template |> DiscoveryEnvelope.lens.projects .~ projectsWithNewProject
    let env3 = .template |> DiscoveryEnvelope.lens.projects .~ projectsWithNewestProject

    withEnvironment(apiService: MockService(fetchDiscoveryResponse: env), currentUser: .template) {
      self.vm.inputs.configureWith(projectsType: .backed, sort: .endingSoon)
      self.vm.inputs.viewWillAppear(false)

      self.projects.assertValueCount(0)
      self.emptyStateIsVisible.assertValueCount(0)
      self.isRefreshing.assertValues([true])
      XCTAssertEqual(["Viewed Profile Tab"], self.trackingClient.events)
      XCTAssertEqual(["backed"], self.trackingClient.properties(forKey: "type", as: String.self))

      self.scheduler.advance()

      self.projects.assertValues([projects])
      self.emptyStateIsVisible.assertValues([false])
      self.emptyStateProjectsType.assertValues([.backed])
      self.isRefreshing.assertValues([true, false])

      self.vm.inputs.viewWillAppear(false)
      self.isRefreshing.assertValues([true, false, true])

      self.scheduler.advance()

      self.projects.assertValues([projects])
      self.emptyStateIsVisible.assertValues([false])
      self.isRefreshing.assertValues([true, false, true, false])

      // Come back after backing a project.
      withEnvironment(apiService: MockService(fetchDiscoveryResponse: env2), currentUser: .template) {
        self.vm.inputs.viewWillAppear(false)

        self.isRefreshing.assertValues([true, false, true, false, true])

        self.scheduler.advance()

        self.projects.assertValues([projects, projectsWithNewProject])
        self.emptyStateIsVisible.assertValues([false, false])
        self.isRefreshing.assertValues([true, false, true, false, true, false])
      }

      // Refresh.
      withEnvironment(apiService: MockService(fetchDiscoveryResponse: env3), currentUser: .template) {
        self.vm.inputs.refresh()

        self.isRefreshing.assertValues([true, false, true, false, true, false, true])

        self.scheduler.advance()

        self.projects.assertValues([projects, projectsWithNewProject, projectsWithNewestProject])
        self.emptyStateIsVisible.assertValues([false, false, false])
        self.isRefreshing.assertValues([true, false, true, false, true, false, true, false])
      }
    }
  }

  func testNoProjects() {
    let env = .template |> DiscoveryEnvelope.lens.projects .~ []

    withEnvironment(apiService: MockService(fetchDiscoveryResponse: env), currentUser: .template) {
      self.vm.inputs.configureWith(projectsType: .saved, sort: .endingSoon)
      self.vm.inputs.viewWillAppear(false)

      self.projects.assertValueCount(0)
      self.emptyStateIsVisible.assertValueCount(0)
      self.isRefreshing.assertValues([true])
      XCTAssertEqual(["Viewed Profile Tab"], self.trackingClient.events)
      XCTAssertEqual(["saved"], self.trackingClient.properties(forKey: "type", as: String.self))

      self.scheduler.advance()

      self.projects.assertValues([[]])
      self.emptyStateIsVisible.assertValues([true], "Empty state is shown for user with no projects.")
      self.emptyStateProjectsType.assertValues([.saved])
      self.isRefreshing.assertValues([true, false])

      self.vm.inputs.viewWillAppear(true)

      self.scheduler.advance()

      self.projects.assertValues([[]], "Projects does not emit.")
      self.emptyStateIsVisible.assertValues([true], "Empty state does not emit.")
    }
  }

  func testProjectCellTapped() {
    let project = Project.template
    let projects = (1...3).map { .template |> Project.lens.id .~ $0 }
    let env = .template |> DiscoveryEnvelope.lens.projects .~ projects

    withEnvironment(apiService: MockService(fetchDiscoveryResponse: env), currentUser: .template) {
      self.vm.inputs.configureWith(projectsType: .backed, sort: .endingSoon)
      self.vm.inputs.viewWillAppear(false)

      self.scheduler.advance()

      self.vm.inputs.projectTapped(project)

      self.goToProject.assertValues([project], "Project emmitted.")
      self.goToProjectRefTag.assertValues([.profileBacked], "RefTag = profile_backed emitted.")
    }
  }

  func testScrollAndUpdateProjects_ViaProjectNavigator() {
    let playlist = (0...10).map { idx in .template |> Project.lens.id .~ (idx + 42) }
    let projectEnv = .template
      |> DiscoveryEnvelope.lens.projects .~ playlist

    let playlist2 = (0...20).map { idx in .template |> Project.lens.id .~ (idx + 72) }
    let projectEnv2 = .template
      |> DiscoveryEnvelope.lens.projects .~ playlist2

    withEnvironment(apiService: MockService(fetchDiscoveryResponse: projectEnv), currentUser: .template) {
      self.vm.inputs.configureWith(projectsType: .backed, sort: .endingSoon)
      self.vm.inputs.viewWillAppear(false)

      self.scheduler.advance()

      self.projects.assertValues([playlist], "Projects are loaded.")

      self.vm.inputs.projectTapped(playlist[4])
      self.vm.inputs.transitionedToProject(at: 5, outOf: playlist.count)

      self.scrollToProjectRow.assertValues([5])

      self.vm.inputs.transitionedToProject(at: 6, outOf: playlist.count)

      self.scrollToProjectRow.assertValues([5, 6])

      self.vm.inputs.transitionedToProject(at: 7, outOf: playlist.count)

      self.scrollToProjectRow.assertValues([5, 6, 7])

      withEnvironment(apiService: MockService(fetchDiscoveryResponse: projectEnv2)) {
        self.vm.inputs.transitionedToProject(at: 8, outOf: playlist.count)

        self.scheduler.advance()

        self.scrollToProjectRow.assertValues([5, 6, 7, 8])
        self.projects.assertValues([playlist, (playlist + playlist2)], "More projects are loaded.")

        self.vm.inputs.transitionedToProject(at: 7, outOf: playlist2.count)

        self.scrollToProjectRow.assertValues([5, 6, 7, 8, 7])
      }
    }
  }
}
