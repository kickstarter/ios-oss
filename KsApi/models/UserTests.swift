import XCTest
@testable import KsApi
import Prelude

final class UserTests: XCTestCase {

  func testEquatable() {
    XCTAssertEqual(User.template, User.template)
    XCTAssertNotEqual(User.template, User.template |> User.lens.id %~ { $0 + 1 })
  }

  func testDescription() {
    XCTAssertNotEqual("", User.template.debugDescription)
  }

  func testJsonParsing() {
    let json: [String:Any] = [
      "id": 1,
      "name": "Blob",
      "avatar": [
        "medium": "http://www.kickstarter.com/medium.jpg",
        "small": "http://www.kickstarter.com/small.jpg"
      ],
      "backed_projects_count": 2,
      "weekly_newsletter": false,
      "promo_newsletter": false,
      "happening_newsletter": false,
      "games_newsletter": false,
      "facebook_connected": false,
      "ksr_live_token": "token",
      "location": [
        "country": "US",
        "id": 12,
        "displayable_name": "Brooklyn, NY",
        "name": "Brooklyn"
      ],
      "is_friend": false
    ]
    let decoded = User.decodeJSONDictionary(json)
    let user = decoded.value

    XCTAssertNil(decoded.error)
    XCTAssertEqual(1, user?.id)
    XCTAssertEqual("http://www.kickstarter.com/small.jpg", user?.avatar.small)
    XCTAssertEqual(2, user?.stats.backedProjectsCount)
    XCTAssertEqual(false, user?.newsletters.weekly)
    XCTAssertEqual(false, user?.newsletters.promo)
    XCTAssertEqual(false, user?.newsletters.happening)
    XCTAssertEqual(false, user?.newsletters.games)
    XCTAssertEqual(false, user?.facebookConnected)
    XCTAssertEqual(false, user?.isFriend)
    XCTAssertEqual("token", user?.liveAuthToken)
    XCTAssertNotNil(user?.location)
    XCTAssertEqual(json as NSDictionary?, user?.encode() as NSDictionary?)
  }

  func testJsonEncoding() {
    let json: [String:Any] = [
      "id": 1,
      "name": "Blob",
      "avatar": [
        "medium": "http://www.kickstarter.com/medium.jpg",
        "small": "http://www.kickstarter.com/small.jpg",
        "large": "http://www.kickstarter.com/large.jpg"
      ],
      "backed_projects_count": 2,
      "games_newsletter": false,
      "happening_newsletter": false,
      "promo_newsletter": false,
      "weekly_newsletter": false,
      "facebook_connected": false,
      "ksr_live_token": "token",
      "location": [
        "country": "US",
        "id": 12,
        "displayable_name": "Brooklyn, NY",
        "name": "Brooklyn"
      ],
      "is_friend": false
    ]
    let user = User.decodeJSONDictionary(json)

    XCTAssertEqual(user.value?.encode() as NSDictionary?, json as NSDictionary?)
  }
}
