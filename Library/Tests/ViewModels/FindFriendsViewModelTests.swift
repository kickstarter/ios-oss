import XCTest
import ReactiveSwift
import UIKit.UIActivity
@testable import ReactiveExtensions
@testable import ReactiveExtensions_TestHelpers
@testable import Result
@testable import KsApi
@testable import Library
import Prelude

final class FindFriendsViewModelTests: TestCase {
  let vm: FindFriendsViewModelType = FindFriendsViewModel()

  let friends = TestObserver<[User], NoError>()
  let goToDiscovery = TestObserver<DiscoveryParams, NoError>()
  let showErrorAlert = TestObserver<AlertError, NoError>()
  let showFacebookConnect = TestObserver<Bool, NoError>()
  let showFollowAllFriendsAlert = TestObserver<Int, NoError>()
  let showLoadingIndicatorView = TestObserver<Bool, NoError>()
  let stats = TestObserver<FriendStatsEnvelope, NoError>()
  let statsSource = TestObserver<FriendsSource, NoError>()

  override func setUp() {
    super.setUp()

    vm.outputs.friends.map { $0.0 }.observe(friends.observer)
    vm.outputs.goToDiscovery.observe(goToDiscovery.observer)
    vm.outputs.showErrorAlert.observe(showErrorAlert.observer)
    vm.outputs.showFacebookConnect.map { $0.1 }.observe(showFacebookConnect.observer)
    vm.outputs.showFollowAllFriendsAlert.observe(showFollowAllFriendsAlert.observer)
    vm.outputs.showLoadingIndicatorView.observe(showLoadingIndicatorView.observer)
    vm.outputs.stats.map { env, _ in env }.observe(stats.observer)
    vm.outputs.stats.map { _, source in source }.observe(statsSource.observer)
  }

  func testSource() {
    vm.inputs.configureWith(source: FriendsSource.findFriends)
    vm.inputs.viewDidLoad()

    XCTAssertEqual(["Find Friends View"], self.trackingClient.events)
    XCTAssertEqual(["find-friends"], self.trackingClient.properties.map { $0["source"] as! String? })

    vm.inputs.configureWith(source: FriendsSource.activity)
    vm.inputs.viewDidLoad()

    XCTAssertEqual(["Find Friends View", "Find Friends View"], self.trackingClient.events)
    XCTAssertEqual(["find-friends", "activity"],
                   self.trackingClient.properties.map { $0["source"] as! String? })

    vm.inputs.configureWith(source: FriendsSource.discovery)
    vm.inputs.viewDidLoad()

    XCTAssertEqual(["Find Friends View", "Find Friends View", "Find Friends View"],
                   self.trackingClient.events)
    XCTAssertEqual(["find-friends", "activity", "discovery"],
                   self.trackingClient.properties.map { $0["source"] as! String? })

    vm.inputs.configureWith(source: FriendsSource.settings)
    vm.inputs.viewDidLoad()

    XCTAssertEqual(["Find Friends View", "Find Friends View", "Find Friends View", "Find Friends View"],
                   self.trackingClient.events)
    XCTAssertEqual(["find-friends", "activity", "discovery", "settings"],
                   self.trackingClient.properties.map { $0["source"] as! String? })
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
    withEnvironment(currentUser: User.template |> User.lens.facebookConnected .~ true) {
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

      AppEnvironment.updateCurrentUser(User.template |> User.lens.facebookConnected .~ true)
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

  func testStats_WithFacebookConnectedUser() {
    withEnvironment(currentUser: User.template |> User.lens.facebookConnected .~ true) {
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

  func testFollowAllFriendsFlow() {
    let friendsResponse = FindFriendsEnvelope.template
    let user = .template
      |> User.lens.facebookConnected .~ true

    withEnvironment(apiService: MockService(fetchFriendsResponse: friendsResponse), currentUser: user) {
      self.vm.inputs.configureWith(source: FriendsSource.activity)
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.willDisplayRow(0, outOf: 2)

      self.scheduler.advance()

      self.friends.assertValues([friendsResponse.users], "Initial friends load.")
      XCTAssertEqual(["Find Friends View"], self.trackingClient.events)
      XCTAssertEqual(["activity"], self.trackingClient.properties.map { $0["source"] as! String? })

      self.vm.inputs.findFriendsStatsCellShowFollowAllFriendsAlert(friendCount: 1000)

      self.showFollowAllFriendsAlert.assertValues([1000], "Show Follow All Friends alert with friend count")

      self.vm.inputs.declineFollowAllFriends()

      XCTAssertEqual(["Find Friends View", "Facebook Friend Decline Follow All"], self.trackingClient.events)
      XCTAssertEqual(["activity", "activity"],
                     self.trackingClient.properties.map { $0["source"] as! String? })

      self.vm.inputs.findFriendsStatsCellShowFollowAllFriendsAlert(friendCount: 1000)

      self.showFollowAllFriendsAlert.assertValues([1000, 1000])

      self.vm.inputs.confirmFollowAllFriends()

      XCTAssertEqual(
        ["Find Friends View", "Facebook Friend Decline Follow All", "Facebook Friend Follow All"],
        self.trackingClient.events
      )
      XCTAssertEqual(["activity", "activity", "activity"],
                     self.trackingClient.properties.map { $0["source"] as! String? })

      // Test the 2 second "Follow all" debounce.
      self.scheduler.advance(by: .seconds(1))

      self.friends.assertValues([friendsResponse.users, []], "Friend list clears.")

      self.scheduler.advance(by: .seconds(1))

      self.friends.assertValues([friendsResponse.users, [], friendsResponse.users], "Updated friends emit.")
    }
  }

  func testLoaderIsAnimating_WithFacebookConnectedUser() {
    withEnvironment(currentUser: User.template |> User.lens.facebookConnected .~ true) {
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
    vm.inputs.configureWith(source: FriendsSource.discovery)

    showFacebookConnect.assertValueCount(0, "Show Facebook Connect does not emit")

    vm.inputs.viewDidLoad()

    self.scheduler.advance()

    showFacebookConnect.assertValues([true], "Show Facebook Connect")

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
