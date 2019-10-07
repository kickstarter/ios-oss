@testable import KsApi
@testable import Library
import XCTest

final class UpdateBackingInput_ConstructorTests: TestCase {
  func testUpdateBackingInput_UpdateBackingData() {
    let data: UpdateBackingData = (
      backing: Backing.template,
      reward: Reward.template,
      pledgeAmount: 100,
      shippingRule: ShippingRule.template
    )
    let input = UpdateBackingInput.input(from: data)

    XCTAssertEqual(input.amount, "105.00")
    XCTAssertNil(input.applePay)
    XCTAssertEqual(input.id, "QmFja2luZy0x")
    XCTAssertEqual(input.locationId, "42")
    XCTAssertNil(input.paymentSourceId)
    XCTAssertEqual(input.rewardId, "UmV3YXJkLTE=")
  }
}
