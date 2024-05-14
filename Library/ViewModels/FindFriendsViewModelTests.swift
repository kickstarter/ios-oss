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

    self.vm.inputs.configureWith(source: FriendsSource.discovery)
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.configureWith(source: FriendsSource.settings)
    self.vm.inputs.viewDidLoad()
  }

  func testGoToDiscovery() {
    let params = DiscoveryParams.defaults
      |> DiscoveryParams.lens.social .~ true
      |> DiscoveryParams.lens.sort .~ .magic

    withEnvironment(currentUser: User.template) {
      self.vm.inputs.configureWith(source: FriendsSource.findFriends)
      self.vm.inputs.viewDidLoad()

      self.goToDiscovery.assertValueCount(0)

      self.vm.inputs.discoverButtonTapped()

      self.goToDiscovery.assertValues([params], "Go to Discovery emits with 'Friends Backed' params")
    }
  }

  func testFriends_WithFacebookConnectedUser() {
    withEnvironment(currentUser: User.template |> \.facebookConnected .~ true) {
      self.vm.inputs.configureWith(source: FriendsSource.settings)

      self.friends.assertValueCount(0, "Friends does not emit")
      self.showFacebookConnect.assertValueCount(0, "Facebook connect does not emit")

      self.vm.inputs.viewDidLoad()

      self.showLoadingIndicatorView.assertValues([true])

      self.scheduler.advance()

      self.showLoadingIndicatorView.assertValues([true, false])
      self.friends.assertValueCount(1, "Friends emit")
      self.showFacebookConnect.assertValues([false])

      self.vm.inputs.willDisplayRow(30, outOf: 10)

      self.showLoadingIndicatorView.assertValues([true, false])
      self.friends.assertValueCount(1, "Friends value has not changed")
      self.showFacebookConnect.assertValues([false], "Show Facebook Connect value has not changed")

      self.scheduler.advance()

      self.showLoadingIndicatorView.assertValues([true, false])
      self.friends.assertValueCount(2, "Friends emits again")
      self.showFacebookConnect.assertValues([false], "Show Facebook Connect value has not changed")
    }
  }

  func testFriends_WithNonFacebookConnectedUser() {
    withEnvironment(currentUser: User.template) {
      self.friends.assertValueCount(0, "Friends does not emit")
      self.showFacebookConnect.assertValueCount(0, "Facebook connect does not emit")

      self.vm.inputs.configureWith(source: FriendsSource.discovery)

      self.showFacebookConnect.assertValueCount(0, "Show Facebook Connect does not emit")

      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.friends.assertValueCount(0, "Friends does not emit")
      self.showFacebookConnect.assertValues([true], "Show Facebook Connect")

      AppEnvironment.updateCurrentUser(User.template |> \.facebookConnected .~ true)
      self.vm.inputs.findFriendsFacebookConnectCellDidFacebookConnectUser()

      self.showLoadingIndicatorView.assertValues([true])

      self.scheduler.advance()

      self.showLoadingIndicatorView.assertValues([true, false])
      self.friends.assertValueCount(1, "Friends emit after Facebook Connected")
      self.showFacebookConnect.assertValues([true, false], "Hide Facebook Connect")

      self.vm.inputs.willDisplayRow(20, outOf: 10)

      self.showLoadingIndicatorView.assertValues([true, false])
      self.friends.assertValueCount(1, "Friends value has not changed")
      self.showFacebookConnect.assertValues([true, false], "Show Facebook Connect value has not changed")

      self.scheduler.advance()

      self.showLoadingIndicatorView.assertValues([true, false])
      self.friends.assertValueCount(2, "Friends emits again")
      self.showFacebookConnect.assertValues([true, false], "Show Facebook Connect value has not changed")
    }
  }

  func testFacebookConnectedUser_needsReconnect() {
    let needsReconnectUser = User.template
      |> \.facebookConnected .~ true
      |> \.needsFreshFacebookToken .~ true

    withEnvironment(currentUser: needsReconnectUser) {
      self.vm.inputs.configureWith(source: FriendsSource.findFriends)

      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.showFacebookConnect.assertValues([true])
      self.stats.assertValueCount(0)
    }
  }

  func testStats_WithFacebookConnectedUser() {
    withEnvironment(currentUser: User.template |> \.facebookConnected .~ true) {
      self.vm.inputs.configureWith(source: FriendsSource.settings)

      self.stats.assertValueCount(0)
      self.statsSource.assertValueCount(0)

      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.stats.assertValueCount(1)
      self.statsSource.assertValues([FriendsSource.settings])
    }
  }

  func testStats_WithNonFacebookConnectedUser() {
    withEnvironment(currentUser: User.template) {
      self.vm.inputs.configureWith(source: FriendsSource.settings)

      self.stats.assertValueCount(0)
      self.statsSource.assertValueCount(0)

      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.stats.assertValueCount(0, "Stats should not emit if user isn't FB Connected")
      self.statsSource.assertValueCount(0)
    }
  }

  func testStats_WithNeedsReconnectUser() {
    let facebookConnectedNeedsReconnectUser = User.template
      |> \.facebookConnected .~ true
      |> \.needsFreshFacebookToken .~ true

    withEnvironment(currentUser: facebookConnectedNeedsReconnectUser) {
      self.vm.inputs.configureWith(source: FriendsSource.settings)

      self.stats.assertValueCount(0)
      self.statsSource.assertValueCount(0)

      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.stats.assertValueCount(0, "Stats should not emit if needs facebook reconnect")
      self.statsSource.assertValueCount(0)
    }
  }

  func testFollowAllFriendsFlow() {
    let friendsResponse = FindFriendsEnvelope.template
    let user = User.template
      |> \.facebookConnected .~ true

    withEnvironment(apiService: MockService(fetchFriendsResponse: friendsResponse), currentUser: user) {
      self.vm.inputs.configureWith(source: FriendsSource.settings)
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.willDisplayRow(0, outOf: 2)

      self.scheduler.advance()

      self.friends.assertValues([friendsResponse.users], "Initial friends load.")

      self.vm.inputs.findFriendsStatsCellShowFollowAllFriendsAlert(friendCount: 1_000)

      self.showFollowAllFriendsAlert.assertValues([1_000], "Show Follow All Friends alert with friend count")

      self.vm.inputs.findFriendsStatsCellShowFollowAllFriendsAlert(friendCount: 1_000)

      self.showFollowAllFriendsAlert.assertValues([1_000, 1_000])

      self.vm.inputs.confirmFollowAllFriends()

      // Test the 2 second "Follow all" debounce.
      self.scheduler.advance(by: .seconds(1))

      self.friends.assertValues([friendsResponse.users, []], "Friend list clears.")

      self.scheduler.advance(by: .seconds(1))

      self.friends.assertValues([friendsResponse.users, [], friendsResponse.users], "Updated friends emit.")
    }
  }

  func testLoaderIsAnimating_WithFacebookConnectedUser() {
    withEnvironment(currentUser: User.template |> \.facebookConnected .~ true) {
      self.vm.inputs.configureWith(source: FriendsSource.settings)

      self.showLoadingIndicatorView.assertValueCount(0, "Loader is hidden")

      self.vm.inputs.viewDidLoad()

      self.showLoadingIndicatorView.assertValues([true])

      self.scheduler.advance()

      self.showLoadingIndicatorView.assertValues([true, false])

      self.vm.inputs.willDisplayRow(30, outOf: 10)

      self.showLoadingIndicatorView.assertValues([true, false])

      self.scheduler.advance()

      self.showLoadingIndicatorView.assertValues([true, false])
    }
  }

  func testLoadedMoreFriendsReporting() {
    withEnvironment(currentUser: .template |> \.facebookConnected .~ true) {
      self.vm.inputs.configureWith(source: FriendsSource.settings)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      // This call should NOT trigger next page request and reporting
      self.vm.inputs.willDisplayRow(5, outOf: 10)
      self.scheduler.advance()

      // This call should trigger next page request and reporting
      self.vm.inputs.willDisplayRow(8, outOf: 10)
      self.scheduler.advance()
    }
  }

  func testLoaderIsAnimating_WithNonFacebookConnectedUser() {
    withEnvironment(currentUser: User.template) {
      self.vm.inputs.configureWith(source: FriendsSource.settings)

      self.showLoadingIndicatorView.assertValueCount(0, "Loader is hidden")

      self.vm.inputs.viewDidLoad()

      self.showLoadingIndicatorView.assertDidNotEmitValue()

      self.scheduler.advance()

      self.showLoadingIndicatorView.assertDidNotEmitValue()
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
