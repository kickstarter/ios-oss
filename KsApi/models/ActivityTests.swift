import XCTest
@testable import KsApi
import Argo

final internal class ActivityTests: XCTestCase {

  func testEquatable() {
    XCTAssertEqual(Activity.template, Activity.template)
  }

  func testJSONDecoding_WithBadData() {
    let activity = Activity.decodeJSONDictionary([
      "category": "update"
    ])

    XCTAssertNotNil(activity.error)
  }

  func testJSONDecoding_WithGoodData() {
    let activity = Activity.decodeJSONDictionary([
      "category": "update",
      "created_at": 123123123,
      "id": 1,
      ])

    XCTAssertNil(activity.error)
    XCTAssertEqual(activity.value?.id, 1)
  }

  func testJSONParsing_WithMemberData() {
    let memberData = Activity.MemberData.decodeJSONDictionary([
      "amount": 25.0,
      "backing": [
        "amount": 1.0,
        "backer_id": 1,
        "id": 1,
        "location_id": 1,
        "pledged_at": 1000,
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

    XCTAssertNil(memberData.error)
    XCTAssertEqual(25, memberData.value?.amount)
    XCTAssertEqual(1, memberData.value?.backing?.id)
    XCTAssertEqual(15, memberData.value?.oldAmount)
    XCTAssertEqual(1, memberData.value?.oldRewardId)
    XCTAssertEqual(25, memberData.value?.newAmount)
    XCTAssertEqual(2, memberData.value?.newRewardId)
    XCTAssertEqual(2, memberData.value?.rewardId)
  }

  func testJSONDecoding_WithNestedGoodData() {
    let activity = Activity.decodeJSONDictionary([
      "category": "update",
      "created_at": 123123123,
      "id": 1,
      "user": [
        "id": 2,
        "name": "User",
        "avatar": [
          "medium": "img.jpg",
          "small": "img.jpg",
          "large": "img.jpg",
        ]
      ]
      ])

    XCTAssertNil(activity.error)
    XCTAssertEqual(activity.value?.id, 1)
    XCTAssertEqual(activity.value?.user?.id, 2)
  }

  func testJSONDecoding_WithIncorrectCategory() {
    let activity = Activity.decodeJSONDictionary([
      "category": "incorrect_category",
      "created_at": 123123123,
      "id": 1,
      ])

    XCTAssertNil(activity.error)
    XCTAssertEqual(.some(.unknown), activity.value?.category)
  }
}
