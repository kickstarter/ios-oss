import XCTest
@testable import Kickstarter_tvOS

final class UILabelLocalizedKeyTests : XCTestCase {

  override func setUp() {
    AppEnvironment.pushEnvironment(mainBundle: MockBundle())
  }

  override func tearDown() {
    AppEnvironment.popEnvironment()
  }

  func testLocalizedKey() {
    let label = UILabel()

    withEnvironment(language: .en) {
      label.localizedKey = "hello"
      XCTAssertEqual(label.text, "world")
      XCTAssertEqual(label.localizedKey, "")
    }

    withEnvironment(language: .de) {
      label.localizedKey = "hello"
      XCTAssertEqual(label.text, "de_world")
      XCTAssertEqual(label.localizedKey, "")
    }
  }

  func testNotLocalizable() {
    let label = UILabel()

    label.notLocalizable = false
    XCTAssertEqual(label.notLocalizable, false)
  }
}
