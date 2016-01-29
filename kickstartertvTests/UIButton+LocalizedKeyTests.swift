import XCTest
@testable import kickstartertv

final class UIButtonLocalizedKeyTests : XCTestCase {

  func testNormalLocalizedKey() {
    let button = UIButton()

    withEnvironment(language: .en) {
      button.normalLocalizedKey = "project_of_the_day"
      XCTAssertEqual(button.titleForState(.Normal), "Project of the day")
      XCTAssertEqual(button.normalLocalizedKey, "")
    }

    withEnvironment(language: .de) {
      button.normalLocalizedKey = "project_of_the_day"
      XCTAssertEqual(button.titleForState(.Normal), "Projekt des Tages")
      XCTAssertEqual(button.normalLocalizedKey, "")
    }
  }

  func testSelectedLocalizedKey() {
    let button = UIButton()

    withEnvironment(language: .en) {
      button.selectedLocalizedKey = "project_of_the_day"
      XCTAssertEqual(button.titleForState(.Selected), "Project of the day")
      XCTAssertEqual(button.selectedLocalizedKey, "")
    }

    withEnvironment(language: .de) {
      button.selectedLocalizedKey = "project_of_the_day"
      XCTAssertEqual(button.titleForState(.Selected), "Projekt des Tages")
      XCTAssertEqual(button.selectedLocalizedKey, "")
    }
  }

  func testDisabledLocalizedKey() {
    let button = UIButton()

    withEnvironment(language: .en) {
      button.disabledLocalizedKey = "project_of_the_day"
      XCTAssertEqual(button.titleForState(.Disabled), "Project of the day")
      XCTAssertEqual(button.disabledLocalizedKey, "")
    }

    withEnvironment(language: .de) {
      button.disabledLocalizedKey = "project_of_the_day"
      XCTAssertEqual(button.titleForState(.Disabled), "Projekt des Tages")
      XCTAssertEqual(button.disabledLocalizedKey, "")
    }
  }
}
