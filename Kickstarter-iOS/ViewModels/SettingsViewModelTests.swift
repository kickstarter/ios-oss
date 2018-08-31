import Prelude
import XCTest
import Result
@testable import KsApi
@testable import Kickstarter_Framework
@testable import ReactiveExtensions_TestHelpers

internal final class SettingsViewModelTests: TestCase {
  let vm = SettingsViewModel()

  let goToAppStoreRating = TestObserver<String, NoError>()
  let logout = TestObserver<DiscoveryParams, NoError>()
  let reloadDataWithUserObserver = TestObserver<User, NoError>()
  let showConfirmLogout = TestObserver<Void, NoError>()
  let transitionToViewController = TestObserver<UIViewController, NoError>()

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.goToAppStoreRating.observe(goToAppStoreRating.observer)
    self.vm.outputs.logoutWithParams.observe(logout.observer)
    self.vm.outputs.reloadDataWithUser.observe(reloadDataWithUserObserver.observer)
    self.vm.outputs.showConfirmLogoutPrompt.signal.mapConst(()).observe(showConfirmLogout.observer)
    self.vm.outputs.transitionToViewController.observe(transitionToViewController.observer)
  }

  func testViewDidLoad() {
    let mockService = MockService(fetchUserSelfResponse: User.template)

    withEnvironment(apiService: mockService, currentUser: User.template) {
      self.vm.viewDidLoad()

      self.reloadDataWithUserObserver.assertValueCount(2)
    }
  }

  func testLogoutCellTapped() {
    self.showConfirmLogout.assertValueCount(0)
    self.logout.assertValueCount(0)
    self.vm.settingsCellTapped(cellType: .logout)

    self.showConfirmLogout.assertValueCount(1, "Shows confirm logout alert.")

    self.vm.inputs.logoutCanceled()

    self.logout.assertValueCount(0, "Logout cancelled")

    self.vm.settingsCellTapped(cellType: .logout)

    self.showConfirmLogout.assertValueCount(2, "Show confirm logout alert")
    self.vm.inputs.logoutConfirmed()

    self.logout.assertValueCount(1, "Log out triggered")
  }

  func testNotificationsCellTapped() {
    self.vm.inputs.viewDidLoad()
    self.transitionToViewController.assertValueCount(0)
    self.vm.settingsCellTapped(cellType: .notifications)
    self.transitionToViewController.assertValueCount(1)
  }

  func testNewslettersCellTapped() {
    self.vm.inputs.viewDidLoad()
    self.transitionToViewController.assertValueCount(0)
    self.vm.settingsCellTapped(cellType: .newsletters)
    self.transitionToViewController.assertValueCount(1)
  }

  func testCellSelection() {
    XCTAssertFalse(self.vm.shouldSelectRow(for: .appVersion))
    XCTAssertTrue(self.vm.shouldSelectRow(for: .newsletters))
  }

  func testShouldSelectRow_findFriends_FollowingEnabled() {
    let user = User.template |> User.lens.social .~ true

    withEnvironment(currentUser: user) {
      XCTAssertTrue(self.vm.shouldSelectRow(for: .findFriends))
    }
  }

  func testShouldSelectRow_findFriends_FollowingDisabled() {
    let user = User.template |> User.lens.social .~ false

    withEnvironment(currentUser: user) {
      XCTAssertFalse(self.vm.shouldSelectRow(for: .findFriends))
    }
  }

  func testAppStoreRatingCellTapped() {
    self.goToAppStoreRating.assertValueCount(0)
    self.vm.settingsCellTapped(cellType: .rateInAppStore)
    self.goToAppStoreRating.assertValueCount(1, "Opens app store url")
  }

  func testUserUpdatedNotification() {
    let updatedUser = User.template |> User.lens.social .~ true
    let mockService = MockService(fetchUserSelfResponse: updatedUser)

    withEnvironment(apiService: mockService, currentUser: User.template) {
      self.vm.currentUserUpdated()

      self.scheduler.advance()

      self.reloadDataWithUserObserver.assertValueCount(2)
    }
  }
}
