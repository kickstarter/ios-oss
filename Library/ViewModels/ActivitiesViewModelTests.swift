@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

final class ActivitiesViewModelTests: TestCase {
  fileprivate let vm: ActivitiesViewModelType! = ActivitiesViewModel()

  fileprivate let activitiesPresent = TestObserver<Bool, Never>()
  fileprivate let clearBadgeValue = TestObserver<(), Never>()
  fileprivate let erroredBackings = TestObserver<[GraphBacking], Never>()
  fileprivate let isRefreshing = TestObserver<Bool, Never>()
  fileprivate let goToProject = TestObserver<Project, Never>()
  fileprivate let goToSurveyResponse = TestObserver<SurveyResponse, Never>()
  fileprivate let showRefTag = TestObserver<RefTag, Never>()
  fileprivate let deleteFacebookConnectSection = TestObserver<(), Never>()
  fileprivate let deleteFindFriendsSection = TestObserver<(), Never>()
  fileprivate let hideEmptyState = TestObserver<(), Never>()
  fileprivate let goToFriends = TestObserver<FriendsSource, Never>()
  fileprivate let goToManagePledgeProjectParam = TestObserver<Param, Never>()
  fileprivate let goToManagePledgeBackingParam = TestObserver<Param?, Never>()
  fileprivate let showEmptyStateIsLoggedIn = TestObserver<Bool, Never>()
  fileprivate let showFacebookConnectSection = TestObserver<Bool, Never>()
  fileprivate let showFacebookConnectSectionSource = TestObserver<FriendsSource, Never>()
  fileprivate let showFindFriendsSection = TestObserver<Bool, Never>()
  fileprivate let showFindFriendsSectionSource = TestObserver<FriendsSource, Never>()
  fileprivate let showFacebookConnectErrorAlert = TestObserver<AlertError, Never>()
  fileprivate let unansweredSurveyResponse = TestObserver<[SurveyResponse], Never>()
  fileprivate let updateUserInEnvironment = TestObserver<User, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.activities.map { !$0.isEmpty }.observe(self.activitiesPresent.observer)
    self.vm.outputs.clearBadgeValue.observe(self.clearBadgeValue.observer)
    self.vm.outputs.erroredBackings.observe(self.erroredBackings.observer)
    self.vm.outputs.hideEmptyState.observe(self.hideEmptyState.observer)
    self.vm.outputs.isRefreshing.observe(self.isRefreshing.observer)
    self.vm.outputs.goToProject.map { $0.0 }.observe(self.goToProject.observer)
    self.vm.outputs.goToProject.map { $0.1 }.observe(self.showRefTag.observer)
    self.vm.outputs.deleteFacebookConnectSection.observe(self.deleteFacebookConnectSection.observer)
    self.vm.outputs.deleteFindFriendsSection.observe(self.deleteFindFriendsSection.observer)
    self.vm.outputs.goToFriends.observe(self.goToFriends.observer)
    self.vm.outputs.goToSurveyResponse.observe(self.goToSurveyResponse.observer)
    self.vm.outputs.goToManagePledge.map(first).observe(self.goToManagePledgeProjectParam.observer)
    self.vm.outputs.goToManagePledge.map(second).observe(self.goToManagePledgeBackingParam.observer)
    self.vm.outputs.showEmptyStateIsLoggedIn.observe(self.showEmptyStateIsLoggedIn.observer)
    self.vm.outputs.showFacebookConnectSection.map { $0.1 }.observe(self.showFacebookConnectSection.observer)
    self.vm.outputs.showFacebookConnectSection.map { $0.0 }
      .observe(self.showFacebookConnectSectionSource.observer)
    self.vm.outputs.showFindFriendsSection.map { $0.1 }.observe(self.showFindFriendsSection.observer)
    self.vm.outputs.showFindFriendsSection.map { $0.0 }.observe(self.showFindFriendsSectionSource.observer)
    self.vm.outputs.showFacebookConnectErrorAlert.observe(self.showFacebookConnectErrorAlert.observer)
    self.vm.outputs.unansweredSurveys.observe(self.unansweredSurveyResponse.observer)
    self.vm.outputs.updateUserInEnvironment.observe(self.updateUserInEnvironment.observer)
  }

  // Tests the flow of logging in with a user that has activities.
  func testLoginFlow_ForUserWithActivities() {
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: false)

    self.activitiesPresent.assertValues([], "No activities shown for logged-out user.")
    self.showEmptyStateIsLoggedIn.assertValues([false], "Logged-out empty state emits.")

    self.vm.inputs.viewWillAppear(animated: false)

    self.activitiesPresent.assertValues([], "No activities shown for logged-out user.")
    self.showEmptyStateIsLoggedIn.assertValues([false], "Logged-out empty state does not emit again.")
    self.hideEmptyState.assertValueCount(1, "Dismiss empty state emits.")

    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: User.template))
    withEnvironment(apiService: MockService(fetchActivitiesResponse: [self.activity1, self.activity2])) {
      self.vm.inputs.userSessionStarted()
      self.vm.inputs.viewWillAppear(animated: false)

      self.scheduler.advance()

      self.activitiesPresent.assertValues([true], "Activities load after session starts and view appears.")
      self.showEmptyStateIsLoggedIn.assertValues([false], "Empty state does not emit.")
      self.hideEmptyState.assertValueCount(2, "Dismiss empty state emits.")

      self.vm.inputs.viewWillAppear(animated: false)

      self.activitiesPresent.assertValues([true], "Same activities do not emit again.")
      self.showEmptyStateIsLoggedIn.assertValues([false], "Empty state does not emit.")
      self.hideEmptyState.assertValueCount(2, "Dismiss empty state does not emit.")
    }

    AppEnvironment.logout()
    self.vm.inputs.userSessionEnded()

    self.activitiesPresent.assertValues([true, false], "Activities are cleared.")
    self.showEmptyStateIsLoggedIn.assertValues([false], "Empty logged-in state does not emit.")
    self.hideEmptyState.assertValueCount(2, "Dismiss empty state does not emit.")

    self.vm.inputs.viewWillAppear(animated: false)

    self.activitiesPresent.assertValues([true, false], "Activities are still cleared.")
    self.showEmptyStateIsLoggedIn.assertValues([false, false], "Logged-out empty state emits again.")
    self.hideEmptyState.assertValueCount(2, "Dismiss empty state does not emit.")

    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeefffffff", user: User.brando))
    withEnvironment(apiService: MockService(fetchActivitiesResponse: [])) {
      self.vm.inputs.userSessionStarted()
      self.vm.inputs.viewWillAppear(animated: false)

      self.scheduler.advance()

      self.activitiesPresent.assertValues([true, false, false], "Emits empty activities.")
      self.showEmptyStateIsLoggedIn.assertValues([false, false, true], "Logged-in empty state emits.")
      self.hideEmptyState.assertValueCount(2, "Dismiss empty state does not emit.")
    }
  }

  // Tests the flow of logging in with a user that has no activities and making sure the correct
  // empty state shows.
  func testLoginFlow_ForUserWithNoActivities() {
    withEnvironment(apiService: MockService(fetchActivitiesResponse: [])) {
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.viewWillAppear(animated: false)
      self.scheduler.advance()

      activitiesPresent.assertValues([], "Activities didn't emit.")
      showEmptyStateIsLoggedIn.assertValues([false], "Logged out empty state emits.")

      AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: User.template))
      self.vm.inputs.userSessionStarted()
      self.vm.inputs.viewWillAppear(animated: false)

      self.scheduler.advance()

      activitiesPresent.assertValues([false], "Activities emit an empty array.")
      // NB: Technically, it is correct that the logged-in empty state should emit here.
      // However, it would be better if the logged-out empty state could have dismissed first.
      // For now, the view controller won't present another empty state if this modal exists already.
      showEmptyStateIsLoggedIn.assertValues([false, true], "Logged in empty state emits.")
      hideEmptyState.assertValueCount(1, "Dismiss empty state emits on view load.")

      self.vm.inputs.viewWillAppear(animated: false)

      activitiesPresent.assertValues([false], "Activities does not emit.")
      showEmptyStateIsLoggedIn.assertValues([false, true], "Logged in empty state does not emit again.")
      hideEmptyState.assertValueCount(1, "Dismiss empty state does not emit.")
    }
  }

  // Tests that activities are cleared if the user is logged out for any reason.
  func testInvalidatedTokenFlow_ActivitiesClearAfterSessionCleared() {
    self.vm.inputs.viewDidLoad()

    self.hideEmptyState.assertValueCount(1, "Dismiss empty state emits.")

    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: User.template))
    self.vm.inputs.userSessionStarted()
    self.vm.inputs.viewWillAppear(animated: false)

    self.scheduler.advance()

    self.activitiesPresent.assertValues([true], "Activities show right away.")
    self.showEmptyStateIsLoggedIn.assertValueCount(0, "Empty state does not emit.")
    self.hideEmptyState.assertValueCount(2, "Dismiss empty state emits.")

    AppEnvironment.logout()
    self.vm.inputs.userSessionEnded()

    self.showEmptyStateIsLoggedIn.assertValueCount(0, "Empty state does not emit.")

    self.vm.inputs.viewWillAppear(animated: false)

    self.scheduler.advance()

    self.activitiesPresent.assertValues([true, false], "Activities clear right away.")
    self.showEmptyStateIsLoggedIn.assertValues([false], "Logged out empty state emits.")
    self.hideEmptyState.assertValueCount(2, "Dismiss empty state does not emit.")

    self.vm.inputs.viewWillAppear(animated: false)

    self.activitiesPresent.assertValues([true, false], "Activities does not emit again.")
    self.showEmptyStateIsLoggedIn.assertValues([false], "Logged out empty state does not emit again.")
    self.hideEmptyState.assertValueCount(2, "Dismiss empty state does not emit.")
  }

  // Tests the flow:
  //   * user logs in before ever view activities
  //   * user navigates to activities
  func testLogin_BeforeActivityViewAppeared() {
    self.vm.inputs.viewDidLoad()

    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: User.template))
    self.vm.inputs.userSessionStarted()
    self.scheduler.advance()

    self.activitiesPresent.assertValues([], "Activities don't load after session starts.")

    self.vm.inputs.viewWillAppear(animated: false)

    self.activitiesPresent.assertValues([true], "Activities load once view appears.")
  }

  func testRefreshActivities() {
    withEnvironment(
      apiService: MockService(fetchActivitiesResponse: [self.activity1, self.activity2]),
      currentUser: .template
    ) {
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.userSessionStarted()
      self.vm.inputs.viewWillAppear(animated: false)
      self.scheduler.advance()

      self.activitiesPresent.assertValues([true], "Activities load immediately after session starts.")

      self.vm.inputs.willDisplayRow(9, outOf: 10)
      self.scheduler.advance()

      self.activitiesPresent.assertValues([true, true], "New activities emit on pagination.")

      // New fetchActivitiesResponse
      withEnvironment(apiService: MockService(fetchActivitiesResponse: [activity1, activity2, activity3])) {
        self.vm.inputs.refresh()
        self.scheduler.advance()

        self.activitiesPresent.assertValues([true, true, true], "New activities emit on refresh.")
      }
    }
  }

  func testClearBadgeValueOnRefreshActivities() {
    self.updateUserInEnvironment.assertValues([])
    self.clearBadgeValue.assertValueCount(0)

    let mockService1 = MockService(
      clearUserUnseenActivityResult: Result.success(.init(activityIndicatorCount: 0)),
      fetchActivitiesResponse: [self.activity1, self.activity2]
    )

    let mockService2 = MockService(
      clearUserUnseenActivityResult: Result.success(.init(activityIndicatorCount: 0)),
      fetchActivitiesResponse: [self.activity1, self.activity2, self.activity3]
    )

    let user = User.template
      |> User.lens.unseenActivityCount .~ 100

    withEnvironment(
      apiService: mockService1,
      currentUser: user
    ) {
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.userSessionStarted()
      self.vm.inputs.viewWillAppear(animated: false)
      self.scheduler.advance()

      self.updateUserInEnvironment.assertValues([])
      self.activitiesPresent.assertValues([true], "Activities load immediately after session starts.")
      self.clearBadgeValue.assertValueCount(0)

      withEnvironment(apiService: mockService2) {
        self.vm.inputs.refresh()
        self.scheduler.advance()

        self.activitiesPresent.assertValues([true, true], "New activities emit on refresh.")
        self.clearBadgeValue.assertValueCount(1)
        XCTAssertEqual(self.updateUserInEnvironment.values.map { $0.id }, [user.id])

        self.scheduler.advance()

        XCTAssertEqual(self.updateUserInEnvironment.values.map { $0.id }, [user.id])
      }
    }
  }

  func testClearBadgeValueOnRefreshActivities_LoggedOut() {
    self.updateUserInEnvironment.assertValues([])
    self.clearBadgeValue.assertValueCount(0)

    let mockService1 = MockService(
      clearUserUnseenActivityResult: Result.success(.init(activityIndicatorCount: 0)),
      fetchActivitiesResponse: [self.activity1, self.activity2]
    )

    let mockService2 = MockService(
      clearUserUnseenActivityResult: Result.success(.init(activityIndicatorCount: 0)),
      fetchActivitiesResponse: [self.activity1, self.activity2, self.activity3]
    )

    withEnvironment(
      apiService: mockService1
    ) {
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.userSessionStarted()
      self.vm.inputs.viewWillAppear(animated: false)
      self.scheduler.advance()

      self.updateUserInEnvironment.assertValues([])
      self.activitiesPresent.assertValues([])
      self.clearBadgeValue.assertValueCount(0)

      withEnvironment(apiService: mockService2) {
        self.vm.inputs.refresh()
        self.scheduler.advance()

        self.activitiesPresent.assertValues([])
        self.clearBadgeValue.assertValueCount(0)
        self.updateUserInEnvironment.assertValues([])

        self.scheduler.advance()

        self.updateUserInEnvironment.assertValues([])
      }
    }
  }

  func testGoToProject() {
    let activity = .template |> Activity.lens.category .~ .backing
    let project = activity.project!
    let refTag = RefTag.activity

    self.vm.inputs.activityUpdateCellTappedProjectImage(activity: activity)

    self.goToProject.assertValues([project])
    self.showRefTag.assertValues([refTag])
  }

  func testGoToFriends() {
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: false)

    self.showFacebookConnectSection.assertValueCount(0)

    self.goToFriends.assertValueCount(0)

    withEnvironment(
      apiService: MockService(fetchUnansweredSurveyResponsesResponse: []),
      currentUser: .template
    ) {
      self.vm.inputs.userSessionStarted()
      self.scheduler.advance()
      self.vm.inputs.viewWillAppear(animated: false)

      showFacebookConnectSection.assertValues([true], "Show Facebook Connect Section after log in")

      self.vm.inputs.findFriendsFacebookConnectCellDidFacebookConnectUser()

      self.goToFriends.assertValues([FriendsSource.activity])

      self.vm.inputs.viewWillAppear(animated: false)

      self.goToFriends.assertValueCount(1)

      self.vm.inputs.findFriendsHeaderCellGoToFriends()

      self.goToFriends.assertValues([FriendsSource.activity, FriendsSource.activity])
    }
  }

  func testFacebookSection() {
    // logged out
    self.showFacebookConnectSectionSource.assertValueCount(0)
    self.showFacebookConnectSection.assertValueCount(0)

    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: false)

    self.showFacebookConnectSectionSource.assertValueCount(0)
    self.showFacebookConnectSection.assertValueCount(0)

    // logged in && Facebook connected && doesn't need new token
    let user = User.template |> \.facebookConnected .~ true
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: user))
    self.vm.inputs.userSessionStarted()
    self.scheduler.advance()

    self.vm.inputs.viewWillAppear(animated: false)

    self.showFacebookConnectSectionSource.assertValues([FriendsSource.activity])
    self.showFacebookConnectSection.assertValues([false], "Don't show Facebook Connect Section")

    // logged in && not Facebook connected
    AppEnvironment.logout()
    self.vm.inputs.userSessionEnded()
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: User.template))
    self.vm.inputs.userSessionStarted()
    self.scheduler.advance()
    self.vm.inputs.viewWillAppear(animated: false)

    self.showFacebookConnectSectionSource.assertValues([FriendsSource.activity, FriendsSource.activity])
    self.showFacebookConnectSection.assertValues([false, true], "Show Facebook Connect Section")

    // logged in && FB connected, needs new token

    let facebookReconnectUser = User.template
      |> \.facebookConnected .~ true
      |> \.needsFreshFacebookToken .~ true
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: facebookReconnectUser))
    self.vm.inputs.userSessionStarted()
    self.scheduler.advance()

    self.vm.inputs.viewWillAppear(animated: false)

    self.showFacebookConnectSection.assertValues([false, true, true], "Show Facebook Section")

    // delete section
    self.deleteFacebookConnectSection.assertValueCount(0)

    self.vm.inputs.findFriendsFacebookConnectCellDidDismissHeader()

    self.deleteFacebookConnectSection.assertValueCount(1)

    self.vm.inputs.viewWillAppear(animated: false)

    self.showFacebookConnectSection.assertValues(
      [false, true, true, false],
      "Don't show Facebook Connect Section on return"
    )
  }

  func testFindFriendsSection() {
    // logged out
    self.showFindFriendsSectionSource.assertValueCount(0)
    self.showFindFriendsSection.assertValueCount(0)

    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: false)

    self.showFindFriendsSectionSource.assertValueCount(0)
    self.showFindFriendsSection.assertValueCount(0)

    // logged in && not Facebook connected
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: User.template))
    self.vm.inputs.userSessionStarted()
    self.scheduler.advance()
    self.vm.inputs.viewWillAppear(animated: false)

    self.showFindFriendsSectionSource.assertValues([FriendsSource.activity])
    self.showFindFriendsSection.assertValues([false], "Don't show Find Friends Section")

    // logged in && FB connected but needs fresh token
    AppEnvironment.logout()
    self.vm.inputs.userSessionEnded()
    let userConnected = User.template
      |> \.facebookConnected .~ true
      |> \.needsFreshFacebookToken .~ true
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: userConnected))
    self.vm.inputs.userSessionStarted()
    self.scheduler.advance()
    self.vm.inputs.viewWillAppear(animated: false)

    self.showFindFriendsSectionSource.assertValues([FriendsSource.activity, FriendsSource.activity])
    self.showFindFriendsSection.assertValues([false, false], "Hide find friends section")

    // logged in && Facebook connected & doesn't needs fresh token
    AppEnvironment.logout()
    self.vm.inputs.userSessionEnded()
    let fbConnected = User.template
      |> \.facebookConnected .~ true
      |> \.needsFreshFacebookToken .~ false
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: fbConnected))
    self.vm.inputs.userSessionStarted()
    self.scheduler.advance()
    self.vm.inputs.viewWillAppear(animated: false)

    self.showFindFriendsSectionSource.assertValues([
      FriendsSource.activity,
      FriendsSource.activity,
      FriendsSource.activity
    ])
    self.showFindFriendsSection.assertValues([false, false, true], "Show Find Friends Section")

    // delete section
    self.deleteFindFriendsSection.assertValueCount(0)

    self.vm.inputs.findFriendsHeaderCellDismissHeader()

    self.deleteFindFriendsSection.assertValueCount(1)

    self.vm.inputs.viewWillAppear(animated: false)

    self.showFindFriendsSection.assertValues([
      false,
      false,
      true,
      false
    ], "Don't show Find Friends Section on return")
  }

  func testFacebookErrorAlerts() {
    let alert = AlertError.facebookTokenFail
    self.vm.inputs.findFriendsFacebookConnectCellShowErrorAlert(alert)

    self.showFacebookConnectErrorAlert.assertValues([AlertError.facebookTokenFail])
  }

  func testSurveys() {
    let surveyResponse = SurveyResponse.template

    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: false)

    self.unansweredSurveyResponse.assertValueCount(0, "Survey does not emit when logged out.")

    withEnvironment(
      apiService: MockService(fetchUnansweredSurveyResponsesResponse: [surveyResponse]),
      currentUser: .template
    ) {
      self.vm.inputs.userSessionStarted()
      self.vm.inputs.viewWillAppear(animated: false)

      self.unansweredSurveyResponse.assertValues([[surveyResponse]])

      // Tap to see survey response.
      self.vm.inputs.tappedRespondNow(forSurveyResponse: surveyResponse)
      self.goToSurveyResponse.assertValues([surveyResponse])

      // Exited survey full screen.
      self.vm.inputs.viewWillAppear(animated: true)
      self.unansweredSurveyResponse.assertValues([[surveyResponse]], "Survey does not emit again.")

      self.vm.inputs.tappedRespondNow(forSurveyResponse: surveyResponse)
      self.goToSurveyResponse.assertValues([surveyResponse, surveyResponse])

      // Exited survey modal.
      self.vm.inputs.surveyResponseViewControllerDismissed()
      self.unansweredSurveyResponse.assertValues(
        [[surveyResponse], [surveyResponse]],
        "Same unanswered survey emits."
      )
    }
  }

  func testGoToManagePledge() {
    self.goToManagePledgeProjectParam.assertDidNotEmitValue()
    self.goToManagePledgeBackingParam.assertDidNotEmitValue()

    let backing = GraphBacking.template
      |> \.project .~ .template

    self.vm.inputs.erroredBackingViewDidTapManage(with: backing)

    guard
      let projectId = backing.project?.pid,
      let backingId = decompose(id: backing.id)
    else {
      XCTFail("Should have projectId and backingId")
      return
    }

    self.goToManagePledgeProjectParam.assertValues([.id(projectId)])
    self.goToManagePledgeBackingParam.assertValues([.id(backingId)])
  }

  func testTracking_GoToManagePledge() {
    withEnvironment(
      apiService: MockService(fetchActivitiesResponse: [.template]),
      currentUser: .template
    ) {
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.viewWillAppear(animated: false)
      self.vm.inputs.userSessionStarted()
      self.scheduler.advance()

      let backing = GraphBacking.template
        |> \.project .~ .template

      XCTAssertEqual(self.trackingClient.events, ["Activity Feed Viewed"])

      self.vm.inputs.erroredBackingViewDidTapManage(with: backing)

      XCTAssertEqual(
        self.trackingClient.events,
        ["Activity Feed Viewed", "Manage Pledge Button Clicked"]
      )
    }
  }

  func testUpdateUserInEnvironmentOnManagePledgeViewDidFinish() {
    let user = User.template

    let backing = GraphBacking.template
      |> \.project .~ .template

    let backings = GraphBackingEnvelope.GraphBackingConnection(nodes: [backing])

    let envelope = GraphBackingEnvelope.template
      |> \.backings .~ backings

    let backingsResponse = UserEnvelope<GraphBackingEnvelope>(me: envelope)

    let mockService = MockService(fetchGraphUserBackingsResponse: backingsResponse)

    withEnvironment(apiService: mockService, currentUser: user) {
      self.updateUserInEnvironment.assertDidNotEmitValue()
      self.erroredBackings.assertDidNotEmitValue()

      self.vm.inputs.managePledgeViewControllerDidFinish()

      self.scheduler.advance()

      self.updateUserInEnvironment.assertValues([user])
      self.erroredBackings.assertDidNotEmitValue()

      self.vm.inputs.currentUserUpdated()

      self.scheduler.advance()

      self.updateUserInEnvironment.assertValues([user])
      self.erroredBackings.assertValues([backingsResponse.me.backings.nodes])
    }
  }

  func testSurvey_DoesntEmitAfterLogOut() {
    let surveyResponse = SurveyResponse.template

    withEnvironment(apiService: MockService(fetchUnansweredSurveyResponsesResponse: [surveyResponse])) {
      AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: .template))
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.viewWillAppear(animated: false)

      self.unansweredSurveyResponse.assertValues([[surveyResponse]])

      AppEnvironment.logout()
      self.vm.inputs.userSessionEnded()
      self.vm.inputs.viewWillAppear(animated: false)

      self.unansweredSurveyResponse.assertValues([[surveyResponse]])
    }
  }

  func testKoalaFlow() {
    let page = [
      .template,
      .template |> Activity.lens.category .~ .backing,
      .template |> Activity.lens.category .~ .success
    ]

    let page2 = [
      .template |> Activity.lens.id .~ 40,
      .template |> Activity.lens.id .~ 41 |> Activity.lens.category .~ .backing,
      .template |> Activity.lens.id .~ 42 |> Activity.lens.category .~ .success
    ]

    withEnvironment(apiService: MockService(fetchActivitiesResponse: page)) {
      XCTAssertEqual([], self.trackingClient.events)

      self.vm.inputs.viewDidLoad()
      self.vm.inputs.viewWillAppear(animated: false)
      self.scheduler.advance()

      XCTAssertEqual([], self.trackingClient.events, "Tracking waits for results")

      AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: .template))
      self.vm.inputs.userSessionStarted()
      self.scheduler.advance()

      XCTAssertEqual(
        ["Activity Feed Viewed"],
        self.trackingClient.events, "Impression is tracked"
      )
      XCTAssertEqual([3], self.trackingClient.properties(forKey: "activities_count", as: Int.self))

      self.vm.inputs.viewWillAppear(animated: false)
      self.scheduler.advance()

      XCTAssertEqual(
        ["Activity Feed Viewed"],
        self.trackingClient.events, "Impression is not tracked when the view doesn't animate"
      )

      self.vm.inputs.refresh()
      self.scheduler.advance()

      XCTAssertEqual(
        ["Activity Feed Viewed", "Activity Feed Viewed"],
        self.trackingClient.events, "Impression tracked when view refreshes"
      )

      self.vm.inputs.viewWillAppear(animated: true)
      self.scheduler.advance()

      XCTAssertEqual(
        ["Activity Feed Viewed", "Activity Feed Viewed", "Activity Feed Viewed"], self.trackingClient.events,
        "Impression tracked when view re-appears with animation"
      )

      withEnvironment(apiService: MockService(fetchActivitiesResponse: page2)) {
        // Scroll down a bit and advance scheduler
        self.vm.inputs.willDisplayRow(3, outOf: 5)
        self.scheduler.advance()

        XCTAssertEqual(
          ["Activity Feed Viewed", "Activity Feed Viewed", "Activity Feed Viewed"],
          self.trackingClient.events,
          "Impression is not tracked on pagination"
        )
      }
    }
  }

  fileprivate let activity1 = .template |> Activity.lens.id .~ 1
  fileprivate let activity2 = .template |> Activity.lens.id .~ 2
  fileprivate let activity3 = .template |> Activity.lens.id .~ 3
}
