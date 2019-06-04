@testable import Library
import XCTest

final class UIFontTests: XCTestCase {
  func testSameFontsHaveZeroBaselineOffset() {
    let font1 = UIFont.ksr_body()
    let font2 = UIFont.ksr_body()

    XCTAssertEqual(0, font1.baselineOffsetToSuperscript(of: font2))
  }

  func testSmallerFontHasBaselineOffsetToLargerFontsSuperscript() {
    let smaller = UIFont.ksr_body()
    let larger = UIFont.ksr_title1()
    let diff = NSNumber(value: Float(larger.capHeight - smaller.capHeight))

    XCTAssertEqual(diff, smaller.baselineOffsetToSuperscript(of: larger))
  }

  func testLargerFontHasZeroBaselineOffsetToSmallerFontsSuperscript() {
    let smaller = UIFont.ksr_body()
    let larger = UIFont.ksr_title1()

    XCTAssertEqual(0, larger.baselineOffsetToSuperscript(of: smaller))
  }
}
