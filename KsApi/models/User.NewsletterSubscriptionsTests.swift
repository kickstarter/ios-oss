import XCTest
@testable import KsApi

final class NewsletterSubscriptionsTests: XCTestCase {

  func testJsonEncoding() {
    let json: [String: Any] = [
      "games_newsletter": false,
      "promo_newsletter": false,
      "happening_newsletter": false,
      "weekly_newsletter": false
    ]

    let newsletter = User.NewsletterSubscriptions.decodeJSONDictionary(json)
    let encodedNewsletter = newsletter.value?.encode() ?? [String: Any]()

    // swiftlint:disable force_cast
    XCTAssertFalse(encodedNewsletter["games_newsletter"] as! Bool)
    XCTAssertFalse(encodedNewsletter["promo_newsletter"] as! Bool)
    XCTAssertFalse(encodedNewsletter["happening_newsletter"] as! Bool)
    XCTAssertFalse(encodedNewsletter["weekly_newsletter"] as! Bool)

    XCTAssertEqual(false, newsletter.value?.weekly)
    XCTAssertEqual(false, newsletter.value?.promo)
    XCTAssertEqual(false, newsletter.value?.happening)
    XCTAssertEqual(false, newsletter.value?.games)
  }

  func testJsonEncoding_TrueValues() {
    let json: [String: Any] = [
      "games_newsletter": true,
      "promo_newsletter": true,
      "happening_newsletter": true,
      "weekly_newsletter": true
    ]

    let newsletter = User.NewsletterSubscriptions.decodeJSONDictionary(json)
    let encodedNewsletter = newsletter.value?.encode() ?? [String: Any]()

    // swiftlint:disable force_cast
    XCTAssertTrue(encodedNewsletter["games_newsletter"] as! Bool)
    XCTAssertTrue(encodedNewsletter["promo_newsletter"] as! Bool)
    XCTAssertTrue(encodedNewsletter["happening_newsletter"] as! Bool)
    XCTAssertTrue(encodedNewsletter["weekly_newsletter"] as! Bool)

    XCTAssertEqual(true, newsletter.value?.weekly)
    XCTAssertEqual(true, newsletter.value?.promo)
    XCTAssertEqual(true, newsletter.value?.happening)
    XCTAssertEqual(true, newsletter.value?.games)
  }

  func testJsonDecoding() {
    let json = User.NewsletterSubscriptions.decodeJSONDictionary([
      "games_newsletter": true,
      "happening_newsletter": false,
      "promo_newsletter": true,
      "weekly_newsletter": false
    ])

    let newsletters = json.value

    XCTAssertEqual(newsletters,
                   User.NewsletterSubscriptions.decodeJSONDictionary(newsletters?.encode() ?? [:]).value)
  }
}
