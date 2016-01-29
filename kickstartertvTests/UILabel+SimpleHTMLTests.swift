import XCTest
@testable import kickstartertv

final class UILabelSimpleHTMLTests : XCTestCase {

  func testSetHTML() {
    let label = UILabel()
    label.textColor = .redColor()
    label.textAlignment = .Center
    label.setHTML("<b>Howdy<b> there!")

    XCTAssertEqual(label.text, "Howdy there!")
    XCTAssertEqual(label.textColor, UIColor.redColor())
    XCTAssertEqual(label.textAlignment, NSTextAlignment.Center)
  }
}
