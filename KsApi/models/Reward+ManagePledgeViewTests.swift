@testable import KsApi
import XCTest

final class Reward_ManagePledgeViewTests: XCTestCase {
  func test() {
    let env = ManagePledgeViewBackingEnvelope.template

    guard let reward = env.backing.reward else {
      XCTFail("Should have a reward")
      return
    }

    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    dateFormatter.dateFormat = "yyyy-MM-DD"

    let v1Reward = Reward.addOnReward(
      from: reward,
      project: .template,
      selectedAddOnQuantities: [reward.id: 5],
      dateFormatter: dateFormatter
    )

    XCTAssertNotNil(v1Reward)
    XCTAssertEqual(v1Reward?.addOnData?.isAddOn, true)
    XCTAssertEqual(v1Reward?.addOnData?.selectedQuantity, 5)
    XCTAssertEqual(v1Reward?.backersCount, 55)
    XCTAssertEqual(v1Reward?.convertedMinimum, 239.0)
    XCTAssertEqual(v1Reward?.description, "Description")
    XCTAssertEqual(v1Reward?.endsAt, 1_887_502_131)
    XCTAssertEqual(v1Reward?.estimatedDeliveryOn, 1_577_836_800.0)
    XCTAssertEqual(v1Reward?.id, 1)
    XCTAssertEqual(v1Reward?.limit, 5)
    XCTAssertEqual(v1Reward?.minimum, 159.0)
    XCTAssertEqual(v1Reward?.remaining, 10)
    XCTAssertEqual(v1Reward?.rewardsItems[0].item.id, 432)
    XCTAssertEqual(v1Reward?.rewardsItems[0].item.name, "Item 1")
    XCTAssertEqual(v1Reward?.rewardsItems[1].item.id, 442)
    XCTAssertEqual(v1Reward?.rewardsItems[1].item.name, "Item 2")

    XCTAssertEqual(v1Reward?.shipping.enabled, true)
    XCTAssertEqual(v1Reward?.startsAt, 1_487_502_131)
    XCTAssertEqual(v1Reward?.title, "Reward name")
  }
}
