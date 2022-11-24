@testable import KsApi
import XCTest

internal final class MessageThreadTests: XCTestCase {
  func testDecoding() {
    let result: MessageThread = try! MessageThread.decodeJSONDictionary([
      "closed": false,
      "id": 1,
      "last_message": [
        "body": "Hello!",
        "created_at": 123_456_789.0,
        "id": 1,
        "recipient": [
          "id": 1,
          "name": "Blob",
          "avatar": [
            "medium": "img",
            "small": "img"
          ],
          "needs_password": true
        ],
        "sender": [
          "id": 2,
          "name": "Clob",
          "avatar": [
            "medium": "img",
            "small": "img"
          ],
          "needs_password": true
        ]
      ],
      "unread_messages_count": 1,
      "participant": [
        "id": 1,
        "name": "Blob",
        "avatar": [
          "medium": "img",
          "small": "img"
        ],
        "needs_password": true
      ],
      "project": [
        "id": 1,
        "name": "Project",
        "blurb": "The project blurb",
        "staff_pick": false,
        "pledged": 1_000,
        "goal": 2_000,
        "category": [
          "id": 1,
          "name": "Art",
          "slug": "art",
          "position": 1
        ],
        "creator": [
          "id": 1,
          "name": "Blob",
          "avatar": [
            "medium": "http://www.kickstarter.com/medium.jpg",
            "small": "http://www.kickstarter.com/small.jpg"
          ],
          "needs_password": true
        ],
        "photo": [
          "full": "http://www.kickstarter.com/full.jpg",
          "med": "http://www.kickstarter.com/med.jpg",
          "small": "http://www.kickstarter.com/small.jpg",
          "1024x768": "http://www.kickstarter.com/1024x768.jpg"
        ],
        "location": [
          "country": "US",
          "id": 1,
          "displayable_name": "Brooklyn, NY",
          "name": "Brooklyn"
        ],
        "video": [
          "id": 1,
          "high": "kickstarter.com/video.mp4"
        ],
        "backers_count": 10,
        "currency_symbol": "$",
        "currency": "USD",
        "currency_trailing_code": false,
        "country": "US",
        "launched_at": 1_000,
        "deadline": 1_000,
        "state_changed_at": 1_000,
        "static_usd_rate": 1.0,
        "slug": "project",
        "urls": [
          "web": [
            "project": "https://www.kickstarter.com/projects/my-cool-projects"
          ]
        ],
        "state": "live"
      ]
    ])

    XCTAssertNotNil(result)
  }
}
