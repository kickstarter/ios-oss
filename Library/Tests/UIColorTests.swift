import XCTest
@testable import Library

final class UIColorTests: XCTestCase {
  let black = UIColor.hex(0x000000)
  let white = UIColor.hex(0xFFFFFF)
  let red = UIColor.hex(0xFF0000)
  let redAlpha = UIColor.hexa(0x80FF0000)
  let clear = UIColor.hexa(0x00000000)

  func testColorMatching() {
    XCTAssertEqual(black, UIColor(red:0.0, green:0.0, blue:0.0, alpha:1.0))
    XCTAssertEqual(white, UIColor(red:1.0, green:1.0, blue:1.0, alpha:1.0))
    XCTAssertEqual(clear, UIColor(red:0.0, green:0.0, blue:0.0, alpha:0.0))

    XCTAssertEqual(red, UIColor(red:1.0, green:0.0, blue:0.0, alpha:1.0))
    XCTAssertEqual(redAlpha, UIColor(red:1.0, green:0.0, blue:0.0, alpha:0.5))

    XCTAssertEqual(UIColor.hex(0xA6000000), UIColor.hex(0x000000))
    XCTAssertEqual(UIColor.hex(0x333333), UIColor.hex(0x333333))
    XCTAssertEqual(UIColor.hexa(0xA6000000), UIColor.hexa(0xA6000000))
  }

  func testColorMisMatching() {
    XCTAssertNotEqual(black, white)
    XCTAssertNotEqual(red, redAlpha)

    XCTAssertNotEqual(UIColor.hexa(0xA6000000), UIColor.hex(0x000000))
    XCTAssertNotEqual(UIColor.hexa(0xA6000000), UIColor.hexa(0x80000000))
  }
}
