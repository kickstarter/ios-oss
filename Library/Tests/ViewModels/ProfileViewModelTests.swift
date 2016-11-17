import Foundation
import XCTest
import ReactiveCocoa
import Result
import KsApi
import Prelude
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions_TestHelpers

internal final class ProfileViewModelTests: TestCase {
  let vm = ProfileViewModel()
  let user = TestObserver<User, NoError>()
  let hasBackedProjects = TestObserver<Bool, NoError>()
  let goToProject = TestObserver<Project, NoError>()
  let goToProjects = TestObserver<[Project], NoError>()
  let goToRefTag = TestObserver<RefTag, NoError>()
  let goToSettings = TestObserver<Void, NoError>()
  let showEmptyState = TestObserver<Bool, NoError>()

  internal override func setUp() {
    super.setUp()
    self.vm.outputs.user.observe(user.observer)
    self.vm.outputs.backedProjects.map { !$0.isEmpty }.observe(hasBackedProjects.observer)
    self.vm.outputs.goToProject.map { $0.0 }.observe(goToProject.observer)
    self.vm.outputs.goToProject.map { $0.1 }.observe(goToProjects.observer)
    self.vm.outputs.goToProject.map { $0.2 }.observe(goToRefTag.observer)
    self.vm.outputs.goToSettings.observe(goToSettings.observer)
    self.vm.outputs.showEmptyState.observe(showEmptyState.observer)
  }

  func testGoToSettings() {
    self.vm.inputs.settingsButtonTapped()
    self.goToSettings.assertValueCount(1, "Go to settings screen.")
  }

  func testProjectCellTapped() {
    let project = Project.template
    let projects = (1...3).map { .template |> Project.lens.id .~ $0 }

    withEnvironment(apiService: MockService(fetchUserProjectsBackedResponse: projects)) {
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

    withEnvironment(apiService: MockService(fetchUserProjectsBackedResponse: projects),
                    currentUser: user) {

      self.vm.inputs.viewWillAppear(false)
      self.scheduler.advance()

      self.user.assertValues([user], "Current user emmitted.")
      self.hasBackedProjects.assertValues([true])
      self.showEmptyState.assertValues([false])

      XCTAssertEqual(["Profile View My", "Viewed Profile"], trackingClient.events)

      self.vm.inputs.viewWillAppear(false)
      self.scheduler.advance()

      self.user.assertValues([user, user], "Current user emmitted.")
      self.hasBackedProjects.assertValues([true])
      self.showEmptyState.assertValues([false])

      XCTAssertEqual(["Profile View My", "Viewed Profile", "Profile View My", "Viewed Profile"],
                     trackingClient.events)

      self.vm.inputs.viewWillAppear(true)
      self.scheduler.advance()

      self.user.assertValues([user, user, user], "Current user emmitted.")
      self.hasBackedProjects.assertValues([true])
      self.showEmptyState.assertValues([false])

      XCTAssertEqual(["Profile View My", "Viewed Profile", "Profile View My", "Viewed Profile"],
                     trackingClient.events, "Viewed Profile tracking does not emit.")

      // Come back after backing a project.
      withEnvironment(apiService: MockService(fetchUserProjectsBackedResponse: projectsWithNewProject),
                      currentUser: user) {

        self.vm.inputs.viewWillAppear(false)
        self.scheduler.advance()

        self.user.assertValues([user, user, user, user], "Current user emmitted.")
        self.hasBackedProjects.assertValues([true, true])
        self.showEmptyState.assertValues([false, false])

        XCTAssertEqual(["Profile View My", "Viewed Profile", "Profile View My", "Viewed Profile",
          "Profile View My", "Viewed Profile"], trackingClient.events)

      }
    }
  }

  func testUser_WithNoProjects() {
    withEnvironment(apiService: MockService(fetchUserProjectsBackedResponse: [])) {
      AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: .template))

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
}
