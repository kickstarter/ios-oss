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
    self.vm.viewDidLoad()

    self.reloadDataWithUserObserver.assertValueCount(1)
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

  func testAppStoreRatingCellTapped() {
    self.goToAppStoreRating.assertValueCount(0)
    self.vm.settingsCellTapped(cellType: .rateInAppStore)
    self.goToAppStoreRating.assertValueCount(1, "Opens app store url")
  }
}
