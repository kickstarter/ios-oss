import XCTest
@testable import Library

// swiftlint:disable line_length
final class StringCurrencyTests: XCTestCase {
  func testCurrencySymbol_NoSymbol() {
    let currencySymbol = ""
    let attributedString = attributedCurrencyString(
      currencySymbol: currencySymbol,
      amount: 99.975,
      fractionDigits: 2,
      font: UIFont.ksr_title1(),
      superscriptFont: UIFont.ksr_body(),
      foregroundColor: UIColor.cyan
    )
    let range = NSRange(location: 0, length: currencySymbol.count)
    let attributedSubstring = attributedString.attributedSubstring(from: range)

    XCTAssertEqual("99.97", attributedString.string)
    XCTAssertEqual(0, attributedSubstring.length)
  }

  func testCurrencySymbol_SimpleSymbol() {
    let currencySymbol = "$"
    let font = UIFont.ksr_title1()
    let superscriptFont = UIFont.ksr_body()
    let foregroundColor = UIColor.cyan
    let attributedString = attributedCurrencyString(
      currencySymbol: currencySymbol,
      amount: 99.975,
      fractionDigits: 2,
      font: font,
      superscriptFont: superscriptFont,
      foregroundColor: foregroundColor
    )
    let range = NSRange(location: 0, length: currencySymbol.count)
    let attributedSubstring = attributedString.attributedSubstring(from: range)
    let attributes = attributedSubstring.attributes(at: 0, longestEffectiveRange: nil, in: range)
    let offset = font.capHeight - superscriptFont.capHeight

    XCTAssertEqual("$99.97", attributedString.string)
    XCTAssertEqual(currencySymbol, attributedSubstring.string)
    XCTAssertEqual(superscriptFont, attributes[NSAttributedString.Key.font] as? UIFont)
    XCTAssertEqual(foregroundColor, attributes[NSAttributedString.Key.foregroundColor] as? UIColor)
    XCTAssertEqual(offset, (attributes[NSAttributedString.Key.baselineOffset] as? NSNumber) as? CGFloat)
  }

  func testCurrencySymbol_CustomSymbol() {
    let currencySymbol = "CA$"
    let font = UIFont.ksr_title1()
    let superscriptFont = UIFont.ksr_body()
    let foregroundColor = UIColor.cyan
    let attributedString = attributedCurrencyString(
      currencySymbol: currencySymbol,
      amount: 99.975,
      fractionDigits: 2,
      font: font,
      superscriptFont: superscriptFont,
      foregroundColor: foregroundColor
    )
    let range = NSRange(location: 0, length: currencySymbol.count)
    let attributedSubstring = attributedString.attributedSubstring(from: range)
    let attributes = attributedSubstring.attributes(at: 0, longestEffectiveRange: nil, in: range)
    let offset = font.capHeight - superscriptFont.capHeight

    XCTAssertEqual("CA$99.97", attributedString.string)
    XCTAssertEqual(currencySymbol, attributedSubstring.string)
    XCTAssertEqual(superscriptFont, attributes[NSAttributedString.Key.font] as? UIFont)
    XCTAssertEqual(foregroundColor, attributes[NSAttributedString.Key.foregroundColor] as? UIColor)
    XCTAssertEqual(offset, (attributes[NSAttributedString.Key.baselineOffset] as? NSNumber) as? CGFloat)
  }

  func testAmount_Zero() {
    let font = UIFont.ksr_title1()
    let foregroundColor = UIColor.cyan
    let attributedString = attributedCurrencyString(
      currencySymbol: "",
      amount: 0,
      fractionDigits: 2,
      font: font,
      superscriptFont: UIFont.ksr_body(),
      foregroundColor: foregroundColor
    )
    let range = NSRange(location: 0, length: 1)
    let attributedSubstring = attributedString.attributedSubstring(from: range)
    let attributes = attributedSubstring.attributes(at: 0, longestEffectiveRange: nil, in: range)

    XCTAssertEqual("0.00", attributedString.string)
    XCTAssertEqual("0", attributedSubstring.string)
    XCTAssertEqual(font, attributes[NSAttributedString.Key.font] as? UIFont)
    XCTAssertEqual(foregroundColor, attributes[NSAttributedString.Key.foregroundColor] as? UIColor)
  }

  func testAmount_NonZero() {
    let font = UIFont.ksr_title1()
    let foregroundColor = UIColor.cyan
    let attributedString = attributedCurrencyString(
      currencySymbol: "",
      amount: 199,
      fractionDigits: 2,
      font: font,
      superscriptFont: UIFont.ksr_body(),
      foregroundColor: foregroundColor
    )
    let range = NSRange(location: 0, length: 3)
    let attributedSubstring = attributedString.attributedSubstring(from: range)
    let attributes = attributedSubstring.attributes(at: 0, longestEffectiveRange: nil, in: range)

    XCTAssertEqual("199.00", attributedString.string)
    XCTAssertEqual("199", attributedSubstring.string)
    XCTAssertEqual(font, attributes[NSAttributedString.Key.font] as? UIFont)
    XCTAssertEqual(foregroundColor, attributes[NSAttributedString.Key.foregroundColor] as? UIColor)
  }

  func testFractionDigits_Zero() {
    let superscriptFont = UIFont.ksr_body()
    let foregroundColor = UIColor.cyan
    let fractionDigits = 0
    let fractionDigitsPlusSeparator = 0
    let attributedString = attributedCurrencyString(
      currencySymbol: "",
      amount: 1.2755,
      fractionDigits: UInt(fractionDigits),
      font: UIFont.ksr_title1(),
      superscriptFont: superscriptFont,
      foregroundColor: foregroundColor
    )
    let range = NSRange(location: 0, length: fractionDigitsPlusSeparator)
    let attributedSubstring = attributedString.attributedSubstring(from: range)

    XCTAssertEqual("1", attributedString.string)
    XCTAssertEqual(0, attributedSubstring.length)
  }

  func testFractionDigits_Two() {
    let superscriptFont = UIFont.ksr_body()
    let foregroundColor = UIColor.cyan
    let fractionDigits = 2
    let fractionDigitsPlusSeparator = fractionDigits + 1
    let attributedString = attributedCurrencyString(
      currencySymbol: "",
      amount: 1.2755,
      fractionDigits: UInt(fractionDigits),
      font: UIFont.ksr_title1(),
      superscriptFont: superscriptFont,
      foregroundColor: foregroundColor
    )
    var range = NSRange(location: 1, length: fractionDigitsPlusSeparator)
    let attributedSubstring = attributedString.attributedSubstring(from: range)
    range = NSRange(location: 0, length: fractionDigitsPlusSeparator)
    let attributes = attributedSubstring.attributes(at: 0, longestEffectiveRange: nil, in: range)

    XCTAssertEqual("1.28", attributedString.string)
    XCTAssertEqual(".28", attributedSubstring.string)
    XCTAssertEqual(superscriptFont, attributes[NSAttributedString.Key.font] as? UIFont)
    XCTAssertEqual(foregroundColor, attributes[NSAttributedString.Key.foregroundColor] as? UIColor)
  }

  func testFractionDigits_Ten() {
    let superscriptFont = UIFont.ksr_body()
    let foregroundColor = UIColor.cyan
    let fractionDigits = 10
    let fractionDigitsPlusSeparator = fractionDigits + 1
    let attributedString = attributedCurrencyString(
      currencySymbol: "",
      amount: 1.2755,
      fractionDigits: UInt(fractionDigits),
      font: UIFont.ksr_title1(),
      superscriptFont: superscriptFont,
      foregroundColor: foregroundColor
    )
    var range = NSRange(location: 1, length: fractionDigitsPlusSeparator)
    let attributedSubstring = attributedString.attributedSubstring(from: range)
    range = NSRange(location: 0, length: fractionDigitsPlusSeparator)
    let attributes = attributedSubstring.attributes(at: 0, longestEffectiveRange: nil, in: range)

    XCTAssertEqual("1.2755000000", attributedString.string)
    XCTAssertEqual(".2755000000", attributedSubstring.string)
    XCTAssertEqual(superscriptFont, attributes[NSAttributedString.Key.font] as? UIFont)
    XCTAssertEqual(foregroundColor, attributes[NSAttributedString.Key.foregroundColor] as? UIColor)
  }

  func testBaselineOffset_FontLargerThanSuperscriptFont() {
    let currencySymbol = "CZK"
    let font = UIFont.ksr_title1()
    let superscriptFont = UIFont.ksr_body()
    let foregroundColor = UIColor.cyan
    let fractionDigits = 1
    let fractionDigitsPlusSeparator = fractionDigits + 1
    let attributedString = attributedCurrencyString(
      currencySymbol: currencySymbol,
      amount: 14.99,
      fractionDigits: UInt(fractionDigits),
      font: font,
      superscriptFont: superscriptFont,
      foregroundColor: foregroundColor
    )
    var range = NSRange(location: 0, length: currencySymbol.count)
    let attributedCurrencySubstring = attributedString.attributedSubstring(from: range)
    range = NSRange(location: currencySymbol.count + 2, length: fractionDigitsPlusSeparator)
    let attributedFractionSubstring = attributedString.attributedSubstring(from: range)
    range = NSRange(location: 0, length: currencySymbol.count)
    let currencyAttributes = attributedCurrencySubstring.attributes(at: 0, longestEffectiveRange: nil, in: range)
    range = NSRange(location: 0, length: fractionDigitsPlusSeparator)
    let fractionAttributes = attributedFractionSubstring.attributes(at: 0, longestEffectiveRange: nil, in: range)
    let offset = font.capHeight - superscriptFont.capHeight

    XCTAssertEqual("CZK15.0", attributedString.string)
    XCTAssertEqual("CZK", attributedCurrencySubstring.string)
    XCTAssertEqual(".0", attributedFractionSubstring.string)
    XCTAssertEqual(superscriptFont, currencyAttributes[NSAttributedString.Key.font] as? UIFont)
    XCTAssertEqual(foregroundColor, currencyAttributes[NSAttributedString.Key.foregroundColor] as? UIColor)
    XCTAssertEqual(offset, (currencyAttributes[NSAttributedString.Key.baselineOffset] as? NSNumber) as? CGFloat)
    XCTAssertEqual(superscriptFont, fractionAttributes[NSAttributedString.Key.font] as? UIFont)
    XCTAssertEqual(foregroundColor, fractionAttributes[NSAttributedString.Key.foregroundColor] as? UIColor)
    XCTAssertEqual(offset, (fractionAttributes[NSAttributedString.Key.baselineOffset] as? NSNumber) as? CGFloat)
  }

  func testBaselineOffset_FontSmallerThanSuperscriptFont() {
    let currencySymbol = "CZK"
    let font = UIFont.ksr_body()
    let superscriptFont = UIFont.ksr_title1()
    let foregroundColor = UIColor.cyan
    let fractionDigits = 1
    let fractionDigitsPlusSeparator = fractionDigits + 1
    let attributedString = attributedCurrencyString(
      currencySymbol: currencySymbol,
      amount: 14.99,
      fractionDigits: UInt(fractionDigits),
      font: font,
      superscriptFont: superscriptFont,
      foregroundColor: foregroundColor
    )
    var range = NSRange(location: 0, length: currencySymbol.count)
    let attributedCurrencySubstring = attributedString.attributedSubstring(from: range)
    range = NSRange(location: currencySymbol.count + 2, length: fractionDigitsPlusSeparator)
    let attributedFractionSubstring = attributedString.attributedSubstring(from: range)
    range = NSRange(location: 0, length: currencySymbol.count)
    let currencyAttributes = attributedCurrencySubstring.attributes(at: 0, longestEffectiveRange: nil, in: range)
    range = NSRange(location: 0, length: fractionDigitsPlusSeparator)
    let fractionAttributes = attributedFractionSubstring.attributes(at: 0, longestEffectiveRange: nil, in: range)

    XCTAssertEqual("CZK15.0", attributedString.string)
    XCTAssertEqual("CZK", attributedCurrencySubstring.string)
    XCTAssertEqual(".0", attributedFractionSubstring.string)
    XCTAssertEqual(superscriptFont, currencyAttributes[NSAttributedString.Key.font] as? UIFont)
    XCTAssertEqual(foregroundColor, currencyAttributes[NSAttributedString.Key.foregroundColor] as? UIColor)
    XCTAssertEqual(0, (currencyAttributes[NSAttributedString.Key.baselineOffset] as? NSNumber) as? CGFloat)
    XCTAssertEqual(superscriptFont, fractionAttributes[NSAttributedString.Key.font] as? UIFont)
    XCTAssertEqual(foregroundColor, fractionAttributes[NSAttributedString.Key.foregroundColor] as? UIColor)
    XCTAssertEqual(0, (fractionAttributes[NSAttributedString.Key.baselineOffset] as? NSNumber) as? CGFloat)
  }

  func testBaselineOffset_FontEqualToSuperscriptFont() {
    let currencySymbol = "CZK"
    let font = UIFont.ksr_body()
    let foregroundColor = UIColor.cyan
    let fractionDigits = 1
    let fractionDigitsPlusSeparator = fractionDigits + 1
    let attributedString = attributedCurrencyString(
      currencySymbol: currencySymbol,
      amount: 14.99,
      fractionDigits: UInt(fractionDigits),
      font: font,
      superscriptFont: font,
      foregroundColor: foregroundColor
    )
    var range = NSRange(location: 0, length: currencySymbol.count)
    let attributedCurrencySubstring = attributedString.attributedSubstring(from: range)
    range = NSRange(location: currencySymbol.count + 2, length: fractionDigitsPlusSeparator)
    let attributedFractionSubstring = attributedString.attributedSubstring(from: range)
    range = NSRange(location: 0, length: currencySymbol.count)
    let currencyAttributes = attributedCurrencySubstring.attributes(at: 0, longestEffectiveRange: nil, in: range)
    range = NSRange(location: 0, length: fractionDigitsPlusSeparator)
    let fractionAttributes = attributedFractionSubstring.attributes(at: 0, longestEffectiveRange: nil, in: range)

    XCTAssertEqual("CZK15.0", attributedString.string)
    XCTAssertEqual("CZK", attributedCurrencySubstring.string)
    XCTAssertEqual(".0", attributedFractionSubstring.string)
    XCTAssertEqual(font, currencyAttributes[NSAttributedString.Key.font] as? UIFont)
    XCTAssertEqual(foregroundColor, currencyAttributes[NSAttributedString.Key.foregroundColor] as? UIColor)
    XCTAssertEqual(0, (currencyAttributes[NSAttributedString.Key.baselineOffset] as? NSNumber) as? CGFloat)
    XCTAssertEqual(font, fractionAttributes[NSAttributedString.Key.font] as? UIFont)
    XCTAssertEqual(foregroundColor, fractionAttributes[NSAttributedString.Key.foregroundColor] as? UIColor)
    XCTAssertEqual(0, (fractionAttributes[NSAttributedString.Key.baselineOffset] as? NSNumber) as? CGFloat)
  }

  func testForegroundColor() {
    let foregroundColor = UIColor.red
    let attributedString = attributedCurrencyString(
      currencySymbol: "CA$",
      amount: 9.99,
      fractionDigits: 2,
      font: UIFont.ksr_title1(),
      superscriptFont: UIFont.ksr_body(),
      foregroundColor: foregroundColor
    )
    let range = NSRange(location: 0, length: attributedString.length)
    let attributes = attributedString.attributes(at: 0, longestEffectiveRange: nil, in: range)

    XCTAssertEqual("CA$9.99", attributedString.string)
    XCTAssertEqual(foregroundColor, attributes[NSAttributedString.Key.foregroundColor] as? UIColor)
  }

  func testCombined_Currency_NoSymbol_Amount_Zero_FractionDigits_Zero() {
    let currencySymbol = ""
    let font = UIFont.ksr_title2()
    let superscriptFont = UIFont.ksr_body()
    let foregroundColor = UIColor.cyan
    let fractionDigits = 0
    let attributedString = attributedCurrencyString(
      currencySymbol: currencySymbol,
      amount: 0,
      fractionDigits: UInt(fractionDigits),
      font: font,
      superscriptFont: superscriptFont,
      foregroundColor: foregroundColor
    )
    let range = NSRange(location: 0, length: attributedString.length)
    let attributes = attributedString.attributes(at: 0, longestEffectiveRange: nil, in: range)

    XCTAssertEqual("0", attributedString.string)
    XCTAssertEqual(foregroundColor, attributes[NSAttributedString.Key.foregroundColor] as? UIColor)
  }

  func testCombined_Currency_SimpleSymbol_Amount_NonZero_FractionDigits_Two() {
    let currencySymbol = "¥"
    let font = UIFont.ksr_title2()
    let superscriptFont = UIFont.ksr_body()
    let foregroundColor = UIColor.cyan
    let fractionDigits = 2
    let fractionDigitsPlusSeparator = fractionDigits + 1
    let attributedString = attributedCurrencyString(
      currencySymbol: currencySymbol,
      amount: 10.0025,
      fractionDigits: UInt(fractionDigits),
      font: font,
      superscriptFont: superscriptFont,
      foregroundColor: foregroundColor
    )
    var range = NSRange(location: currencySymbol.count, length: 2)
    let attributedAmountSubstring = attributedString.attributedSubstring(from: range)
    range = NSRange(location: 0, length: currencySymbol.count)
    let attributedCurrencySubstring = attributedString.attributedSubstring(from: range)
    range = NSRange(location: currencySymbol.count + 2, length: fractionDigitsPlusSeparator)
    let attributedFractionSubstring = attributedString.attributedSubstring(from: range)
    range = NSRange(location: 0, length: currencySymbol.count)
    let currencyAttributes = attributedCurrencySubstring.attributes(at: 0, longestEffectiveRange: nil, in: range)
    range = NSRange(location: 0, length: 2)
    let amountAttributes = attributedAmountSubstring.attributes(at: 0, longestEffectiveRange: nil, in: range)
    range = NSRange(location: 0, length: fractionDigitsPlusSeparator)
    let fractionAttributes = attributedFractionSubstring.attributes(at: 0, longestEffectiveRange: nil, in: range)
    let offset = font.capHeight - superscriptFont.capHeight

    XCTAssertEqual("¥10.00", attributedString.string)
    XCTAssertEqual("¥", attributedCurrencySubstring.string)
    XCTAssertEqual(".00", attributedFractionSubstring.string)
    XCTAssertEqual(superscriptFont, currencyAttributes[NSAttributedString.Key.font] as? UIFont)
    XCTAssertEqual(foregroundColor, currencyAttributes[NSAttributedString.Key.foregroundColor] as? UIColor)
    XCTAssertEqual(offset, (currencyAttributes[NSAttributedString.Key.baselineOffset] as? NSNumber) as? CGFloat)
    XCTAssertEqual(font, amountAttributes[NSAttributedString.Key.font] as? UIFont)
    XCTAssertEqual(foregroundColor, amountAttributes[NSAttributedString.Key.foregroundColor] as? UIColor)
    XCTAssertEqual(superscriptFont, fractionAttributes[NSAttributedString.Key.font] as? UIFont)
    XCTAssertEqual(foregroundColor, fractionAttributes[NSAttributedString.Key.foregroundColor] as? UIColor)
    XCTAssertEqual(offset, (fractionAttributes[NSAttributedString.Key.baselineOffset] as? NSNumber) as? CGFloat)
  }

  func testCombined_Currency_CustomSymbol_Amount_NonZero_FractionDigits_Five() {
    let currencySymbol = "CZK"
    let font = UIFont.ksr_title2()
    let superscriptFont = UIFont.ksr_body()
    let foregroundColor = UIColor.blue
    let fractionDigits = 5
    let fractionDigitsPlusSeparator = fractionDigits + 1
    let attributedString = attributedCurrencyString(
      currencySymbol: currencySymbol,
      amount: 100.0025,
      fractionDigits: UInt(fractionDigits),
      font: font,
      superscriptFont: superscriptFont,
      foregroundColor: foregroundColor
    )
    var range = NSRange(location: currencySymbol.count, length: 3)
    let attributedAmountSubstring = attributedString.attributedSubstring(from: range)
    range = NSRange(location: 0, length: currencySymbol.count)
    let attributedCurrencySubstring = attributedString.attributedSubstring(from: range)
    range = NSRange(location: currencySymbol.count + 3, length: fractionDigitsPlusSeparator)
    let attributedFractionSubstring = attributedString.attributedSubstring(from: range)
    range = NSRange(location: 0, length: currencySymbol.count)
    let currencyAttributes = attributedCurrencySubstring.attributes(at: 0, longestEffectiveRange: nil, in: range)
    range = NSRange(location: 0, length: 3)
    let amountAttributes = attributedAmountSubstring.attributes(at: 0, longestEffectiveRange: nil, in: range)
    range = NSRange(location: 0, length: fractionDigitsPlusSeparator)
    let fractionAttributes = attributedFractionSubstring.attributes(at: 0, longestEffectiveRange: nil, in: range)
    let offset = font.capHeight - superscriptFont.capHeight

    XCTAssertEqual("CZK100.00250", attributedString.string)
    XCTAssertEqual("CZK", attributedCurrencySubstring.string)
    XCTAssertEqual(".00250", attributedFractionSubstring.string)
    XCTAssertEqual(superscriptFont, currencyAttributes[NSAttributedString.Key.font] as? UIFont)
    XCTAssertEqual(foregroundColor, currencyAttributes[NSAttributedString.Key.foregroundColor] as? UIColor)
    XCTAssertEqual(offset, (currencyAttributes[NSAttributedString.Key.baselineOffset] as? NSNumber) as? CGFloat)
    XCTAssertEqual(font, amountAttributes[NSAttributedString.Key.font] as? UIFont)
    XCTAssertEqual(foregroundColor, amountAttributes[NSAttributedString.Key.foregroundColor] as? UIColor)
    XCTAssertEqual(superscriptFont, fractionAttributes[NSAttributedString.Key.font] as? UIFont)
    XCTAssertEqual(foregroundColor, fractionAttributes[NSAttributedString.Key.foregroundColor] as? UIColor)
    XCTAssertEqual(offset, (fractionAttributes[NSAttributedString.Key.baselineOffset] as? NSNumber) as? CGFloat)
  }
}
