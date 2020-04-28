@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import UIKit.UIActivity
import XCTest

final class FindFriendsViewModelTests: TestCase {
  let vm: FindFriendsViewModelType = FindFriendsViewModel()

  let friends = TestObserver<[User], Never>()
  let goToDiscovery = TestObserver<DiscoveryParams, Never>()
  let showErrorAlert = TestObserver<AlertError, Never>()
  let showFacebookConnect = TestObserver<Bool, Never>()
  let showFollowAllFriendsAlert = TestObserver<Int, Never>()
  let showLoadingIndicatorView = TestObserver<Bool, Never>()
  let stats = TestObserver<FriendStatsEnvelope, Never>()
  let statsSource = TestObserver<FriendsSource, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.friends.map { $0.0 }.observe(self.friends.observer)
    self.vm.outputs.goToDiscovery.observe(self.goToDiscovery.observer)
    self.vm.outputs.showErrorAlert.observe(self.showErrorAlert.observer)
    self.vm.outputs.showFacebookConnect.map { $0.1 }.observe(self.showFacebookConnect.observer)
    self.vm.outputs.showFollowAllFriendsAlert.observe(self.showFollowAllFriendsAlert.observer)
    self.vm.outputs.showLoadingIndicatorView.observe(self.showLoadingIndicatorView.observer)
    self.vm.outputs.stats.map { env, _ in env }.observe(self.stats.observer)
    self.vm.outputs.stats.map { _, source in source }.observe(self.statsSource.observer)
  }

  func testSource() {
    self.vm.inputs.configureWith(source: FriendsSource.findFriends)
    self.vm.inputs.viewDidLoad()

    XCTAssertEqual(["Find Friends View", "Viewed Find Friends"], self.trackingClient.events)
    XCTAssertEqual(
      ["find-friends", "find-friends"],
      self.trackingClient.properties.map { $0["source"] as! String? }
    )

    XCTAssertEqual([true, nil], self.trackingClient.properties.map { $0[Koala.DeprecatedKey] as! Bool? })

    self.vm.inputs.configureWith(source: FriendsSource.activity)
    self.vm.inputs.viewDidLoad()

    XCTAssertEqual([
      "Find Friends View", "Viewed Find Friends",
      "Find Friends View", "Viewed Find Friends"
    ], self.trackingClient.events)

    XCTAssertEqual(
      [
        "find-friends", "find-friends",
        "activity", "activity"
      ],
      self.trackingClient.properties.map { $0["source"] as! String? }
    )

    self.vm.inputs.configureWith(source: FriendsSource.discovery)
    self.vm.inputs.viewDidLoad()

    XCTAssertEqual([
      "Find Friends View", "Viewed Find Friends",
      "Find Friends View", "Viewed Find Friends",
      "Find Friends View", "Viewed Find Friends"
    ], self.trackingClient.events)

    XCTAssertEqual(
      [
        "find-friends", "find-friends",
        "activity", "activity",
        "discovery", "discovery"
      ],
      self.trackingClient.properties.map { $0["source"] as! String? }
    )

    self.vm.inputs.configureWith(source: FriendsSource.settings)
    self.vm.inputs.viewDidLoad()

    XCTAssertEqual([
      "Find Friends View", "Viewed Find Friends",
      "Find Friends View", "Viewed Find Friends",
      "Find Friends View", "Viewed Find Friends",
      "Find Friends View", "Viewed Find Friends"
    ], self.trackingClient.events)

    XCTAssertEqual([
      "find-friends", "find-friends",
      "activity", "activity",
      "discovery", "discovery",
      "settings", "settings"
    ], self.trackingClient.properties.map { $0["source"] as! String? })
  }

  func testGoToDiscovery() {
    let params = DiscoveryParams.defaults
      |> DiscoveryParams.lens.social .~ true
      |> DiscoveryParams.lens.sort .~ .magic

    withEnvironment(currentUser: User.template) {
      vm.inputs.configureWith(source: FriendsSource.findFriends)
      vm.inputs.viewDidLoad()

      goToDiscovery.assertValueCount(0)

      vm.inputs.discoverButtonTapped()

      goToDiscovery.assertValues([params], "Go to Discovery emits with 'Friends Backed' params")
    }
  }

  func testFriends_WithFacebookConnectedUser() {
    withEnvironment(currentUser: User.template |> \.facebookConnected .~ true) {
      vm.inputs.configureWith(source: FriendsSource.activity)

      friends.assertValueCount(0, "Friends does not emit")
      showFacebookConnect.assertValueCount(0, "Facebook connect does not emit")

      vm.inputs.viewDidLoad()

      showLoadingIndicatorView.assertValues([true])

      self.scheduler.advance()

      showLoadingIndicatorView.assertValues([true, false])
      friends.assertValueCount(1, "Friends emit")
      showFacebookConnect.assertValues([false])

      vm.inputs.willDisplayRow(30, outOf: 10)

      showLoadingIndicatorView.assertValues([true, false])
      friends.assertValueCount(1, "Friends value has not changed")
      showFacebookConnect.assertValues([false], "Show Facebook Connect value has not changed")

      self.scheduler.advance()

      showLoadingIndicatorView.assertValues([true, false])
      friends.assertValueCount(2, "Friends emits again")
      showFacebookConnect.assertValues([false], "Show Facebook Connect value has not changed")
    }
  }

  func testFriends_WithNonFacebookConnectedUser() {
    withEnvironment(currentUser: User.template) {
      friends.assertValueCount(0, "Friends does not emit")
      showFacebookConnect.assertValueCount(0, "Facebook connect does not emit")

      vm.inputs.configureWith(source: FriendsSource.discovery)

      showFacebookConnect.assertValueCount(0, "Show Facebook Connect does not emit")

      vm.inputs.viewDidLoad()

      self.scheduler.advance()

      friends.assertValueCount(0, "Friends does not emit")
      showFacebookConnect.assertValues([true], "Show Facebook Connect")

      AppEnvironment.updateCurrentUser(User.template |> \.facebookConnected .~ true)
      vm.inputs.findFriendsFacebookConnectCellDidFacebookConnectUser()

      showLoadingIndicatorView.assertValues([true])

      self.scheduler.advance()

      showLoadingIndicatorView.assertValues([true, false])
      friends.assertValueCount(1, "Friends emit after Facebook Connected")
      showFacebookConnect.assertValues([true, false], "Hide Facebook Connect")

      vm.inputs.willDisplayRow(20, outOf: 10)

      showLoadingIndicatorView.assertValues([true, false])
      friends.assertValueCount(1, "Friends value has not changed")
      showFacebookConnect.assertValues([true, false], "Show Facebook Connect value has not changed")

      self.scheduler.advance()

      showLoadingIndicatorView.assertValues([true, false])
      friends.assertValueCount(2, "Friends emits again")
      showFacebookConnect.assertValues([true, false], "Show Facebook Connect value has not changed")
    }
  }

  func testFacebookConnectedUser_needsReconnect() {
    let needsReconnectUser = User.template
      |> \.facebookConnected .~ true
      |> \.needsFreshFacebookToken .~ true

    withEnvironment(currentUser: needsReconnectUser) {
      vm.inputs.configureWith(source: FriendsSource.findFriends)

      vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.showFacebookConnect.assertValues([true])
      self.stats.assertValueCount(0)
    }
  }

  func testStats_WithFacebookConnectedUser() {
    withEnvironment(currentUser: User.template |> \.facebookConnected .~ true) {
      vm.inputs.configureWith(source: FriendsSource.activity)

      stats.assertValueCount(0)
      statsSource.assertValueCount(0)

      vm.inputs.viewDidLoad()

      self.scheduler.advance()

      stats.assertValueCount(1)
      statsSource.assertValues([FriendsSource.activity])
    }
  }

  func testStats_WithNonFacebookConnectedUser() {
    withEnvironment(currentUser: User.template) {
      vm.inputs.configureWith(source: FriendsSource.activity)

      stats.assertValueCount(0)
      statsSource.assertValueCount(0)

      vm.inputs.viewDidLoad()

      self.scheduler.advance()

      stats.assertValueCount(0, "Stats should not emit if user isn't FB Connected")
      statsSource.assertValueCount(0)
    }
  }

  func testStats_WithNeedsReconnectUser() {
    let facebookConnectedNeedsReconnectUser = User.template
      |> \.facebookConnected .~ true
      |> \.needsFreshFacebookToken .~ true

    withEnvironment(currentUser: facebookConnectedNeedsReconnectUser) {
      vm.inputs.configureWith(source: FriendsSource.activity)

      stats.assertValueCount(0)
      statsSource.assertValueCount(0)

      vm.inputs.viewDidLoad()

      self.scheduler.advance()

      stats.assertValueCount(0, "Stats should not emit if needs facebook reconnect")
      statsSource.assertValueCount(0)
    }
  }

  func testFollowAllFriendsFlow() {
    let friendsResponse = FindFriendsEnvelope.template
    let user = User.template
      |> \.facebookConnected .~ true

    withEnvironment(apiService: MockService(fetchFriendsResponse: friendsResponse), currentUser: user) {
      self.vm.inputs.configureWith(source: FriendsSource.activity)
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.willDisplayRow(0, outOf: 2)

      self.scheduler.advance()

      self.friends.assertValues([friendsResponse.users], "Initial friends load.")
      XCTAssertEqual(["Find Friends View", "Viewed Find Friends"], self.trackingClient.events)
      XCTAssertEqual(
        ["activity", "activity"],
        self.trackingClient.properties.map { $0["source"] as! String? }
      )

      self.vm.inputs.findFriendsStatsCellShowFollowAllFriendsAlert(friendCount: 1_000)

      self.showFollowAllFriendsAlert.assertValues([1_000], "Show Follow All Friends alert with friend count")

      self.vm.inputs.declineFollowAllFriends()

      XCTAssertEqual(
        [
          "Find Friends View", "Viewed Find Friends",
          "Facebook Friend Decline Follow All", "Declined Follow All Facebook Friends"
        ],
        self.trackingClient.events
      )

      XCTAssertEqual(
        [
          "activity", "activity",
          "activity", "activity"
        ],
        self.trackingClient.properties.map { $0["source"] as! String? }
      )

      self.vm.inputs.findFriendsStatsCellShowFollowAllFriendsAlert(friendCount: 1_000)

      self.showFollowAllFriendsAlert.assertValues([1_000, 1_000])

      self.vm.inputs.confirmFollowAllFriends()

      XCTAssertEqual(
        [
          "Find Friends View", "Viewed Find Friends",
          "Facebook Friend Decline Follow All", "Declined Follow All Facebook Friends",
          "Facebook Friend Follow All", "Followed All Facebook Friends"
        ], self.trackingClient.events
      )
      XCTAssertEqual(
        [
          "activity", "activity",
          "activity", "activity",
          "activity", "activity"
        ],
        self.trackingClient.properties.map { $0["source"] as! String? }
      )

      // Test the 2 second "Follow all" debounce.
      self.scheduler.advance(by: .seconds(1))

      self.friends.assertValues([friendsResponse.users, []], "Friend list clears.")

      self.scheduler.advance(by: .seconds(1))

      self.friends.assertValues([friendsResponse.users, [], friendsResponse.users], "Updated friends emit.")
    }
  }

  func testLoaderIsAnimating_WithFacebookConnectedUser() {
    withEnvironment(currentUser: User.template |> \.facebookConnected .~ true) {
      vm.inputs.configureWith(source: FriendsSource.activity)

      showLoadingIndicatorView.assertValueCount(0, "Loader is hidden")

      vm.inputs.viewDidLoad()

      showLoadingIndicatorView.assertValues([true])

      self.scheduler.advance()

      showLoadingIndicatorView.assertValues([true, false])

      vm.inputs.willDisplayRow(30, outOf: 10)

      showLoadingIndicatorView.assertValues([true, false])

      self.scheduler.advance()

      showLoadingIndicatorView.assertValues([true, false])
    }
  }

  func testLoadedMoreFriendsReporting() {
    withEnvironment(currentUser: .template |> \.facebookConnected .~ true) {
      self.vm.inputs.configureWith(source: FriendsSource.activity)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      // This call should NOT trigger next page request and reporting
      self.vm.inputs.willDisplayRow(5, outOf: 10)
      self.scheduler.advance()

      XCTAssertEqual(
        ["Find Friends View", "Viewed Find Friends"], self.trackingClient.events
      )

      XCTAssertEqual(
        ["activity", "activity"],
        self.trackingClient.properties.map { $0["source"] as! String? }
      )

      XCTAssertEqual(
        [nil, nil],
        self.trackingClient.properties.map { $0["page_count"] as! String? }
      )

      // This call should trigger next page request and reporting
      self.vm.inputs.willDisplayRow(8, outOf: 10)
      self.scheduler.advance()

      XCTAssertEqual(
        ["Find Friends View", "Viewed Find Friends", "Loaded More Friends"], self.trackingClient.events
      )

      XCTAssertEqual(
        ["activity", "activity", "activity"],
        self.trackingClient.properties.map { $0["source"] as! String? }
      )

      XCTAssertEqual(
        [nil, nil, 2],
        self.trackingClient.properties.map { $0["page_count"] as! Int? }
      )
    }
  }

  func testLoaderIsAnimating_WithNonFacebookConnectedUser() {
    withEnvironment(currentUser: User.template) {
      vm.inputs.configureWith(source: FriendsSource.activity)

      showLoadingIndicatorView.assertValueCount(0, "Loader is hidden")

      vm.inputs.viewDidLoad()

      showLoadingIndicatorView.assertDidNotEmitValue()

      self.scheduler.advance()

      showLoadingIndicatorView.assertDidNotEmitValue()
    }
  }

  func testFacebookErrorAlerts() {
    self.vm.inputs.configureWith(source: FriendsSource.discovery)

    self.showFacebookConnect.assertValueCount(0, "Show Facebook Connect does not emit")

    self.vm.inputs.viewDidLoad()

    self.scheduler.advance()

    self.showFacebookConnect.assertValues([true], "Show Facebook Connect")

    let alertTokenFail = AlertError.facebookTokenFail

    self.vm.inputs.findFriendsFacebookConnectCellShowErrorAlert(alertTokenFail)

    self.showErrorAlert.assertValues([alertTokenFail])

    let errorAccountTaken = ErrorEnvelope(
      errorMessages: ["This Facebook account is already linked to another Kickstarter user."],
      ksrCode: .FacebookConnectAccountTaken,
      httpCode: 403,
      exception: nil
    )

    let alertAccountTaken = AlertError.facebookConnectAccountTaken(envelope: errorAccountTaken)

    self.vm.inputs.findFriendsFacebookConnectCellShowErrorAlert(alertAccountTaken)

    self.showErrorAlert.assertValues([alertTokenFail, alertAccountTaken])

    let errorEmailTaken = ErrorEnvelope(
      errorMessages: [
        "The email associated with this Facebook account is already registered to another Kickstarter user."
      ],
      ksrCode: .FacebookConnectEmailTaken,
      httpCode: 403,
      exception: nil
    )

    let alertEmailTaken = AlertError.facebookConnectEmailTaken(envelope: errorEmailTaken)

    self.vm.inputs.findFriendsFacebookConnectCellShowErrorAlert(alertEmailTaken)

    self.showErrorAlert.assertValues([alertTokenFail, alertAccountTaken, alertEmailTaken])
  }
}
