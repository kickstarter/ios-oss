import Foundation
import XCTest
import ReactiveSwift
import Result
import KsApi
import Prelude
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions_TestHelpers

internal final class ProfileViewModelTests: TestCase {
  private let vm = ProfileViewModel()
  private let user = TestObserver<User, NoError>()
  private let hasAddedProjects = TestObserver<Bool, NoError>()
  private let hasBackedProjects = TestObserver<Bool, NoError>()
  private let goToProject = TestObserver<Project, NoError>()
  private let goToProjects = TestObserver<[Project], NoError>()
  private let goToRefTag = TestObserver<RefTag, NoError>()
  private let goToSettings = TestObserver<Void, NoError>()
  private let scrollToProjectItem = TestObserver<Int, NoError>()
  private let showEmptyState = TestObserver<Bool, NoError>()

  internal override func setUp() {
    super.setUp()
    self.vm.outputs.user.observe(user.observer)
    self.vm.outputs.backedProjects.map { !$0.isEmpty }.observe(hasBackedProjects.observer)
    self.vm.outputs.goToProject.map { $0.0 }.observe(goToProject.observer)
    self.vm.outputs.goToProject.map { $0.1 }.observe(goToProjects.observer)
    self.vm.outputs.goToProject.map { $0.2 }.observe(goToRefTag.observer)
    self.vm.outputs.goToSettings.observe(goToSettings.observer)
    self.vm.outputs.scrollToProjectItem.observe(self.scrollToProjectItem.observer)
    self.vm.outputs.showEmptyState.observe(showEmptyState.observer)

    self.vm.outputs.backedProjects
      .map { $0.count }
      .combinePrevious(0)
      .map { prev, next in next > prev }
      .observe(self.hasAddedProjects.observer)
  }

  func testGoToSettings() {
    self.vm.inputs.settingsButtonTapped()
    self.goToSettings.assertValueCount(1, "Go to settings screen.")
  }

  func testProjectCellTapped() {
    let project = Project.template
    let projects = (1...3).map { .template |> Project.lens.id .~ $0 }
    let env = .template |> DiscoveryEnvelope.lens.projects .~ projects

    withEnvironment(apiService: MockService(fetchDiscoveryResponse: env)) {
      self.vm.inputs.viewWillAppear(false)
      self.scheduler.advance()
      self.vm.inputs.projectTapped(project)

      self.goToProject.assertValues([project], "Project emmitted.")
      self.goToProjects.assertValues([projects])
      self.goToRefTag.assertValues([.profileBacked], "RefTag =profile_backed emitted.")
    }
  }

  func testUser_WithBackedProjects() {
    let user = User.template
    let projects = (1...3).map { .template |> Project.lens.id .~ $0 }
    let projectsWithNewProject = (1...4).map { .template |> Project.lens.id .~ $0 }
    let env = .template |> DiscoveryEnvelope.lens.projects .~ projects
    let env2 = .template |> DiscoveryEnvelope.lens.projects .~ projectsWithNewProject

    withEnvironment(apiService: MockService(fetchDiscoveryResponse: env),
                    currentUser: user) {

      self.vm.inputs.viewWillAppear(false)
      self.scheduler.advance()

      self.user.assertValues([user, user], "Current user emmitted.")
      self.hasBackedProjects.assertValues([true])
      self.showEmptyState.assertValues([false])

      XCTAssertEqual(["Profile View My", "Viewed Profile"], trackingClient.events)

      self.vm.inputs.viewWillAppear(false)
      self.scheduler.advance()

      self.user.assertValues([user, user, user, user], "Current user emmitted.")
      self.hasBackedProjects.assertValues([true])
      self.showEmptyState.assertValues([false])

      XCTAssertEqual(["Profile View My", "Viewed Profile", "Profile View My", "Viewed Profile"],
                     trackingClient.events)

      self.vm.inputs.viewWillAppear(true)
      self.scheduler.advance()

      self.user.assertValues([user, user, user, user, user, user], "Current user emmitted.")
      self.hasBackedProjects.assertValues([true])
      self.showEmptyState.assertValues([false])

      XCTAssertEqual(["Profile View My", "Viewed Profile", "Profile View My", "Viewed Profile"],
                     trackingClient.events, "Viewed Profile tracking does not emit.")

      // Come back after backing a project.
      withEnvironment(apiService: MockService(fetchDiscoveryResponse: env2),
                      currentUser: user) {

        self.vm.inputs.viewWillAppear(false)
        self.scheduler.advance()

        self.user.assertValues([user, user, user, user, user, user, user, user], "Current user emmitted.")
        self.hasBackedProjects.assertValues([true, true])
        self.showEmptyState.assertValues([false, false])

        XCTAssertEqual(["Profile View My", "Viewed Profile", "Profile View My", "Viewed Profile",
          "Profile View My", "Viewed Profile"], trackingClient.events)

      }
    }
  }

  func testUser_WithNoProjects() {
    let env = .template |> DiscoveryEnvelope.lens.projects .~ []

    withEnvironment(apiService: MockService(fetchDiscoveryResponse: env), currentUser: .template) {
      self.vm.inputs.viewWillAppear(false)

      self.hasBackedProjects.assertValueCount(0)
      self.showEmptyState.assertValueCount(0)
      XCTAssertEqual(["Profile View My", "Viewed Profile"], trackingClient.events)

      self.scheduler.advance()

      self.hasBackedProjects.assertValues([false])
      self.showEmptyState.assertValues([true], "Empty state is shown for user with 0 backed projects.")

      self.vm.inputs.viewWillAppear(true)

      self.scheduler.advance()

      self.hasBackedProjects.assertValues([false], "Backed projects does not emit.")
      self.showEmptyState.assertValues([true], "Empty state does not emit.")
      XCTAssertEqual(["Profile View My", "Viewed Profile"], trackingClient.events)
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
      self.vm.inputs.viewWillAppear(false)

      self.scheduler.advance()

      self.hasAddedProjects.assertValues([true], "Projects are loaded.")

      self.vm.inputs.projectTapped(playlist[4])
      self.vm.inputs.transitionedToProject(at: 5, outOf: playlist.count)

      self.scrollToProjectItem.assertValues([5])

      self.vm.inputs.transitionedToProject(at: 6, outOf: playlist.count)

      self.scrollToProjectItem.assertValues([5, 6])

      self.vm.inputs.transitionedToProject(at: 7, outOf: playlist.count)

      self.scrollToProjectItem.assertValues([5, 6, 7])

      withEnvironment(apiService: MockService(fetchDiscoveryResponse: projectEnv2)) {
        self.vm.inputs.transitionedToProject(at: 8, outOf: playlist.count)

        self.scheduler.advance()

        self.scrollToProjectItem.assertValues([5, 6, 7, 8])
        self.hasAddedProjects.assertValues([true, true], "More projects are loaded.")

        self.vm.inputs.transitionedToProject(at: 7, outOf: playlist2.count)

        self.scrollToProjectItem.assertValues([5, 6, 7, 8, 7])
      }
    }
  }
}
