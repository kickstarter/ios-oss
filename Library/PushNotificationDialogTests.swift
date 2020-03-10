@testable import KsApi
@testable import Library
import XCTest

class PushNotificationDialogTests: XCTestCase {
  let userDefaults = MockKeyValueStore()

  func testTitleForDismissalIs_NotNow_WhenUserDeniedLessThanTwoTimes() {
    withEnvironment(userDefaults: self.userDefaults) {
      PushNotificationDialog.didDenyAccess(for: .save)

      XCTAssertEqual(PushNotificationDialog.titleForDismissal, "Not Now")
    }
  }

  func testTitleForDismissalIs_Never_WhenUserDeniedTwoTimes() {
    withEnvironment(userDefaults: self.userDefaults) {
      PushNotificationDialog.didDenyAccess(for: .login)
      PushNotificationDialog.didDenyAccess(for: .save)

      XCTAssertEqual(PushNotificationDialog.titleForDismissal, "Never")
    }
  }

  func testCanShowDialogIf_UserHasNeverDeniedForContext() {
    withEnvironment(userDefaults: self.userDefaults) {
      PushNotificationDialog.didDenyAccess(for: .save)

      XCTAssertTrue(PushNotificationDialog.canShowDialog(for: .message))
    }
  }

  func testCanNotShowDialogIf_UserDeniedForContext() {
    withEnvironment(userDefaults: self.userDefaults) {
      PushNotificationDialog.didDenyAccess(for: .save)

      XCTAssertFalse(PushNotificationDialog.canShowDialog(for: .save))
    }
  }

  func testCanShowDialogIf_UserDeniedLessThanThreeTimes() {
    withEnvironment(userDefaults: self.userDefaults) {
      PushNotificationDialog.didDenyAccess(for: .save)
      PushNotificationDialog.didDenyAccess(for: .message)

      XCTAssertTrue(PushNotificationDialog.canShowDialog(for: .pledge))
    }
  }

  func testCanNotShowDialogIf_UserDeniedThreeTimes() {
    withEnvironment(userDefaults: self.userDefaults) {
      PushNotificationDialog.didDenyAccess(for: .save)
      PushNotificationDialog.didDenyAccess(for: .message)
      PushNotificationDialog.didDenyAccess(for: .login)

      XCTAssertFalse(PushNotificationDialog.canShowDialog(for: .pledge))
    }
  }

  func testContextIsAddedToUserDefaults_AfterDenial() {
    withEnvironment(userDefaults: self.userDefaults) {
      PushNotificationDialog.didDenyAccess(for: .login)
      XCTAssertEqual(["login"], userDefaults.deniedNotificationContexts)

      PushNotificationDialog.didDenyAccess(for: .save)
      XCTAssertEqual(["login", "save"], userDefaults.deniedNotificationContexts)
    }
  }

  func testContextsReset_AfterLogout() {
    withEnvironment(userDefaults: self.userDefaults) {
      PushNotificationDialog.didDenyAccess(for: .login)
      PushNotificationDialog.didDenyAccess(for: .save)
      PushNotificationDialog.didDenyAccess(for: .message)
      PushNotificationDialog.didDenyAccess(for: .pledge)

      XCTAssertEqual(["login", "save", "message", "pledge"], userDefaults.deniedNotificationContexts)

      PushNotificationDialog.resetAllContexts()
      XCTAssertEqual([], userDefaults.deniedNotificationContexts)
    }
  }
}
