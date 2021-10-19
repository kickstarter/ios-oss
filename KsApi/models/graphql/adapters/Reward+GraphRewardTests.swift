@testable import KsApi
import Prelude
import XCTest

final class Reward_GraphRewardTests: XCTestCase {
  var dateFormatter: DateFormatter {
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    dateFormatter.dateFormat = "yyyy-MM-dd"

    return dateFormatter
  }

  func test() {
    let shippingReward = GraphReward.template
      |> \.shippingPreference .~ .restricted
    let backing = GraphBacking.template
      |> \.reward .~ shippingReward

    guard let reward = backing.reward else {
      XCTFail("Should have a reward")
      return
    }

    let v1Reward = Reward.reward(
      from: reward,
      projectId: Project.template.id,
      dateFormatter: self.dateFormatter
    )

    XCTAssertNotNil(v1Reward)
    XCTAssertEqual(v1Reward?.backersCount, 55)
    XCTAssertEqual(v1Reward?.convertedMinimum, 180.0)
    XCTAssertEqual(v1Reward?.description, "Description")
    XCTAssertEqual(v1Reward?.endsAt, 1_887_502_131)
    XCTAssertEqual(v1Reward?.estimatedDeliveryOn, 1_596_240_000.0)
    XCTAssertEqual(v1Reward?.id, 1)
    XCTAssertEqual(v1Reward?.limit, 5)
    XCTAssertEqual(v1Reward?.minimum, 159.0)
    XCTAssertEqual(v1Reward?.remaining, 10)
    XCTAssertEqual(v1Reward?.rewardsItems[0].item.id, 921_095)
    XCTAssertEqual(v1Reward?.rewardsItems[0].item.name, "Item 1")
    XCTAssertEqual(v1Reward?.rewardsItems[1].item.id, 921_093)
    XCTAssertEqual(v1Reward?.rewardsItems[1].item.name, "Item 2")

    XCTAssertEqual(v1Reward?.shipping.enabled, true)
    XCTAssertEqual(v1Reward?.shipping.preference, .restricted)
    XCTAssertEqual(v1Reward?.startsAt, 1_487_502_131)
    XCTAssertEqual(v1Reward?.title, "Reward name")

    XCTAssertEqual(v1Reward?.isLimitedQuantity, true)
    XCTAssertEqual(v1Reward?.isLimitedTime, true)
  }

  func test_isLimited_False() {
    let shippingReward = GraphReward.template
      |> \.shippingPreference .~ .restricted
      |> \.limit .~ nil
      |> \.endsAt .~ nil
    let backing = GraphBacking.template
      |> \.reward .~ shippingReward

    guard let reward = backing.reward else {
      XCTFail("Should have a reward")
      return
    }

    let v1Reward = Reward.reward(
      from: reward,
      projectId: Project.template.id,
      dateFormatter: self.dateFormatter
    )

    XCTAssertNotNil(v1Reward)
    XCTAssertEqual(v1Reward?.backersCount, 55)
    XCTAssertEqual(v1Reward?.convertedMinimum, 180.0)
    XCTAssertEqual(v1Reward?.description, "Description")
    XCTAssertEqual(v1Reward?.endsAt, nil)
    XCTAssertEqual(v1Reward?.estimatedDeliveryOn, 1_596_240_000.0)
    XCTAssertEqual(v1Reward?.id, 1)
    XCTAssertEqual(v1Reward?.limit, nil)
    XCTAssertEqual(v1Reward?.minimum, 159.0)
    XCTAssertEqual(v1Reward?.remaining, 10)
    XCTAssertEqual(v1Reward?.rewardsItems[0].item.id, 921_095)
    XCTAssertEqual(v1Reward?.rewardsItems[0].item.name, "Item 1")
    XCTAssertEqual(v1Reward?.rewardsItems[1].item.id, 921_093)
    XCTAssertEqual(v1Reward?.rewardsItems[1].item.name, "Item 2")

    XCTAssertEqual(v1Reward?.shipping.enabled, true)
    XCTAssertEqual(v1Reward?.shipping.preference, .restricted)
    XCTAssertEqual(v1Reward?.startsAt, 1_487_502_131)
    XCTAssertEqual(v1Reward?.title, "Reward name")

    XCTAssertEqual(v1Reward?.isLimitedQuantity, false)
    XCTAssertEqual(v1Reward?.isLimitedTime, false)
  }

  func test_shippingPreference_None() {
    let shippingReward = GraphReward.template
      |> \.shippingPreference .~ .noShipping
    let backing = GraphBacking.template
      |> \.reward .~ shippingReward

    guard let reward = backing.reward else {
      XCTFail("Should have a reward")
      return
    }

    let v1Reward = Reward.reward(
      from: reward,
      projectId: Project.template.id,
      dateFormatter: self.dateFormatter
    )

    XCTAssertNotNil(v1Reward)
    XCTAssertEqual(v1Reward?.shipping.preference, Reward.Shipping.Preference.none)
  }

  func test_shippingPreference_Unrestricted() {
    let shippingReward = GraphReward.template
      |> \.shippingPreference .~ .unrestricted
    let backing = GraphBacking.template
      |> \.reward .~ shippingReward

    guard let reward = backing.reward else {
      XCTFail("Should have a reward")
      return
    }

    let v1Reward = Reward.reward(
      from: reward,
      projectId: Project.template.id,
      dateFormatter: self.dateFormatter
    )

    XCTAssertNotNil(v1Reward)
    XCTAssertEqual(v1Reward?.shipping.preference, .unrestricted)
  }

  func test_shippingPreference_Restricted() {
    let shippingReward = GraphReward.template
      |> \.shippingPreference .~ .restricted
    let backing = GraphBacking.template
      |> \.reward .~ shippingReward

    guard let reward = backing.reward else {
      XCTFail("Should have a reward")
      return
    }

    let v1Reward = Reward.reward(
      from: reward,
      projectId: Project.template.id,
      dateFormatter: self.dateFormatter
    )

    XCTAssertNotNil(v1Reward)
    XCTAssertEqual(v1Reward?.shipping.preference, .restricted)
  }

  func test_shippingPreference_Nil() {
    let shippingReward = GraphReward.template
      |> \.shippingPreference .~ nil
    let backing = GraphBacking.template
      |> \.reward .~ shippingReward

    guard let reward = backing.reward else {
      XCTFail("Should have a reward")
      return
    }

    let v1Reward = Reward.reward(
      from: reward,
      projectId: Project.template.id,
      dateFormatter: self.dateFormatter
    )

    XCTAssertNotNil(v1Reward)
    XCTAssertEqual(v1Reward?.shipping.preference, Reward.Shipping.Preference.none)
  }

  func test_rewardNoValidId_Fails() {
    let shippingReward = GraphReward.template
      |> \.id .~ ""
      |> \.shippingPreference .~ .restricted
    let backing = GraphBacking.template
      |> \.reward .~ shippingReward

    guard let reward = backing.reward else {
      XCTFail("Should have a reward")
      return
    }

    let v1Reward = Reward.reward(
      from: reward,
      projectId: Project.template.id,
      dateFormatter: self.dateFormatter
    )

    XCTAssertNil(v1Reward)
  }

  func test_rewardItems_IsEmpty() {
    let shippingReward = GraphReward.template
      |> \.shippingPreference .~ .restricted
      |> \.items .~ GraphReward.Items(nodes: [])
    let backing = GraphBacking.template
      |> \.reward .~ shippingReward

    guard let reward = backing.reward else {
      XCTFail("Should have a reward")
      return
    }

    let v1Reward = Reward.reward(
      from: reward,
      projectId: Project.template.id,
      dateFormatter: self.dateFormatter
    )

    guard let rewardItems = v1Reward?.rewardsItems else {
      XCTFail("Should have a reward")
      return
    }

    XCTAssertTrue(rewardItems.isEmpty)
  }

  func test_rewardItemsWithInvalidIds_IsEmpty() {
    let shippingReward = GraphReward.template
      |> \.shippingPreference .~ .restricted
      |> \.items .~ GraphReward.Items(nodes: [
        .init(id: "", name: "Item 1"),
        .init(id: "", name: "Item 2")
      ])
    let backing = GraphBacking.template
      |> \.reward .~ shippingReward

    guard let reward = backing.reward else {
      XCTFail("Should have a reward")
      return
    }

    let v1Reward = Reward.reward(
      from: reward,
      projectId: Project.template.id,
      dateFormatter: self.dateFormatter
    )

    guard let rewardItems = v1Reward?.rewardsItems else {
      XCTFail("Should have a reward")
      return
    }

    XCTAssertTrue(rewardItems.isEmpty)
  }

  func test_rewardShippingRulesNone_IsEmpty() {
    let shippingReward = GraphReward.template
      |> \.shippingRules .~ []
    let backing = GraphBacking.template
      |> \.reward .~ shippingReward

    guard let reward = backing.reward else {
      XCTFail("Should have a reward")
      return
    }

    let v1Reward = Reward.reward(
      from: reward,
      projectId: Project.template.id,
      dateFormatter: self.dateFormatter
    )

    guard let rewardShippingRules = v1Reward?.shippingRules else {
      XCTFail("Should have a reward")
      return
    }

    XCTAssertTrue(rewardShippingRules.isEmpty)
  }

  func test_rewardShippingRulesWithInvalidLocationId_IsEmpty() {
    let shippingRule = GraphReward.ShippingRule.template
      |> \.location.id .~ ""
    let shippingReward = GraphReward.template
      |> \.shippingRules .~ [shippingRule]
    let backing = GraphBacking.template
      |> \.reward .~ shippingReward

    guard let reward = backing.reward else {
      XCTFail("Should have a reward")
      return
    }

    let v1Reward = Reward.reward(
      from: reward,
      projectId: Project.template.id,
      dateFormatter: self.dateFormatter
    )

    guard let rewardShippingRules = v1Reward?.shippingRules else {
      XCTFail("Should have a reward")
      return
    }

    XCTAssertTrue(rewardShippingRules.isEmpty)
  }

  func test_rewardShippingRulesNil_IsEmpty() {
    let shippingReward = GraphReward.template
      |> \.shippingRules .~ nil
    let backing = GraphBacking.template
      |> \.reward .~ shippingReward

    guard let reward = backing.reward else {
      XCTFail("Should have a reward")
      return
    }

    let v1Reward = Reward.reward(
      from: reward,
      projectId: Project.template.id,
      dateFormatter: self.dateFormatter
    )

    XCTAssertNil(v1Reward?.shippingRules)
  }

  func test_rewardShippingRulesExpandedWithInvalidLocationId_IsEmpty() {
    let shippingRule = GraphReward.ShippingRule.template
      |> \.location.id .~ ""
    let shippingReward = GraphReward.template
      |> \.shippingRulesExpanded .~ GraphReward.ShippingRuleExpanded.init(nodes: [shippingRule])
    let backing = GraphBacking.template
      |> \.reward .~ shippingReward

    guard let reward = backing.reward else {
      XCTFail("Should have a reward")
      return
    }

    let v1Reward = Reward.reward(
      from: reward,
      projectId: Project.template.id,
      dateFormatter: self.dateFormatter
    )

    guard let rewardShippingRulesExpanded = v1Reward?.shippingRulesExpanded else {
      XCTFail("Should have a reward")
      return
    }

    XCTAssertTrue(rewardShippingRulesExpanded.isEmpty)
  }

  func test_rewardShippingRulesExpandedNil_IsEmpty() {
    let shippingReward = GraphReward.template
      |> \.shippingRulesExpanded .~ nil
    let backing = GraphBacking.template
      |> \.reward .~ shippingReward

    guard let reward = backing.reward else {
      XCTFail("Should have a reward")
      return
    }

    let v1Reward = Reward.reward(
      from: reward,
      projectId: Project.template.id,
      dateFormatter: self.dateFormatter
    )

    XCTAssertNil(v1Reward?.shippingRulesExpanded)
  }

  func testTemplate() {
    let reward = Reward.reward(from: .template, projectId: 12_345)
    XCTAssertNotNil(reward)
    XCTAssertEqual(reward?.estimatedDeliveryOn, 1_596_240_000.0)
  }
}
