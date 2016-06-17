import XCTest
@testable import Library
@testable import KsApi
@testable import ReactiveExtensions_TestHelpers
import Result
import KsApi
import Prelude

final class ActivitiesViewModelTests: TestCase {
  let vm: ActivitiesViewModelType! = ActivitiesViewModel()

  let activitiesPresent = TestObserver<Bool, NoError>()
  let showLoggedOutEmptyState = TestObserver<Bool, NoError>()
  let showLoggedInEmptyState = TestObserver<Bool, NoError>()
  let isRefreshing = TestObserver<Bool, NoError>()
  let goToProject = TestObserver<Project, NoError>()
  let showRefTag = TestObserver<RefTag, NoError>()
  let deleteFacebookConnectSection = TestObserver<(), NoError>()
  let deleteFindFriendsSection = TestObserver<(), NoError>()
  let goToFriends = TestObserver<FriendsSource, NoError>()
  let showFacebookConnectSection = TestObserver<Bool, NoError>()
  let showFacebookConnectSectionSource = TestObserver<FriendsSource, NoError>()
  let showFindFriendsSection = TestObserver<Bool, NoError>()
  let showFindFriendsSectionSource = TestObserver<FriendsSource, NoError>()
  let showFacebookConnectErrorAlert = TestObserver<AlertError, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.activities.map { !$0.isEmpty }.observe(self.activitiesPresent.observer)
    self.vm.outputs.showLoggedOutEmptyState.observe(self.showLoggedOutEmptyState.observer)
    self.vm.outputs.showLoggedInEmptyState.observe(self.showLoggedInEmptyState.observer)
    self.vm.outputs.isRefreshing.observe(self.isRefreshing.observer)
    self.vm.outputs.goToProject.map { $0.0 }.observe(self.goToProject.observer)
    self.vm.outputs.goToProject.map { $0.1 }.observe(self.showRefTag.observer)
    self.vm.outputs.deleteFacebookConnectSection.observe(self.deleteFacebookConnectSection.observer)
    self.vm.outputs.deleteFindFriendsSection.observe(self.deleteFindFriendsSection.observer)
    self.vm.outputs.goToFriends.observe(self.goToFriends.observer)
    self.vm.outputs.showFacebookConnectSection.map { $0.1 }.observe(self.showFacebookConnectSection.observer)
    self.vm.outputs.showFacebookConnectSection.map { $0.0 }
      .observe(self.showFacebookConnectSectionSource.observer)
    self.vm.outputs.showFindFriendsSection.map { $0.1 }.observe(self.showFindFriendsSection.observer)
    self.vm.outputs.showFindFriendsSection.map { $0.0 }.observe(self.showFindFriendsSectionSource.observer)
    self.vm.outputs.showFacebookConnectErrorAlert.observe(self.showFacebookConnectErrorAlert.observer)
  }

  // Tests the flow of logging in with a user that has activities.
  func testLoginFlow_ForUserWithActivities() {
    self.vm.inputs.viewWillAppear()

    activitiesPresent.assertValues([], "No activities shown")
    showLoggedOutEmptyState.assertValues([true], "Logged-out empty state shown.")
    showLoggedInEmptyState.assertValues([], "No logged-in empty state.")

    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: User.template))
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

      AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: User.template))
      self.vm.inputs.userSessionStarted()
      self.scheduler.advance()

      activitiesPresent.assertValues([false], "Activities emit an empty array.")
      showLoggedOutEmptyState.assertValues([true, false], "Logged out empty state goes away.")
      showLoggedInEmptyState.assertValues([true], "Logged in empty state is visible.")
    }
  }

  // Tests that activities are cleared if the user is logged out for any reason.
  func testInvalidatedTokenFlow_ActivitiesClearAfterSessionCleared() {
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: User.template))
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
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: User.template))
    self.vm.inputs.userSessionStarted()
    self.scheduler.advance()

    activitiesPresent.assertValues([], "Activities don't load after session starts.")

    self.vm.inputs.viewWillAppear()
    self.scheduler.advance()

    activitiesPresent.assertValues([true], "Activities load once view appears.")
  }

  func testRefreshActivities() {
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: User.template))
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

  func testGoToProject() {
    let activity = Activity.template |> Activity.lens.category .~ .backing
    let project = activity.project!
    let refTag = RefTag.activity

    self.vm.inputs.activityUpdateCellTappedProjectImage(activity: activity)

    self.goToProject.assertValues([project])
    self.showRefTag.assertValues([refTag])
  }

  func testGoToFriends() {
    self.vm.inputs.viewWillAppear()

    showFacebookConnectSection.assertValues([false])

    self.goToFriends.assertValueCount(0)

    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: User.template))
    self.vm.inputs.userSessionStarted()
    self.scheduler.advance()

    showFacebookConnectSection.assertValues([false, true], "Show Facebook Connect Section after log in")

    self.vm.inputs.findFriendsFacebookConnectCellDidFacebookConnectUser()

    self.goToFriends.assertValues([FriendsSource.activity])

    self.vm.inputs.viewWillAppear()

    self.goToFriends.assertValueCount(1)

    self.vm.inputs.findFriendsHeaderCellGoToFriends()

    self.goToFriends.assertValues([FriendsSource.activity, FriendsSource.activity])
  }

  func testFacebookSection() {
    // logged out
    self.showFacebookConnectSectionSource.assertValueCount(0)
    self.showFacebookConnectSection.assertValueCount(0)

    self.vm.inputs.viewWillAppear()

    self.showFacebookConnectSectionSource.assertValues([FriendsSource.activity])
    self.showFacebookConnectSection.assertValues([false], "Don't show Facebook Connect Section")

    // logged in && Facebook connected
    let user = User.template |> User.lens.facebookConnected .~ true
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: user))
    self.vm.inputs.userSessionStarted()
    self.scheduler.advance()

    self.showFacebookConnectSectionSource.assertValues([FriendsSource.activity])
    self.showFacebookConnectSection.assertValues([false], "Don't show Facebook Connect Section")

    // logged in && not Facebook connected
    AppEnvironment.logout()
    self.vm.inputs.userSessionEnded()
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: User.template))
    self.vm.inputs.userSessionStarted()
    self.scheduler.advance()

    self.showFacebookConnectSectionSource.assertValues([FriendsSource.activity, FriendsSource.activity])
    self.showFacebookConnectSection.assertValues([false, true], "Show Facebook Connect Section")

    // returning view
    let vm2: ActivitiesViewModelType = ActivitiesViewModel()
    let showFacebookConnectSection2 = TestObserver<Bool, NoError>()
    vm2.outputs.showFacebookConnectSection.map { $0.1 }
      .observe(showFacebookConnectSection2.observer)

    vm2.inputs.viewWillAppear()

    showFacebookConnectSection2.assertValues([true], "Show Facebook Connect Section on return")

    // delete section
    self.deleteFacebookConnectSection.assertValueCount(0)

    self.vm.inputs.findFriendsFacebookConnectCellDidDismissHeader()

    self.deleteFacebookConnectSection.assertValueCount(1)

    vm2.inputs.viewWillAppear()

    showFacebookConnectSection2.assertValues([true, false], "Don't show Facebook Connect Section on return")

    // returning view
    let vm3: ActivitiesViewModelType = ActivitiesViewModel()
    let showFacebookConnectSection3 = TestObserver<Bool, NoError>()
    vm3.outputs.showFacebookConnectSection.map { $0.1 }
      .observe(showFacebookConnectSection3.observer)

    vm3.inputs.viewWillAppear()

    showFacebookConnectSection3.assertValues([false], "Don't show Facebook Connect Section on return")
  }

  func testFindFriendsSection() {
    // logged out
    self.showFindFriendsSectionSource.assertValueCount(0)
    self.showFindFriendsSection.assertValueCount(0)

    self.vm.inputs.viewWillAppear()

    self.showFindFriendsSectionSource.assertValues([FriendsSource.activity])
    self.showFindFriendsSection.assertValues([false], "Don't show Facebook Connect Section")

    // logged in && not Facebook connected
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: User.template))
    self.vm.inputs.userSessionStarted()
    self.scheduler.advance()

    self.showFindFriendsSectionSource.assertValues([FriendsSource.activity])
    self.showFindFriendsSection.assertValues([false], "Don't show Find Friends Section")

    // logged in && Facebook connected
    AppEnvironment.logout()
    self.vm.inputs.userSessionEnded()
    let userNotConnected = User.template |> User.lens.facebookConnected .~ true
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: userNotConnected))
    self.vm.inputs.userSessionStarted()
    self.scheduler.advance()

    self.showFindFriendsSectionSource.assertValues([FriendsSource.activity, FriendsSource.activity])
    self.showFindFriendsSection.assertValues([false, true], "Show Find Friends Section")

    // returning view
    let vm2: ActivitiesViewModelType = ActivitiesViewModel()
    let showFindFriendsSection2 = TestObserver<Bool, NoError>()
    vm2.outputs.showFindFriendsSection.map { $0.1 }
      .observe(showFindFriendsSection2.observer)

    vm2.inputs.viewWillAppear()

    showFindFriendsSection2.assertValues([true], "Show Find Friends on return")

    // delete section
    self.deleteFindFriendsSection.assertValueCount(0)

    self.vm.inputs.findFriendsHeaderCellDismissHeader()

    self.deleteFindFriendsSection.assertValueCount(1)

    vm2.inputs.viewWillAppear()

    showFindFriendsSection2.assertValues([true, false], "Don't show Find Friends Section on return")

    // returning view
    let vm3: ActivitiesViewModelType = ActivitiesViewModel()
    let showFindFriendsSection3 = TestObserver<Bool, NoError>()
    vm3.outputs.showFindFriendsSection.map { $0.1 }
      .observe(showFindFriendsSection3.observer)

    vm3.inputs.viewWillAppear()

    showFindFriendsSection3.assertValues([false], "Don't show Find Friends Section on return")
  }

  func testFacebookErrorAlerts() {
    let alert = AlertError.facebookTokenFail
    self.vm.inputs.findFriendsFacebookConnectCellShowErrorAlert(alert)

    self.showFacebookConnectErrorAlert.assertValues([AlertError.facebookTokenFail])
  }
}
