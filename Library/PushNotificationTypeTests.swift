import XCTest
@testable import Library

final class PushNotificationTypeTests: XCTestCase {
  let options: [PushNotificationType] = [.alert, .badge, .sound]

  func testsUserNotificationTypes() {
    let userNotificationTypes = options.userNotificationTypes()

    XCTAssertTrue(userNotificationTypes.contains(.alert))
    XCTAssertTrue(userNotificationTypes.contains(.badge))
    XCTAssertTrue(userNotificationTypes.contains(.sound))
  }

  @available(iOS 10.0, *)
  func testAuthorizationOptions() {
    let authorizationOptions = options.authorizationOptions()

    XCTAssertTrue(authorizationOptions.contains(.alert))
    XCTAssertTrue(authorizationOptions.contains(.badge))
    XCTAssertTrue(authorizationOptions.contains(.sound))
  }
}
