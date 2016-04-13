import XCTest
@testable import Library

final class UITextFieldLocalizedKeyTests: XCTestCase {

  func testLocalizedKey() {
    let tf = UITextField()

    withEnvironment(mainBundle: MockBundle(), language: .en) {
      tf.localizedPlaceholderKey = "placeholder_password"
      XCTAssertEqual("password", tf.placeholder)
      XCTAssertEqual("", tf.localizedPlaceholderKey)
    }

    withEnvironment(mainBundle: MockBundle(), language: .es) {
      tf.localizedPlaceholderKey = "placeholder_password"
      XCTAssertEqual("el secreto", tf.placeholder)
      XCTAssertEqual("", tf.localizedPlaceholderKey)
    }
  }
}
