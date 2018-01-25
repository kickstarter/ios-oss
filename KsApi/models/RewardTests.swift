import XCTest
@testable import KsApi
import Prelude

final class RewardTests: XCTestCase {

  func testIsNoReward() {
    XCTAssertTrue(Reward.noReward.isNoReward)
    XCTAssertFalse(Reward.template.isNoReward)
  }

  func testEquatable() {
    XCTAssertEqual(Reward.template, Reward.template)
    XCTAssertNotEqual(Reward.template, Reward.template |> Reward.lens.id %~ { $0 + 1})
    XCTAssertNotEqual(Reward.template, Reward.noReward)
  }

  func testComparable() {
    let reward1 = Reward.template |> Reward.lens.id .~ 1 <> Reward.lens.minimum .~ 10
    let reward2 = Reward.template |> Reward.lens.id .~ 4 <> Reward.lens.minimum .~ 30
    let reward3 = Reward.template |> Reward.lens.id .~ 3 <> Reward.lens.minimum .~ 20
    let reward4 = Reward.template |> Reward.lens.id .~ 2 <> Reward.lens.minimum .~ 30

    let rewards = [reward1, reward2, reward3, reward4]
    let sorted = rewards.sorted()

    XCTAssertEqual(sorted, [reward1, reward3, reward4, reward2])
  }

  func testJsonParsing_WithMinimalData_AndDescription() {
    let reward = Reward.decodeJSONDictionary([
      "id": 1,
      "minimum": 10,
      "description": "cool stuff"
      ])

    XCTAssertNil(reward.error)
    XCTAssertEqual(reward.value?.id, 1)
    XCTAssertEqual(reward.value?.description, "cool stuff")
    XCTAssertNotNil(reward.value?.shipping)
    XCTAssertEqual(false, reward.value?.shipping.enabled)

  }

  func testJsonParsing_WithMinimalData_AndReward() {
    let reward = Reward.decodeJSONDictionary([
      "id": 1,
      "minimum": 10,
      "reward": "cool stuff"
      ])

    XCTAssertNil(reward.error)
    XCTAssertEqual(reward.value?.id, 1)
    XCTAssertEqual(reward.value?.minimum, 10)
    XCTAssertEqual(reward.value?.description, "cool stuff")
  }

  func testJsonParsing_WithFullData() {
    let reward = Reward.decodeJSONDictionary([
      "id": 1,
      "description": "Some reward",
      "minimum": 10,
      "backers_count": 10
      ])

    XCTAssertNotNil(reward)
    XCTAssertEqual(reward.value?.id, 1)
    XCTAssertEqual(reward.value?.description, "Some reward")
    XCTAssertEqual(reward.value?.minimum, 10)
    XCTAssertEqual(reward.value?.backersCount, 10)
  }

  func testJsonDecoding_WithShipping() {

    let reward = Reward.decodeJSONDictionary([
      "id": 1,
      "description": "Some reward",
      "minimum": 10,
      "backers_count": 10,
      "shipping_enabled": true,
      "shipping_preference": "unrestricted",
      "shipping_summary": "Ships anywhere in the world."
      ])

    XCTAssertNotNil(reward)
    XCTAssertEqual(reward.value?.id, 1)
    XCTAssertEqual(reward.value?.description, "Some reward")
    XCTAssertEqual(reward.value?.minimum, 10)
    XCTAssertEqual(reward.value?.backersCount, 10)
    XCTAssertEqual(true, reward.value?.shipping.enabled)
    XCTAssertEqual(.unrestricted, reward.value?.shipping.preference)
    XCTAssertEqual("Ships anywhere in the world.", reward.value?.shipping.summary)
  }
}
