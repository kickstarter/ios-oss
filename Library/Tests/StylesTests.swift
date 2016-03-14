import XCTest
@testable import Library

final class StylesTests: XCTestCase {

  func testFontStyle() {
    let headline = FontStyle(rawValue: "Headline")
    let head = FontStyle(rawValue: "Head")

    XCTAssertNotNil(headline)
    XCTAssertNil(head, "Not valid name")

    let headlineFont = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
    XCTAssertEqual(FontStyle.Headline.toUIFont(), headlineFont)

    let captionFont = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
    XCTAssertNotEqual(FontStyle.Headline.toUIFont(), captionFont)
  }

  func testWeight() {
    let def = Weight(rawValue: "Default")
    let bad = Weight(rawValue: "Med")

    XCTAssertNotNil(def)
    XCTAssertNil(bad, "Not valid name")
  }

  func testColor() {
    let green = Color(rawValue: "Green")
    let greeny = Color(rawValue: "Greeny")

    XCTAssertNotNil(green)
    XCTAssertNil(greeny)

    let black = UIColor(red:0.0, green:0.0, blue:0.0, alpha:1.0)
    XCTAssertEqual(Color.Black.toUIColor(), black)
  }

  func testColorCategory() {
    let comics = Color.Category(rawValue: "Comics")
    let dancey = Color.Category(rawValue: "Dancey")

    XCTAssertNotNil(comics)
    XCTAssertNil(dancey)

    let filmColor = Color.Category.Film.toUIColor()
    var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
    filmColor.getRed(&r, green: &g, blue: &b, alpha: &a)
    XCTAssertEqualWithAccuracy(1.0, r, accuracy: 0.01)
    XCTAssertEqualWithAccuracy(0.35, g, accuracy: 0.01)
    XCTAssertEqualWithAccuracy(0.43, b, accuracy: 0.01)
  }

  func testColorSocial() {
    let facebook = Color.Social(rawValue: "FacebookBlue")
    let twitter = Color.Social(rawValue: "Twitter")

    XCTAssertNotNil(facebook)
    XCTAssertNil(twitter)

    let facebookBlue = Color.Social.FacebookBlue.toUIColor()
    var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
    facebookBlue.getRed(&r, green: &g, blue: &b, alpha: &a)
    XCTAssertEqualWithAccuracy(0.23, r, accuracy: 0.01)
    XCTAssertEqualWithAccuracy(0.35, g, accuracy: 0.01)
    XCTAssertEqualWithAccuracy(0.6, b, accuracy: 0.01)
  }

  func testAllColors() {
    XCTAssertEqual(21, Color.allColors.count,
      "If this test fails it means some colors were added/removed. Please update the count if that happens")
    XCTAssertEqual(30, Color.Category.allColors.count,
      "If this test fails it means some colors were added/removed. Please update the count if that happens")
    XCTAssertEqual(2, Color.Social.allColors.count,
      "If this test fails it means some colors were added/removed. Please update the count if that happens")
  }
}
