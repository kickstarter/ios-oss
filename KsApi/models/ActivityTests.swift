@testable import KsApi
import XCTest

internal final class ActivityTests: XCTestCase {
  func testEquatable() {
    XCTAssertEqual(Activity.template, Activity.template)
  }

  func testJSONDecoding_WithBadData() {
    let activity: Activity! = Activity.decodeJSONDictionary([
      "category": "update"
    ])

    XCTAssertNil(activity)
  }

  func testJSONDecoding_WithGoodData() {
    let activity: Activity! = Activity.decodeJSONDictionary([
      "category": "update",
      "created_at": 123_123_123,
      "id": 1
    ])

    XCTAssertNotNil(activity)
    XCTAssertEqual(activity.id, 1)
  }

  func testJSONParsing_WithMemberData() {
    let memberData: Activity.MemberData! = Activity.MemberData.decodeJSONDictionary([
      "amount": 25.0,
      "backing": [
        "amount": 1.0,
        "backer_id": 1,
        "cancelable": true,
        "id": 1,
        "location_id": 1,
        "pledged_at": 1_000,
        "project_country": "US",
        "project_id": 1,
        "sequence": 1,
        "status": "pledged"
      ],
      "old_amount": 15.0,
      "old_reward_id": 1,
      "new_amount": 25.0,
      "new_reward_id": 2,
      "reward_id": 2
    ])

    XCTAssertNotNil(memberData)
    XCTAssertEqual(25, memberData.amount)
    XCTAssertEqual(1, memberData.backing?.id)
    XCTAssertEqual(15, memberData.oldAmount)
    XCTAssertEqual(1, memberData.oldRewardId)
    XCTAssertEqual(25, memberData.newAmount)
    XCTAssertEqual(2, memberData.newRewardId)
    XCTAssertEqual(2, memberData.rewardId)
  }

  func testJSONDecoding_WithNestedGoodData() {
    let activity: Activity! = Activity.decodeJSONDictionary([
      "category": "update",
      "created_at": 123_123_123,
      "id": 1,
      "user": [
        "id": 2,
        "name": "User",
        "needs_password": false,
        "avatar": [
          "medium": "img.jpg",
          "small": "img.jpg",
          "large": "img.jpg"
        ]
      ]
    ])

    XCTAssertNotNil(activity)
    XCTAssertEqual(activity.id, 1)
    XCTAssertEqual(activity.user?.id, 2)
  }

  func testJSONDecoding_WithIncorrectCategory() {
    let activity: Activity! = Activity.decodeJSONDictionary([
      "category": "incorrect_category",
      "created_at": 123_123_123,
      "id": 1
    ])

    XCTAssertNotNil(activity)
    XCTAssertEqual(.unknown, activity.category)
  }
}
