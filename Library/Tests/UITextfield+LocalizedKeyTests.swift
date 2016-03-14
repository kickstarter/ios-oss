import XCTest
@testable import Library

final class UITextFieldLocalizedKeyTests : XCTestCase {

  override func setUp() {
    AppEnvironment.pushEnvironment(mainBundle: MockBundle())
  }

  func testLocalizedKey() {
    let tf = UITextField()

    withEnvironment(language: .en) {
      tf.localizedKey = "placeholder_password"
      XCTAssertEqual(tf.placeholder, "password")
      XCTAssertEqual(tf.localizedKey, "")
    }

    withEnvironment(language: .es) {
      tf.localizedKey = "placeholder_password"
      XCTAssertEqual(tf.placeholder, "el secreto")
      XCTAssertEqual(tf.localizedKey, "")
    }
  }
}
