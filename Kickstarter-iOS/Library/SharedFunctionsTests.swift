import XCTest
@testable import Kickstarter_Framework
@testable import Library

internal final class SharedFunctionsTests: XCTestCase {
  func testLogoutAndDismiss() {
    let mockAppEnvironment = MockAppEnvironment.self
    let mockPushNotificationDialog = MockPushNotificationDialog.self
    let mockViewController = MockViewController()

    XCTAssertFalse(mockAppEnvironment.logoutWasCalled)
    XCTAssertFalse(mockPushNotificationDialog.resetAllContextsWasCalled)
    XCTAssertFalse(mockViewController.dismissAnimatedWasCalled)
    logoutAndDismiss(viewController: mockViewController, appEnvironment: mockAppEnvironment,
                     pushNotificationDialog: mockPushNotificationDialog)
    XCTAssertTrue(mockAppEnvironment.logoutWasCalled)
    XCTAssertTrue(mockPushNotificationDialog.resetAllContextsWasCalled)
    XCTAssertTrue(mockViewController.dismissAnimatedWasCalled)
  }
}

struct MockAppEnvironment: AppEnvironmentType {
  static var logoutWasCalled = false

  static func logout() {
    self.logoutWasCalled = true
  }
}

struct MockPushNotificationDialog: PushNotificationDialogType {
  static var resetAllContextsWasCalled = false

  static func resetAllContexts() {
    self.resetAllContextsWasCalled = true
  }
}

class MockViewController: UIViewController {
  var dismissAnimatedWasCalled = false

  override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
    self.dismissAnimatedWasCalled = true
  }
}
