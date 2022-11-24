@testable import KsApi
import XCTest

final class FindFriendsEnvelopeTests: XCTestCase {
  func testJsonDecoding() {
    let json: [String: Any] = [
      "contacts_imported": true,
      "urls": [
        "api": [
          "more_users": "http://api.dev/v1/users/self/friends/find?count=10"
        ]
      ],
      "users": [
        [
          "id": 1,
          "name": "Blob",
          "avatar": [
            "medium": "http://www.kickstarter.com/medium.jpg",
            "small": "http://www.kickstarter.com/small.jpg"
          ],
          "needs_password": false,
          "backed_projects_count": 2,
          "weekly_newsletter": false,
          "promo_newsletter": false,
          "happening_newsletter": false,
          "games_newsletter": false,
          "facebook_connected": false,
          "location": [
            "id": 12,
            "displayable_name": "Brooklyn, NY",
            "name": "Brooklyn"
          ],
          "is_friend": false
        ],
        [
          "id": 2,
          "name": "Blab",
          "avatar": [
            "medium": "http://www.kickstarter.com/medium.jpg",
            "small": "http://www.kickstarter.com/small.jpg"
          ],
          "needs_password": false,
          "backed_projects_count": 2,
          "weekly_newsletter": false,
          "promo_newsletter": false,
          "happening_newsletter": false,
          "games_newsletter": false,
          "facebook_connected": false,
          "location": [
            "id": 12,
            "displayable_name": "Brooklyn, NY",
            "name": "Brooklyn"
          ],
          "is_friend": true
        ]
      ]
    ]

    let friends: FindFriendsEnvelope = try! FindFriendsEnvelope.decodeJSONDictionary(json)
    let users = friends.users

    XCTAssertEqual(true, friends.contactsImported)
    XCTAssertEqual(
      "http://api.dev/v1/users/self/friends/find?count=10",
      friends.urls.api.moreUsers
    )
    XCTAssertEqual(false, users[0].isFriend)
    XCTAssertEqual(true, users[1].isFriend)
  }

  func testJsonDecoding_MissingData() {
    let json: [String: Any] = [
      "contacts_imported": true,
      "urls": [
        "api": [
        ]
      ],
      "users": [
      ]
    ]

    let friends: FindFriendsEnvelope? = FindFriendsEnvelope.decodeJSONDictionary(json)

    XCTAssertNil(friends?.urls.api.moreUsers)
    XCTAssertEqual([], friends?.users ?? [])
  }
}
