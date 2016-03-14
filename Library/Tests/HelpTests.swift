import XCTest
@testable import Library

final class HelpTests: XCTestCase {

  func testHelpTitlesDefault() {
    let label = UILabel()

    label.text = HelpType.Contact.title()
    XCTAssertEqual("Contact", label.text)

    label.text = HelpType.HowItWorks.title()
    XCTAssertEqual("How Kickstarter Works", label.text)
  }

  func testHelpTitlesLocalized() {
    AppEnvironment.pushEnvironment(mainBundle: MockBundle())

    let label = UILabel()

    label.text = HelpType.Contact.title()
    XCTAssertEqual("Mock Contact", label.text)

    withEnvironment(language: .es) {
      label.text = HelpType.Contact.title()
      XCTAssertEqual("Contacto", label.text)
    }

    withEnvironment(language: .de) {
      label.text = HelpType.Contact.title()
      XCTAssertEqual("Contact", label.text)
    }
  }
}
