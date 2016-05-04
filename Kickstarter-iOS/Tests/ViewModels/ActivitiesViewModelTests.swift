import XCTest
@testable import Kickstarter_iOS
@testable import Library
@testable import KsApi
@testable import KsApi_TestHelpers
@testable import ReactiveExtensions_TestHelpers
import Result
import Models
@testable import Models_TestHelpers

final class ActivitiesViewModelTests: TestCase {
  let vm: ActivitiesViewModelType! = ActivitiesViewModel()

  let activitiesPresent = TestObserver<Bool, NoError>()
  let showLoggedOutEmptyState = TestObserver<Bool, NoError>()
  let showLoggedInEmptyState = TestObserver<Bool, NoError>()
  let isRefreshing = TestObserver<Bool, NoError>()
  let showProject = TestObserver<Project, NoError>()
  let showRefTag = TestObserver<RefTag, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.activities.map { !$0.isEmpty }.observe(self.activitiesPresent.observer)
    self.vm.outputs.showLoggedOutEmptyState.observe(self.showLoggedOutEmptyState.observer)
    self.vm.outputs.showLoggedInEmptyState.observe(self.showLoggedInEmptyState.observer)
    self.vm.outputs.isRefreshing.observe(self.isRefreshing.observer)
    self.vm.outputs.showProject.map { $0.0 }.observe(self.showProject.observer)
    self.vm.outputs.showProject.map { $0.1 }.observe(self.showRefTag.observer)
  }

  // Tests the flow of logging in with a user that has activities.
  func testLoginFlow_ForUserWithActivities() {
    self.vm.inputs.viewWillAppear()

    activitiesPresent.assertValues([], "No activities shown")
    showLoggedOutEmptyState.assertValues([true], "Logged-out empty state shown.")
    showLoggedInEmptyState.assertValues([], "No logged-in empty state.")

    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: UserFactory.user()))
    self.vm.inputs.userSessionStarted()
    self.scheduler.advance()

    activitiesPresent.assertValues([true], "Activities load immediately after session starts.")
    showLoggedOutEmptyState.assertValues([true, false], "Logged-out empty state goes away.")
    showLoggedInEmptyState.assertValues([], "Logged-in empty state never showed.")
  }

  // Tests the flow of logging in with a user that has not activities and making sure the correct
  // empty state shows.
  func testLoginFlow_ForUserWithNoActivities() {
    withEnvironment(apiService: MockService(fetchActivitiesResponse: [])) {
      self.vm.inputs.viewWillAppear()
      self.scheduler.advance()

      activitiesPresent.assertValues([], "Activities didn't emit.")
      showLoggedOutEmptyState.assertValues([true], "Logged out empty state visible.")
      showLoggedInEmptyState.assertValues([], "Logged in empty state didn't emit.")

      AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: UserFactory.user()))
      self.vm.inputs.userSessionStarted()
      self.scheduler.advance()

      activitiesPresent.assertValues([false], "Activities emit an empty array.")
      showLoggedOutEmptyState.assertValues([true, false], "Logged out empty state goes away.")
      showLoggedInEmptyState.assertValues([true], "Logged in empty state is visible.")
    }
  }

  // Tests that activities are cleared if the user is logged out for any reason.
  func testInvalidatedTokenFlow_ActivitiesClearAfterSessionCleared() {
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: UserFactory.user()))
    self.vm.inputs.viewWillAppear()
    self.scheduler.advance()

    activitiesPresent.assertValues([true], "Activities show right away.")
    showLoggedOutEmptyState.assertValues([], "No empty state.")

    AppEnvironment.logout()
    self.vm.inputs.userSessionEnded()
    self.scheduler.advance()

    activitiesPresent.assertValues([true, false], "Activities clear right away.")
    showLoggedOutEmptyState.assertValues([true], "Empty state displayed.")
  }

  // Tests the flow:
  //   * user logs in before ever view activities
  //   * user navigates to activities
  func testLogin_BeforeActivityViewAppeared() {
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: UserFactory.user()))
    self.vm.inputs.userSessionStarted()
    self.scheduler.advance()

    activitiesPresent.assertValues([], "Activities don't load after session starts.")

    self.vm.inputs.viewWillAppear()
    self.scheduler.advance()

    activitiesPresent.assertValues([true], "Activities load once view appears.")
  }

  func testRefreshActivities() {
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: UserFactory.user()))
    self.vm.inputs.userSessionStarted()
    self.vm.inputs.viewWillAppear()
    self.scheduler.advance()

    activitiesPresent.assertValues([true], "Activities load immediately after session starts.")

    self.vm.inputs.willDisplayRow(9, outOf: 10)
    self.scheduler.advance()

    activitiesPresent.assertValues([true, true], "Activities load immediately after session starts.")

    self.vm.inputs.refresh()
    self.scheduler.advance()

    activitiesPresent.assertValues([true, true, true], "Activities load immediately after session starts.")
  }

  func testShowProject() {
    let activity = ActivityFactory.backingActivity
    let project = activity.project!
    let refTag = RefTag.activity

    self.vm.inputs.activityUpdateCellTappedProjectImage(activity: activity)

    self.showProject.assertValues([project])
    self.showRefTag.assertValues([refTag])
  }
}
