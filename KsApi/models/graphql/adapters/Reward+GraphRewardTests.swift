@testable import KsApi
import Prelude
import XCTest

final class Reward_GraphRewardTests: XCTestCase {
  func test() {
    let shippingReward = GraphReward.template
      |> \.shippingPreference .~ .restricted
    let backing = GraphBacking.template
      |> \.reward .~ shippingReward

    guard let reward = backing.reward else {
      XCTFail("Should have a reward")
      return
    }

    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    dateFormatter.dateFormat = "yyyy-MM-DD"

    let v1Reward = Reward.reward(
      from: reward,
      projectId: Project.template.id,
      dateFormatter: dateFormatter
    )

    XCTAssertNotNil(v1Reward)
    XCTAssertEqual(v1Reward?.backersCount, 55)
    XCTAssertEqual(v1Reward?.convertedMinimum, 180.0)
    XCTAssertEqual(v1Reward?.description, "Description")
    XCTAssertEqual(v1Reward?.endsAt, 1_887_502_131)
    XCTAssertEqual(v1Reward?.estimatedDeliveryOn, 1_577_836_800.0)
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
  }

  func testTemplate() {
    XCTAssertNotNil(Reward.reward(from: .template, projectId: 12_345))
  }
}
