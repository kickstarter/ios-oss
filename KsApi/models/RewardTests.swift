@testable import KsApi
import Prelude
import XCTest

final class RewardTests: XCTestCase {
  func testIsNoReward() {
    XCTAssertEqual(Reward.noReward.isNoReward, true)
    XCTAssertEqual(Reward.template.isNoReward, false)
  }

  func testEquatable() {
    XCTAssertEqual(Reward.template, Reward.template)
    XCTAssertNotEqual(Reward.template, Reward.template |> Reward.lens.id %~ { $0 + 1 })
    XCTAssertNotEqual(Reward.template, Reward.noReward)
  }

  func testComparable() {
    let reward1 = Reward.template |> Reward.lens.id .~ 1 <> Reward.lens.minimum .~ 10.0
    let reward2 = Reward.template |> Reward.lens.id .~ 4 <> Reward.lens.minimum .~ 30.0
    let reward3 = Reward.template |> Reward.lens.id .~ 3 <> Reward.lens.minimum .~ 20.0
    let reward4 = Reward.template |> Reward.lens.id .~ 2 <> Reward.lens.minimum .~ 30.0

    let rewards = [reward1, reward2, reward3, reward4]
    let sorted = rewards.sorted()

    XCTAssertEqual(sorted, [reward1, reward3, reward4, reward2])
  }

  func testJsonParsing_WithMinimalData_AndDescription() {
    let reward = Reward.decodeJSONDictionary([
      "id": 1,
      "minimum": 10,
      "converted_minimum": 12,
      "description": "cool stuff"
    ])

    XCTAssertNil(reward.error)
    XCTAssertEqual(reward.value?.id, 1)
    XCTAssertEqual(reward.value?.minimum, 10)
    XCTAssertEqual(reward.value?.convertedMinimum, 12)
    XCTAssertEqual(reward.value?.description, "cool stuff")
    XCTAssertNotNil(reward.value?.shipping)
    XCTAssertEqual(false, reward.value?.shipping.enabled)
  }

  func testJsonParsing_WithMinimalData_AndReward() {
    let reward = Reward.decodeJSONDictionary([
      "id": 1,
      "minimum": 10,
      "converted_minimum": 12,
      "reward": "cool stuff"
    ])

    XCTAssertNil(reward.error)
    XCTAssertEqual(reward.value?.id, 1)
    XCTAssertEqual(reward.value?.minimum, 10)
    XCTAssertEqual(reward.value?.convertedMinimum, 12)
    XCTAssertEqual(reward.value?.description, "cool stuff")
  }

  func testJsonParsing_WithFullData() {
    let reward = Reward.decodeJSONDictionary([
      "id": 1,
      "description": "Some reward",
      "minimum": 10,
      "converted_minimum": 12,
      "backers_count": 10
    ])

    XCTAssertNotNil(reward)
    XCTAssertEqual(reward.value?.id, 1)
    XCTAssertEqual(reward.value?.description, "Some reward")
    XCTAssertEqual(reward.value?.minimum, 10)
    XCTAssertEqual(reward.value?.convertedMinimum, 12)
    XCTAssertEqual(reward.value?.backersCount, 10)
  }

  func testJsonDecoding_WithShipping() {
    let reward = Reward.decodeJSONDictionary([
      "id": 1,
      "description": "Some reward",
      "minimum": 10,
      "converted_minimum": 12,
      "backers_count": 10,
      "shipping_enabled": true,
      "shipping_preference": "unrestricted",
      "shipping_summary": "Ships anywhere in the world."
    ])

    XCTAssertNotNil(reward)
    XCTAssertEqual(reward.value?.id, 1)
    XCTAssertEqual(reward.value?.description, "Some reward")
    XCTAssertEqual(reward.value?.minimum, 10)
    XCTAssertEqual(reward.value?.convertedMinimum, 12)
    XCTAssertEqual(reward.value?.backersCount, 10)
    XCTAssertEqual(true, reward.value?.shipping.enabled)
    XCTAssertEqual(.unrestricted, reward.value?.shipping.preference)
    XCTAssertEqual("Ships anywhere in the world.", reward.value?.shipping.summary)
  }

  func testJsonDecoding_WithShippingType_Anywhere() {
    let reward = Reward.decodeJSONDictionary([
      "id": 1,
      "description": "Some reward",
      "minimum": 10,
      "converted_minimum": 12,
      "backers_count": 10,
      "shipping_enabled": true,
      "shipping_type": "anywhere"
    ])

    XCTAssertNotNil(reward)
    XCTAssertEqual(reward.value?.id, 1)
    XCTAssertEqual(reward.value?.description, "Some reward")
    XCTAssertEqual(reward.value?.minimum, 10)
    XCTAssertEqual(reward.value?.convertedMinimum, 12)
    XCTAssertEqual(reward.value?.backersCount, 10)
    XCTAssertEqual(true, reward.value?.shipping.enabled)
    XCTAssertEqual(.anywhere, reward.value?.shipping.type)
  }

  func testJsonDecoding_WithShippingType_SingleLocation() {
    let reward = Reward.decodeJSONDictionary([
      "id": 1,
      "description": "Some reward",
      "minimum": 10,
      "converted_minimum": 12,
      "backers_count": 10,
      "shipping_enabled": true,
      "shipping_type": "single_location",
      "shipping_single_location": [
        "id": 123,
        "localized_name": "United States"
      ]
    ])

    XCTAssertNotNil(reward)
    XCTAssertEqual(reward.value?.id, 1)
    XCTAssertEqual(reward.value?.description, "Some reward")
    XCTAssertEqual(reward.value?.minimum, 10)
    XCTAssertEqual(reward.value?.convertedMinimum, 12)
    XCTAssertEqual(reward.value?.backersCount, 10)
    XCTAssertEqual(true, reward.value?.shipping.enabled)
    XCTAssertEqual(.singleLocation, reward.value?.shipping.type)
    XCTAssertEqual(.init(id: 123, localizedName: "United States"), reward.value?.shipping.location)
  }

  func testJsonDecoding_WithShippingType_MultipleLocations() {
    let reward = Reward.decodeJSONDictionary([
      "id": 1,
      "description": "Some reward",
      "minimum": 10,
      "converted_minimum": 12,
      "backers_count": 10,
      "shipping_enabled": true,
      "shipping_type": "multiple_locations"
    ])

    XCTAssertNotNil(reward)
    XCTAssertEqual(reward.value?.id, 1)
    XCTAssertEqual(reward.value?.description, "Some reward")
    XCTAssertEqual(reward.value?.minimum, 10)
    XCTAssertEqual(reward.value?.convertedMinimum, 12)
    XCTAssertEqual(reward.value?.backersCount, 10)
    XCTAssertEqual(true, reward.value?.shipping.enabled)
    XCTAssertEqual(.multipleLocations, reward.value?.shipping.type)
  }

  func testJsonDecoding_WithShippingType_NoShipping() {
    let reward = Reward.decodeJSONDictionary([
      "id": 1,
      "description": "Some reward",
      "minimum": 10,
      "converted_minimum": 12,
      "backers_count": 10,
      "shipping_enabled": false,
      "shipping_type": "no_shipping"
    ])

    XCTAssertNotNil(reward)
    XCTAssertEqual(reward.value?.id, 1)
    XCTAssertEqual(reward.value?.description, "Some reward")
    XCTAssertEqual(reward.value?.minimum, 10)
    XCTAssertEqual(reward.value?.convertedMinimum, 12)
    XCTAssertEqual(reward.value?.backersCount, 10)
    XCTAssertEqual(false, reward.value?.shipping.enabled)
    XCTAssertEqual(.noShipping, reward.value?.shipping.type)
  }
}
