import XCTest
@testable import Library
@testable import KsApi

class PushNotificationdialogTests: XCTestCase {

  let userDefaults = MockKeyValueStore()

  func testTitleForDismissalIs_NotNow_WhenUserDeniedLessThanTwoTimes() {

    withEnvironment(userDefaults: userDefaults) {

      PushNotificationDialog.didDenyAccess(for: .save)

      XCTAssertEqual(PushNotificationDialog.titleForDismissal, "Not Now")
    }
  }

  func testTitleForDismissalIs_Never_WhenUserDeniedTwoTimes() {

    withEnvironment(userDefaults: userDefaults) {

      PushNotificationDialog.didDenyAccess(for: .login)
      PushNotificationDialog.didDenyAccess(for: .save)

      XCTAssertEqual(PushNotificationDialog.titleForDismissal, "Never")
    }
  }

  func testCanShowDialogIf_UserHasNeverDeniedForContext() {

    withEnvironment(userDefaults: userDefaults) {

      PushNotificationDialog.didDenyAccess(for: .save)

      XCTAssertTrue(PushNotificationDialog.canShowDialog(for: .message))
    }
  }

  func testCanNotShowDialogIf_UserDeniedForContext() {

    withEnvironment(userDefaults: userDefaults) {

      PushNotificationDialog.didDenyAccess(for: .save)

      XCTAssertFalse(PushNotificationDialog.canShowDialog(for: .save))
    }
  }

  func testCanShowDialogIf_UserDeniedLessThanThreeTimes() {

    withEnvironment(userDefaults: userDefaults) {

      PushNotificationDialog.didDenyAccess(for: .save)
      PushNotificationDialog.didDenyAccess(for: .message)

      XCTAssertTrue(PushNotificationDialog.canShowDialog(for: .pledge))
    }
  }

  func testCanNotShowDialogIf_UserDeniedThreeTimes() {

    withEnvironment(userDefaults: userDefaults) {

      PushNotificationDialog.didDenyAccess(for: .save)
      PushNotificationDialog.didDenyAccess(for: .message)
      PushNotificationDialog.didDenyAccess(for: .login)

      XCTAssertFalse(PushNotificationDialog.canShowDialog(for: .pledge))
    }
  }

  func testContextIsAddedToUserDefaults_AfterDenial() {

    withEnvironment(userDefaults: userDefaults) {

      PushNotificationDialog.didDenyAccess(for: .login)
      XCTAssertEqual(["login"], userDefaults.deniedNotificationContexts )

      PushNotificationDialog.didDenyAccess(for: .save)
      XCTAssertEqual(["login", "save"], userDefaults.deniedNotificationContexts )
    }
  }
}
