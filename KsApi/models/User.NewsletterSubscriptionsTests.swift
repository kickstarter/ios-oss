@testable import KsApi
import XCTest

final class NewsletterSubscriptionsTests: XCTestCase {
  func testJsonEncoding() {
    let json: [String: Any] = [
      "games_newsletter": false,
      "promo_newsletter": false,
      "happening_newsletter": false,
      "weekly_newsletter": false
    ]

    let newsletter: User.NewsletterSubscriptions! = User.NewsletterSubscriptions.decodeJSONDictionary(json)

    let newsletterDescription = newsletter!.encode().description

    XCTAssertTrue(newsletterDescription.contains("games_newsletter\": false"))
    XCTAssertTrue(newsletterDescription.contains("happening_newsletter\": false"))
    XCTAssertTrue(newsletterDescription.contains("promo_newsletter\": false"))
    XCTAssertTrue(newsletterDescription.contains("weekly_newsletter\": false"))

    XCTAssertEqual(false, newsletter.weekly)
    XCTAssertEqual(false, newsletter.promo)
    XCTAssertEqual(false, newsletter.happening)
    XCTAssertEqual(false, newsletter.games)
  }

  func testJsonEncoding_TrueValues() {
    let json: [String: Any] = [
      "games_newsletter": true,
      "promo_newsletter": true,
      "happening_newsletter": true,
      "weekly_newsletter": true
    ]

    let newsletter: User.NewsletterSubscriptions! = User.NewsletterSubscriptions.decodeJSONDictionary(json)

    let newsletterDescription = newsletter.encode().description

    XCTAssertTrue(newsletterDescription.contains("games_newsletter\": true"))
    XCTAssertTrue(newsletterDescription.contains("promo_newsletter\": true"))
    XCTAssertTrue(newsletterDescription.contains("happening_newsletter\": true"))
    XCTAssertTrue(newsletterDescription.contains("weekly_newsletter\": true"))

    XCTAssertEqual(true, newsletter.weekly)
    XCTAssertEqual(true, newsletter.promo)
    XCTAssertEqual(true, newsletter.happening)
    XCTAssertEqual(true, newsletter.games)
  }

  func testJsonDecoding() {
    let newsletters: User.NewsletterSubscriptions! = User.NewsletterSubscriptions.decodeJSONDictionary([
      "games_newsletter": true,
      "happening_newsletter": false,
      "promo_newsletter": true,
      "weekly_newsletter": false
    ])

    XCTAssertEqual(
      newsletters,
      User.NewsletterSubscriptions.decodeJSONDictionary(newsletters?.encode() ?? [:])
    )
  }
}
