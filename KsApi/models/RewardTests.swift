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
    let reward: Reward! = Reward.decodeJSONDictionary([
      "id": 1,
      "minimum": 10,
      "converted_minimum": 12,
      "description": "cool stuff"
    ])

    XCTAssertNotNil(reward)
    XCTAssertEqual(reward.id, 1)
    XCTAssertEqual(reward.minimum, 10)
    XCTAssertEqual(reward.convertedMinimum, 12)
    XCTAssertEqual(reward.description, "cool stuff")
    XCTAssertNotNil(reward.shipping)
    XCTAssertEqual(false, reward.shipping.enabled)
  }

  func testJsonParsing_WithMinimalData_AndReward() {
    let reward: Reward! = Reward.decodeJSONDictionary([
      "id": 1,
      "minimum": 10,
      "converted_minimum": 12,
      "reward": "cool stuff"
    ])

    XCTAssertNotNil(reward)
    XCTAssertEqual(reward.id, 1)
    XCTAssertEqual(reward.minimum, 10)
    XCTAssertEqual(reward.convertedMinimum, 12)
    XCTAssertEqual(reward.description, "cool stuff")
  }

  func testJsonParsing_WithFullData() {
    let reward: Reward! = Reward.decodeJSONDictionary([
      "id": 1,
      "description": "Some reward",
      "minimum": 10,
      "converted_minimum": 12,
      "backers_count": 10
    ])

    XCTAssertNotNil(reward)
    XCTAssertEqual(reward.id, 1)
    XCTAssertEqual(reward.description, "Some reward")
    XCTAssertEqual(reward.minimum, 10)
    XCTAssertEqual(reward.convertedMinimum, 12)
    XCTAssertEqual(reward.backersCount, 10)
  }

  func testJsonDecoding_WithShipping() {
    let reward: Reward! = Reward.decodeJSONDictionary([
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
    XCTAssertEqual(reward.id, 1)
    XCTAssertEqual(reward.description, "Some reward")
    XCTAssertEqual(reward.minimum, 10)
    XCTAssertEqual(reward.convertedMinimum, 12)
    XCTAssertEqual(reward.backersCount, 10)
    XCTAssertEqual(true, reward.shipping.enabled)
    XCTAssertEqual(.unrestricted, reward.shipping.preference)
    XCTAssertEqual("Ships anywhere in the world.", reward.shipping.summary)
  }

  func testJsonDecoding_WithShippingType_Anywhere() {
    let reward: Reward! = Reward.decodeJSONDictionary([
      "id": 1,
      "description": "Some reward",
      "minimum": 10,
      "converted_minimum": 12,
      "backers_count": 10,
      "shipping_enabled": true,
      "shipping_type": "anywhere"
    ])

    XCTAssertNotNil(reward)
    XCTAssertEqual(reward.id, 1)
    XCTAssertEqual(reward.description, "Some reward")
    XCTAssertEqual(reward.minimum, 10)
    XCTAssertEqual(reward.convertedMinimum, 12)
    XCTAssertEqual(reward.backersCount, 10)
    XCTAssertEqual(true, reward.shipping.enabled)
    XCTAssertEqual(.anywhere, reward.shipping.type)
  }

  func testJsonDecoding_WithShippingType_SingleLocation() {
    let reward: Reward! = Reward.decodeJSONDictionary([
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
    XCTAssertEqual(reward.id, 1)
    XCTAssertEqual(reward.description, "Some reward")
    XCTAssertEqual(reward.minimum, 10)
    XCTAssertEqual(reward.convertedMinimum, 12)
    XCTAssertEqual(reward.backersCount, 10)
    XCTAssertEqual(true, reward.shipping.enabled)
    XCTAssertEqual(.singleLocation, reward.shipping.type)
    XCTAssertEqual(.init(id: 123, localizedName: "United States"), reward.shipping.location)
  }

  func testJsonDecoding_WithShippingType_MultipleLocations() {
    let reward: Reward! = Reward.decodeJSONDictionary([
      "id": 1,
      "description": "Some reward",
      "minimum": 10,
      "converted_minimum": 12,
      "backers_count": 10,
      "shipping_enabled": true,
      "shipping_type": "multiple_locations"
    ])

    XCTAssertNotNil(reward)
    XCTAssertEqual(reward.id, 1)
    XCTAssertEqual(reward.description, "Some reward")
    XCTAssertEqual(reward.minimum, 10)
    XCTAssertEqual(reward.convertedMinimum, 12)
    XCTAssertEqual(reward.backersCount, 10)
    XCTAssertEqual(true, reward.shipping.enabled)
    XCTAssertEqual(.multipleLocations, reward.shipping.type)
  }

  func testJsonDecoding_WithShippingType_NoShipping() {
    let reward: Reward! = Reward.decodeJSONDictionary([
      "id": 1,
      "description": "Some reward",
      "minimum": 10,
      "converted_minimum": 12,
      "backers_count": 10,
      "shipping_enabled": false,
      "shipping_type": "no_shipping"
    ])

    XCTAssertNotNil(reward)
    XCTAssertEqual(reward.id, 1)
    XCTAssertEqual(reward.description, "Some reward")
    XCTAssertEqual(reward.minimum, 10)
    XCTAssertEqual(reward.convertedMinimum, 12)
    XCTAssertEqual(reward.backersCount, 10)
    XCTAssertEqual(false, reward.shipping.enabled)
    XCTAssertEqual(.noShipping, reward.shipping.type)
  }

  func testRewardShippingRule_Match() {
    let shippingRule1 = ShippingRule.template
      |> ShippingRule.lens.cost .~ 5.0
      |> ShippingRule.lens.location .~ (.template |> Location.lens.id .~ 1)
    let shippingRule2 = ShippingRule.template
      |> ShippingRule.lens.cost .~ 1.0
      |> ShippingRule.lens.location .~ (.template |> Location.lens.id .~ 2)
    let reward = Reward.template
      |> Reward.lens.shippingRules .~ [shippingRule1, shippingRule2]

    let match = ShippingRule.template
      |> ShippingRule.lens.cost .~ 500.0
      |> ShippingRule.lens.location .~ (.template |> Location.lens.id .~ 1)

    XCTAssertEqual(reward.shippingRule(matching: match), shippingRule1)
  }

  func testRewardShippingRuleExpanded_Match() {
    let shippingRule1 = ShippingRule.template
      |> ShippingRule.lens.cost .~ 5.0
      |> ShippingRule.lens.location .~ (.template |> Location.lens.id .~ 1)
    let shippingRule2 = ShippingRule.template
      |> ShippingRule.lens.cost .~ 1.0
      |> ShippingRule.lens.location .~ (.template |> Location.lens.id .~ 2)
    let reward = Reward.template
      |> Reward.lens.shippingRulesExpanded .~ [shippingRule1, shippingRule2]

    let match = ShippingRule.template
      |> ShippingRule.lens.cost .~ 500.0
      |> ShippingRule.lens.location .~ (.template |> Location.lens.id .~ 1)

    XCTAssertEqual(reward.shippingRule(matching: match), shippingRule1)
  }

  func testRewardShippingRule_NoMatch() {
    let shippingRule1 = ShippingRule.template
      |> ShippingRule.lens.cost .~ 5.0
      |> ShippingRule.lens.location .~ (.template |> Location.lens.id .~ 5)
    let shippingRule2 = ShippingRule.template
      |> ShippingRule.lens.cost .~ 1.0
      |> ShippingRule.lens.location .~ (.template |> Location.lens.id .~ 2)
    let reward = Reward.template
      |> Reward.lens.shippingRulesExpanded .~ [shippingRule1, shippingRule2]

    let match = ShippingRule.template
      |> ShippingRule.lens.cost .~ 500.0
      |> ShippingRule.lens.location .~ (.template |> Location.lens.id .~ 1)

    XCTAssertEqual(reward.shippingRule(matching: match), match)
  }
}
