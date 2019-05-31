@testable import Library
import XCTest

final class UILabelSimpleHTMLTests: XCTestCase {
  func testSetHTML() {
    let label = UILabel()
    label.textColor = .red
    label.textAlignment = .center
    label.setHTML("<b>Howdy<b> there!")

    XCTAssertEqual(label.text, "Howdy there!")
    XCTAssertEqual(label.textColor, UIColor.red)
    XCTAssertEqual(label.textAlignment, NSTextAlignment.center)
  }
}
