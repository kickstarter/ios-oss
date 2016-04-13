import XCTest
@testable import Library

final class UIButtonLocalizedKeyTests: XCTestCase {

  override func setUp() {
    AppEnvironment.pushEnvironment(mainBundle: MockBundle())
  }

  override func tearDown() {
    AppEnvironment.popEnvironment()
  }

  func testNormalLocalizedKey() {
    let button = UIButton()

    withEnvironment(language: .en) {
      button.normalLocalizedKey = "hello"
      XCTAssertEqual(button.titleForState(.Normal), "world")
      XCTAssertEqual(button.normalLocalizedKey, "")
    }

    withEnvironment(language: .de) {
      button.normalLocalizedKey = "hello"
      XCTAssertEqual(button.titleForState(.Normal), "de_world")
      XCTAssertEqual(button.normalLocalizedKey, "")
    }
  }

  func testSelectedLocalizedKey() {
    let button = UIButton()

    withEnvironment(language: .en) {
      button.selectedLocalizedKey = "hello"
      XCTAssertEqual(button.titleForState(.Selected), "world")
      XCTAssertEqual(button.selectedLocalizedKey, "")
    }

    withEnvironment(language: .de) {
      button.selectedLocalizedKey = "hello"
      XCTAssertEqual(button.titleForState(.Selected), "de_world")
      XCTAssertEqual(button.selectedLocalizedKey, "")
    }
  }

  func testDisabledLocalizedKey() {
    let button = UIButton()

    withEnvironment(language: .en) {
      button.disabledLocalizedKey = "hello"
      XCTAssertEqual(button.titleForState(.Disabled), "world")
      XCTAssertEqual(button.disabledLocalizedKey, "")
    }

    withEnvironment(language: .de) {
      button.disabledLocalizedKey = "hello"
      XCTAssertEqual(button.titleForState(.Disabled), "de_world")
      XCTAssertEqual(button.disabledLocalizedKey, "")
    }
  }
}
