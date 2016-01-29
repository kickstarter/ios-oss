import XCTest
@testable import kickstartertv

final class UILabelLocalizedKeyTests : XCTestCase {

  func testLocalizedKey() {
    let label = UILabel()

    withEnvironment(language: .en) {
      label.localizedKey = "project_of_the_day"
      XCTAssertEqual(label.text, "Project of the day")
      XCTAssertEqual(label.localizedKey, "")
    }

    withEnvironment(language: .de) {
      label.localizedKey = "project_of_the_day"
      XCTAssertEqual(label.text, "Projekt des Tages")
      XCTAssertEqual(label.localizedKey, "")
    }
  }

  func testNotLocalizable() {
    let label = UILabel()

    label.notLocalizable = false
    XCTAssertEqual(label.notLocalizable, false)
  }
}
