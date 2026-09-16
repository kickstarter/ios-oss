@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
@testable import LibraryTestHelpers
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import UIKit
import XCTest

/// Exercises the shared deep-link router directly rather than through `AppDelegateViewModel` or
/// `SceneDelegateViewModel`. Those two feed it from different sources — push/Braze and
/// URL/user-activity/shortcut respectively — so pinning the routing contract here keeps it from
/// drifting when either of them changes.
final class DeepLinkNavigationRouterTests: TestCase {
  private var deepLinkObserver: Signal<Navigation, Never>.Observer!

  private let goToActivity = TestObserver<(), Never>()
  private let goToDiscovery = TestObserver<DiscoveryParams?, Never>()
  private let goToLoginWithIntent = TestObserver<LoginIntent, Never>()
  private let goToMessageThread = TestObserver<MessageThread, Never>()
  private let goToProfile = TestObserver<(), Never>()
  private let goToSearch = TestObserver<(), Never>()
  private let presentViewControllerCount = TestObserver<Int, Never>()
  private let updateCurrentUserInEnvironment = TestObserver<User, Never>()

  override func setUp() {
    super.setUp()

    let (deepLink, observer) = Signal<Navigation, Never>.pipe()
    self.deepLinkObserver = observer

    let outputs = DeepLinkNavigationRouter(deepLink: deepLink)

    outputs.goToActivity.observe(self.goToActivity.observer)
    outputs.goToDiscovery.observe(self.goToDiscovery.observer)
    outputs.goToLoginWithIntent.observe(self.goToLoginWithIntent.observer)
    outputs.goToMessageThread.observe(self.goToMessageThread.observer)
    outputs.goToProfile.observe(self.goToProfile.observer)
    outputs.goToSearch.observe(self.goToSearch.observer)
    outputs.presentViewController
      .map { ($0 as? UINavigationController)?.viewControllers.count ?? 0 }
      .observe(self.presentViewControllerCount.observer)
    outputs.updateCurrentUserInEnvironment.observe(self.updateCurrentUserInEnvironment.observer)
  }

  private func send(_ navigation: Navigation) {
    self.deepLinkObserver.send(value: navigation)
  }

  // MARK: - Tabs

  func testGoToActivity() {
    self.goToActivity.assertValueCount(0)

    self.send(.tab(.activity))

    self.goToActivity.assertValueCount(1)
    self.goToSearch.assertValueCount(0)
    self.goToProfile.assertValueCount(0)
  }

  func testGoToSearch() {
    self.goToSearch.assertValueCount(0)

    self.send(.tab(.search))

    self.goToSearch.assertValueCount(1)
    self.goToActivity.assertValueCount(0)
  }

  func testGoToProfile() {
    self.goToProfile.assertValueCount(0)

    self.send(.tab(.me))

    self.goToProfile.assertValueCount(1)
    self.goToActivity.assertValueCount(0)
  }

  func testGoToDiscovery_WithParams() {
    self.goToDiscovery.assertValues([])

    self.send(.tab(.discovery(["sort": "newest"])))

    let params = .defaults
      |> DiscoveryParams.lens.sort .~ .newest
    self.goToDiscovery.assertValues([params])
  }

  func testGoToDiscovery_NoParams() {
    self.goToDiscovery.assertValues([])

    self.send(.tab(.discovery(nil)))

    self.goToDiscovery.assertValueCount(1)
    XCTAssertNil(self.goToDiscovery.lastValue ?? nil, "Emits nil params for a bare discovery link.")
  }

  // MARK: - Login

  func testGoToLogin_EmitsGenericIntent() {
    self.goToLoginWithIntent.assertDidNotEmitValue()

    self.send(.tab(.login))

    self.goToLoginWithIntent.assertValues([.generic])
  }

  func testErroredPledge_LoggedOut_EmitsErroredPledgeIntent() {
    withEnvironment(apiService: MockService(fetchProjectResult: .success(.template)), currentUser: nil) {
      self.goToLoginWithIntent.assertDidNotEmitValue()

      self.send(.project(.slug("a-project"), .pledge(.manage), refInfo: nil))

      self.goToLoginWithIntent.assertValues([.erroredPledge])
    }
  }

  func testErroredPledge_LoggedIn_DoesNotEmitLoginIntent() {
    withEnvironment(
      apiService: MockService(fetchProjectResult: .success(.template)),
      currentUser: .template
    ) {
      self.send(.project(.slug("a-project"), .pledge(.manage), refInfo: nil))

      self.goToLoginWithIntent.assertDidNotEmitValue(
        "A logged-in backer goes straight to manage pledge instead of logging in."
      )
    }
  }

  // MARK: - Message threads

  func testGoToMessageThread() {
    withEnvironment(apiService: MockService()) {
      self.goToMessageThread.assertDidNotEmitValue()

      self.send(.messages(messageThreadId: 1))

      self.goToMessageThread.assertValueCount(1)
    }
  }

  // MARK: - Presented view controllers

  func testPresentViewController_ProjectRoot() {
    withEnvironment(apiService: MockService(fetchProjectResult: .success(.template))) {
      self.presentViewControllerCount.assertValues([])

      self.send(.project(.slug("a-project"), .root, refInfo: nil))

      self.presentViewControllerCount.assertValues([1], "Presents the project page on its own.")
    }
  }

  func testPresentViewController_ProjectComments() {
    withEnvironment(apiService: MockService(fetchProjectResult: .success(.template))) {
      self.send(.project(.slug("a-project"), .comments, refInfo: nil))

      self.presentViewControllerCount.assertValues([2], "Stacks comments on top of the project page.")
    }
  }

  // MARK: - Notification settings

  func testUpdateCurrentUserInEnvironment_NotificationSettings() {
    withEnvironment(apiService: MockService()) {
      let user = User.template
        |> User.lens.notifications.mobileMessages .~ false
      AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: user))

      self.updateCurrentUserInEnvironment.assertDidNotEmitValue()

      self.send(.settings(.notifications("notify_mobile_of_messages", true)))

      self.updateCurrentUserInEnvironment.assertDidNotEmitValue("Waits on the API call.")

      self.scheduler.advance()

      let updatedUser = user
        |> User.lens.notifications.mobileMessages .~ true
      self.updateCurrentUserInEnvironment.assertValues([updatedUser])
    }
  }

  func testUpdateCurrentUserInEnvironment_NotificationSettings_LoggedOut() {
    withEnvironment(apiService: MockService(), currentUser: nil) {
      self.send(.settings(.notifications("notify_mobile_of_messages", true)))

      self.scheduler.advance()

      self.updateCurrentUserInEnvironment.assertDidNotEmitValue(
        "There is no user to update when logged out."
      )
    }
  }

  // MARK: - Navigations the router doesn't handle

  func testUnroutedNavigation_EmitsNothing() {
    self.send(.emailClick)

    self.scheduler.advance()

    self.goToActivity.assertValueCount(0)
    self.goToDiscovery.assertValues([])
    self.goToLoginWithIntent.assertDidNotEmitValue()
    self.goToMessageThread.assertDidNotEmitValue()
    self.goToProfile.assertValueCount(0)
    self.goToSearch.assertValueCount(0)
    self.presentViewControllerCount.assertValues([])
    self.updateCurrentUserInEnvironment.assertDidNotEmitValue()
  }
}
