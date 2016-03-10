import XCTest
@testable import Library

final class StylesTests: XCTestCase {
  func testEquality() {
    XCTAssertEqual(FontText.Headline, FontText.Headline)
    XCTAssertEqual(Weight.Default, Weight.Default)
    XCTAssertEqual(Color.Black, Color.Black)
    XCTAssertEqual(Color.Category.Art, Color.Category.Art)
    XCTAssertEqual(Color.Social.FacebookBlue, Color.Social.FacebookBlue)
  }

  func testInequality() {
    XCTAssertNotEqual(FontText.Headline, FontText.Body)
    XCTAssertNotEqual(Weight.Default, Weight.Medium)
    XCTAssertNotEqual(Color.Black, Color.Blue)
    XCTAssertNotEqual(Color.Category.Art, Color.Category.Theater)
    XCTAssertNotEqual(Color.Social.FacebookBlue, Color.Social.TwitterBlue)
  }

  func testFontText() {
    let headline = FontText(rawValue: "Headline")
    let head = FontText(rawValue: "Head")

    XCTAssertNotNil(headline)
    XCTAssertNil(head, "Not valid name")
  }

  func testColor() {
    let green = Color(rawValue: "Green")
    let greeny = Color(rawValue: "Greeny")

    XCTAssertNotNil(green)
    XCTAssertNil(greeny)

    let black = UIColor(red:0.0, green:0.0, blue:0.0, alpha:1.0)
    XCTAssertEqual(Color.Black.toUIColor(), black)

    let blue = UIColor(red:0.0, green:0.63, blue:1.0, alpha:1.0)
    XCTAssertEqual(Color.Blue.toUIColor(), blue)
  }

  func testColorCategory() {
    let comics = Color.Category(rawValue: "Comics")
    let dancey = Color.Category(rawValue: "Dancey")

    XCTAssertNotNil(comics)
    XCTAssertNil(dancey)

    let filmColor = UIColor(red:1.0, green:0.35, blue:0.43, alpha:1.0)
    XCTAssertEqual(Color.Category.Film.toUIColor(), filmColor)

    let gamesColor = UIColor(red:0.0, green:0.79, blue:0.67, alpha:1.0)
    XCTAssertEqual(Color.Category.Games.toUIColor(), gamesColor)
  }

  func testColorSocial() {
    let facebook = Color.Social(rawValue: "FacebookBlue")
    let twitter = Color.Social(rawValue: "Twitter")

    XCTAssertNotNil(facebook)
    XCTAssertNil(twitter)

    let facebookBlue = UIColor(red:0.23, green:0.35, blue:0.6, alpha:1.0)
    XCTAssertEqual(Color.Social.FacebookBlue.toUIColor(), facebookBlue)

    let twitterBlue = UIColor(red:0.0, green:0.67, blue:0.93, alpha:1.0)
    XCTAssertEqual(Color.Social.TwitterBlue.toUIColor(), twitterBlue)
  }
}
