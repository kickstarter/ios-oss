@testable import KsApi
import Prelude
import XCTest

final class UserTests: XCTestCase {
  func testEquatable() {
    XCTAssertEqual(User.template, User.template)
    XCTAssertNotEqual(User.template, User.template |> \.id %~ { $0 + 1 })
  }

  func testDescription() {
    XCTAssertNotEqual("", User.template.debugDescription)
  }

  func testJsonParsing() {
    let json: [String: Any] = [
      "id": 1,
      "name": "Blob",
      "avatar": [
        "medium": "http://www.kickstarter.com/medium.jpg",
        "small": "http://www.kickstarter.com/small.jpg"
      ],
      "needs_password": true,
      "backed_projects_count": 2,
      "draft_projects_count": 4,
      "weekly_newsletter": false,
      "promo_newsletter": false,
      "happening_newsletter": false,
      "games_newsletter": false,
      "notify_of_comment_replies": false,
      "notify_mobile_of_marketing_update": true,
      "facebook_connected": false,
      "location": [
        "country": "US",
        "id": 12,
        "displayable_name": "Brooklyn, NY",
        "localized_name": "Brooklyn, NY",
        "name": "Brooklyn"
      ],
      "is_admin": false,
      "is_email_verified": false,
      "is_friend": false,
      "opted_out_of_recommendations": true,
      "show_public_profile": false,
      "social": true
    ]

    guard let user: User = tryDecode(json) else {
      XCTFail("User object should be decodable")

      return
    }

    XCTAssertEqual(1, user.id)
    XCTAssertEqual(false, user.isAdmin)
    XCTAssertEqual("http://www.kickstarter.com/small.jpg", user.avatar.small)
    XCTAssertEqual(2, user.stats.backedProjectsCount)
    XCTAssertEqual(4, user.stats.draftProjectsCount)
    XCTAssertEqual(false, user.newsletters.weekly)
    XCTAssertEqual(false, user.newsletters.promo)
    XCTAssertEqual(false, user.newsletters.happening)
    XCTAssertEqual(false, user.newsletters.games)
    XCTAssertEqual(false, user.notifications.commentReplies)
    XCTAssertEqual(true, user.notifications.mobileMarketingUpdate)
    XCTAssertEqual(false, user.facebookConnected)
    XCTAssertEqual(false, user.isEmailVerified)
    XCTAssertTrue(user.needsPassword!)
    XCTAssertEqual(false, user.isFriend)
    XCTAssertNotNil(user.location)
    XCTAssertEqual(json as NSDictionary?, user.encode() as NSDictionary?)
  }

  func testJsonEncoding() {
    let json: [String: Any] = [
      "id": 1,
      "name": "Blob",
      "avatar": [
        "medium": "http://www.kickstarter.com/medium.jpg",
        "small": "http://www.kickstarter.com/small.jpg",
        "large": "http://www.kickstarter.com/large.jpg"
      ],
      "needs_password": false,
      "backed_projects_count": 2,
      "games_newsletter": false,
      "happening_newsletter": false,
      "promo_newsletter": false,
      "weekly_newsletter": false,
      "notify_of_comment_replies": false,
      "notify_mobile_of_marketing_update": true,
      "facebook_connected": false,
      "location": [
        "country": "US",
        "id": 12,
        "displayable_name": "Brooklyn, NY",
        "localized_name": "Brooklyn, NY",
        "name": "Brooklyn"
      ],
      "is_admin": false,
      "is_email_verified": false,
      "is_friend": false,
      "opted_out_of_recommendations": true,
      "show_public_profile": false,
      "social": true
    ]
    let user: User? = User.decodeJSONDictionary(json)

    XCTAssertEqual(user?.encode() as NSDictionary?, json as NSDictionary?)
  }

  func testIsRepeatCreator() {
    let user = User.template
    let creator = User.template
      |> User.lens.stats.createdProjectsCount .~ 1
    let repeatCreator = User.template
      |> User.lens.stats.createdProjectsCount .~ 2

    XCTAssertEqual(true, repeatCreator.isRepeatCreator)
    XCTAssertEqual(false, creator.isRepeatCreator)
    XCTAssertNil(user.isRepeatCreator)
  }
}
