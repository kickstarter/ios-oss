import XCTest
import Foundation
import ReactiveSwift
import Result
@testable import KsApi
@testable import Library
@testable import Kickstarter_Framework
@testable import ReactiveExtensions
@testable import ReactiveExtensions_TestHelpers

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

internal final class SharedFunctionsTests: XCTestCase {

  func testLogoutAndDismiss() {
    let mockAppEnvironment = MockAppEnvironment.self
    let mockPushNotificationDialog = MockPushNotificationDialog.self
    let mockViewController = MockViewController()

    XCTAssertFalse(mockAppEnvironment.logoutWasCalled)
    XCTAssertFalse(mockPushNotificationDialog.resetAllContextsWasCalled)
    XCTAssertFalse(mockViewController.dismissAnimatedWasCalled)
    mockAppEnvironment.logout()
    XCTAssertTrue(mockAppEnvironment.logoutWasCalled)
    mockPushNotificationDialog.resetAllContexts()
    XCTAssertTrue(mockPushNotificationDialog.resetAllContextsWasCalled)
    mockViewController.dismiss(animated: true, completion: nil)
    XCTAssertTrue(mockViewController.dismissAnimatedWasCalled)
  }
}
