import XCTest
@testable import Kickstarter_iOS
@testable import Library
@testable import KsApi
@testable import KsApi_TestHelpers
@testable import ReactiveExtensions_TestHelpers
import Result
import Models
@testable import Models_TestHelpers

final class ActivitiesViewModelTests: XCTestCase {
  let apiService = MockService()
  let vm: ActivitiesViewModelType! = ActivitiesViewModel()

  override func setUp() {
    super.setUp()
    AppEnvironment.pushEnvironment(
      apiService: apiService,
      ubiquitousStore: MockKeyValueStore(),
      userDefaults: MockKeyValueStore()
    )
  }

  override func tearDown() {
    super.tearDown()
    AppEnvironment.popEnvironment()
  }

  // Tests the flow of logging in with a user that has activities.
  func testLoginFlow_ForUserWithActivities() {
    let activitiesPresent = TestObserver<Bool, NoError>()
    self.vm.outputs.activities.map { $0.count > 0 }.observe(activitiesPresent.observer)

    let showLoggedOutEmptyState = TestObserver<Bool, NoError>()
    self.vm.outputs.showLoggedOutEmptyState.observe(showLoggedOutEmptyState.observer)

    let showLoggedInEmptyState = TestObserver<Bool, NoError>()
    self.vm.outputs.showLoggedInEmptyState.observe(showLoggedInEmptyState.observer)

    self.vm.inputs.viewWillAppear()

    activitiesPresent.assertValues([], "No activities shown")
    showLoggedOutEmptyState.assertValues([true], "Logged-out empty state shown.")
    showLoggedInEmptyState.assertValues([], "No logged-in empty state.")

    AppEnvironment.login(AccessTokenEnvelope(access_token: "deadbeef", user: UserFactory.user))
    self.vm.inputs.userSessionStarted()

    activitiesPresent.assertValues([true], "Activities load immediately after session starts.")
    showLoggedOutEmptyState.assertValues([true, false], "Logged-out empty state goes away.")
    showLoggedInEmptyState.assertValues([], "Logged-in empty state never showed.")
  }

  // Tests the flow of logging in with a user that has not activities and making sure the correct
  // empty state shows.
  func testLoginFlow_ForUserWithNoActivities() {
    withEnvironment(apiService: MockService(activities: [])) {
      let activitiesPresent = TestObserver<Bool, NoError>()
      self.vm.outputs.activities.map { $0.count > 0 }.observe(activitiesPresent.observer)

      let showLoggedOutEmptyState = TestObserver<Bool, NoError>()
      self.vm.outputs.showLoggedOutEmptyState.observe(showLoggedOutEmptyState.observer)

      let showLoggedInEmptyState = TestObserver<Bool, NoError>()
      self.vm.outputs.showLoggedInEmptyState.observe(showLoggedInEmptyState.observer)

      self.vm.inputs.viewWillAppear()

      activitiesPresent.assertValues([], "Activities didn't emit.")
      showLoggedOutEmptyState.assertValues([true], "Logged out empty state visible.")
      showLoggedInEmptyState.assertValues([], "Logged in empty state didn't emit.")

      AppEnvironment.login(AccessTokenEnvelope(access_token: "deadbeef", user: UserFactory.user))
      self.vm.inputs.userSessionStarted()

      activitiesPresent.assertValues([false], "Activities emit an empty array.")
      showLoggedOutEmptyState.assertValues([true, false], "Logged out empty state goes away.")
      showLoggedInEmptyState.assertValues([true], "Logged in empty state is visible.")
    }
  }

  // Tests that activities are cleared if the user is logged out for any reason.
  func testInvalidatedTokenFlow_ActivitiesClearAfterSessionCleared() {
    let activitiesPresent = TestObserver<Bool, NoError>()
    self.vm.outputs.activities.map { $0.count > 0 }.observe(activitiesPresent.observer)

    let showLoggedOutEmptyState = TestObserver<Bool, NoError>()
    self.vm.outputs.showLoggedOutEmptyState.observe(showLoggedOutEmptyState.observer)

    AppEnvironment.login(AccessTokenEnvelope(access_token: "deadbeef", user: UserFactory.user))
    self.vm.inputs.viewWillAppear()

    activitiesPresent.assertValues([true], "Activities show right away.")
    showLoggedOutEmptyState.assertValues([], "No empty state.")

    AppEnvironment.logout()
    self.vm.inputs.userSessionEnded()

    activitiesPresent.assertValues([true, false],"Activities clear right away.")
    showLoggedOutEmptyState.assertValues([true], "Empty state displayed.")
  }

  // Tests the flow:
  //   * user logs in before ever view activities
  //   * user navigates to activities
  func testLogin_BeforeActivityViewAppeared() {
    let activitiesPresent = TestObserver<Bool, NoError>()
    self.vm.outputs.activities.map { $0.count > 0 }.observe(activitiesPresent.observer)

    AppEnvironment.login(AccessTokenEnvelope(access_token: "deadbeef", user: UserFactory.user))
    self.vm.inputs.userSessionStarted()

    activitiesPresent.assertValues([], "Activities don't load after session starts.")

    self.vm.inputs.viewWillAppear()

    activitiesPresent.assertValues([true], "Activities load once view appears.")
  }
}
