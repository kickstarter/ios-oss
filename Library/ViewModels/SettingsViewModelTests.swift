import Prelude
import XCTest
import Result
@testable import KsApi
@testable import Library
@testable import Kickstarter_Framework
import ReactiveExtensions_TestHelpers

internal final class SettingsViewModelTests: TestCase {
  let vm = SettingsViewModel(SettingsViewController.viewController(for:))

  private let findFriendsDisabled = TestObserver<Bool, NoError>()
  private let goToAppStoreRating = TestObserver<String, NoError>()
  private let logout = TestObserver<DiscoveryParams, NoError>()
  private let reloadDataWithUser = TestObserver<User, NoError>()
  private let showConfirmLogout = TestObserver<Void, NoError>()
  private let transitionToViewController = TestObserver<UIViewController, NoError>()

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.findFriendsDisabledProperty.signal.observe(findFriendsDisabled.observer)
    self.vm.outputs.goToAppStoreRating.observe(goToAppStoreRating.observer)
    self.vm.outputs.logoutWithParams.observe(logout.observer)
    self.vm.outputs.reloadDataWithUser.observe(reloadDataWithUser.observer)
    self.vm.outputs.showConfirmLogoutPrompt.signal.mapConst(()).observe(showConfirmLogout.observer)
    self.vm.outputs.transitionToViewController.observe(transitionToViewController.observer)
  }

  func testViewDidLoad_withSocialEnabledUser() {
    let user = User.template |> \.social .~ true
    let mockService = MockService(fetchUserSelfResponse: user)

    withEnvironment(apiService: mockService, currentUser: user) {
      self.vm.viewDidLoad()

      self.reloadDataWithUser.assertValueCount(2)
      self.findFriendsDisabled.assertValues([false, false])
    }
  }

  func testViewDidLoad_withSocialDisabledUser() {
    let user = User.template |> \.social .~ false
    let mockService = MockService(fetchUserSelfResponse: user)

    withEnvironment(apiService: mockService, currentUser: user) {
      self.vm.viewDidLoad()

      self.reloadDataWithUser.assertValueCount(2)
      self.findFriendsDisabled.assertValues([true, true])
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
    XCTAssertTrue(self.vm.shouldSelectRow(for: .newsletters))
  }

  func testShouldSelectRow_findFriends_FollowingEnabled() {
    let user = User.template |> \.social .~ true

    withEnvironment(currentUser: user) {
      XCTAssertTrue(self.vm.shouldSelectRow(for: .findFriends))
    }
  }

  func testShouldSelectRow_findFriends_FollowingDisabled() {
    let user = User.template |> \.social .~ false

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
    let storedUser = User.template |> \.social .~ false
    let updatedUser = User.template |> \.social .~ true
    let mockService = MockService(fetchUserSelfResponse: updatedUser)

    withEnvironment(apiService: mockService, currentUser: storedUser) {
      self.vm.currentUserUpdated()

      self.scheduler.advance()

      self.reloadDataWithUser.assertValueCount(2)
      self.findFriendsDisabled.assertValues([true, false])
    }
  }
}
