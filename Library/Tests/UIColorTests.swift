import XCTest
@testable import Library

final class UIColorTests: XCTestCase {
  func testColors() {
    let red = UIColor.hex(0xFF0000)
    let green = UIColor.hex(0x00FF00)
    let blue = UIColor.hex(0x0000FF)
    let redAlpha = UIColor.hexa(0x80FF0000)

    XCTAssertEqual(UIColor(red:1.0, green:0.0, blue:0.0, alpha:1.0), red)
    XCTAssertEqual(UIColor(red:0.0, green:1.0, blue:0.0, alpha:1.0), green)
    XCTAssertEqual(UIColor(red:0.0, green:0.0, blue:1.0, alpha:1.0), blue)

    var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
    redAlpha.getRed(&r, green: &g, blue: &b, alpha: &a)
    XCTAssertEqualWithAccuracy(0.5, a, accuracy: 0.01)

    XCTAssertEqual(UIColor.hex(0xA6000000), UIColor.hex(0x000000))

    XCTAssertNotEqual(UIColor.hexa(0xA6000000), UIColor.hex(0x000000))
    XCTAssertNotEqual(UIColor.hexa(0xA6000000), UIColor.hexa(0x80000000))
  }
}
