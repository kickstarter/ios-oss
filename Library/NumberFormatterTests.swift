@testable import Library
import XCTest

final class NumberFormatterTests: TestCase {
  // MARK: - Properties

  let defaultAttributes: String.Attributes = [
    .font: UIFont.preferredFont(forTextStyle: .title1),
    .foregroundColor: UIColor.black
  ]

  let currencySymbolAttributes: String.Attributes = [
    .backgroundColor: UIColor.cyan,
    .font: UIFont.preferredFont(forTextStyle: .body)
  ]

  let decimalSeparatorAttributes: String.Attributes = [
    .font: UIFont.preferredFont(forTextStyle: .body),
    .strokeColor: UIColor.magenta
  ]

  let fractionDigitsAttributes: String.Attributes = [
    .font: UIFont.preferredFont(forTextStyle: .body),
    .underlineColor: UIColor.orange
  ]

  // MARK: - Tests

  func testAttributedString() {
    let formatter = AttributedNumberFormatter()
    formatter.defaultAttributes = self.defaultAttributes

    guard let attributedString = formatter.attributedString(for: 1_000) else {
      XCTFail("attributedString should not be nil")
      return
    }

    XCTAssertEqual("1000", attributedString.string)

    let range = attributedString.range(of: "1000")
    let attributedSubstring = attributedString.attributedSubstring(from: range)
    let attributes = attributedSubstring.attributes(at: 0, effectiveRange: nil)

    XCTAssertTrue(self.defaultAttributes == attributes)
  }

  func testAttributedString_DecimalSeparator() {
    let formatter = AttributedNumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencySymbol = "CA$"
    formatter.defaultAttributes = self.defaultAttributes
    formatter.decimalSeparatorAttributes = self.decimalSeparatorAttributes

    guard let attributedString = formatter.attributedString(for: 1_000) else {
      XCTFail("attributedString should not be nil")
      return
    }

    XCTAssertEqual("CA$1,000.00", attributedString.string)

    let range = attributedString.range(of: ".")
    let attributedSubstring = attributedString.attributedSubstring(from: range)
    let attributes = attributedSubstring.attributes(at: 0, effectiveRange: nil)
    let expectedAttributes = self.defaultAttributes.merging(self.decimalSeparatorAttributes) { _, new in new }

    XCTAssertTrue(expectedAttributes == attributes)
  }

  func testAttributedString_FractionDigits() {
    let formatter = AttributedNumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencySymbol = "DKK"
    formatter.defaultAttributes = self.defaultAttributes
    formatter.fractionDigitsAttributes = self.fractionDigitsAttributes

    guard let attributedString = formatter.attributedString(for: 1_000) else {
      XCTFail("attributedString should not be nil")
      return
    }

    XCTAssertEqual("DKK 1,000.00", attributedString.string)

    let range = attributedString.range(of: "00", options: .backwards)
    let attributedSubstring = attributedString.attributedSubstring(from: range)
    let attributes = attributedSubstring.attributes(at: 0, effectiveRange: nil)
    let expectedAttributes = self.defaultAttributes.merging(self.fractionDigitsAttributes) { _, new in new }

    XCTAssertTrue(expectedAttributes == attributes)
  }

  func testAttributedString_Combined() {
    let formatter = AttributedNumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencySymbol = "€"
    formatter.defaultAttributes = self.defaultAttributes
    formatter.currencySymbolAttributes = self.currencySymbolAttributes
    formatter.decimalSeparatorAttributes = self.decimalSeparatorAttributes
    formatter.fractionDigitsAttributes = self.fractionDigitsAttributes

    guard let attributedString = formatter.attributedString(for: 1_000) else {
      XCTFail("attributedString should not be nil")
      return
    }

    XCTAssertEqual("€1,000.00", attributedString.string)

    var range = attributedString.range(of: "€")
    var attributedSubstring = attributedString.attributedSubstring(from: range)
    var attributes = attributedSubstring.attributes(at: 0, effectiveRange: nil)
    var expectedAttributes = self.defaultAttributes.merging(self.currencySymbolAttributes) { _, new in new }

    XCTAssertEqual("€", attributedSubstring.string)
    XCTAssertTrue(expectedAttributes == attributes)

    range = attributedString.range(of: "1,000")
    attributedSubstring = attributedString.attributedSubstring(from: range)
    attributes = attributedSubstring.attributes(at: 0, effectiveRange: nil)

    XCTAssertEqual("1,000", attributedSubstring.string)
    XCTAssertTrue(self.defaultAttributes == attributes)

    range = attributedString.range(of: ".")
    attributedSubstring = attributedString.attributedSubstring(from: range)
    attributes = attributedSubstring.attributes(at: 0, effectiveRange: nil)
    expectedAttributes = self.defaultAttributes.merging(self.decimalSeparatorAttributes) { _, new in new }

    XCTAssertEqual(".", attributedSubstring.string)
    XCTAssertTrue(expectedAttributes == attributes)

    range = attributedString.range(of: "00", options: .backwards)
    attributedSubstring = attributedString.attributedSubstring(from: range)
    attributes = attributedSubstring.attributes(at: 0, effectiveRange: nil)
    expectedAttributes = self.defaultAttributes.merging(self.fractionDigitsAttributes) { _, new in new }

    XCTAssertEqual("00", attributedSubstring.string)
    XCTAssertTrue(expectedAttributes == attributes)
  }
}

private extension NSAttributedString {
  func range(of substring: String, options: NSString.CompareOptions = .caseInsensitive) -> NSRange {
    return (self.string as NSString).range(of: substring, options: options)
  }
}
