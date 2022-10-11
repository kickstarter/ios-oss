@testable import KsApi
@testable import Library
import Prelude
import XCTest

final class UpdateBackingInput_ConstructorTests: TestCase {
  func testUpdateBackingInput_UpdateBackingData_NotApplePay_NotPaymentSource() {
    let reward = Reward.template

    let data: UpdateBackingData = (
      backing: Backing.template,
      rewards: [reward],
      pledgeTotal: 105,
      selectedQuantities: [reward.id: 1],
      shippingRule: ShippingRule.template,
      paymentSourceId: nil,
      setupIntentClientSecret: "seti_1Lq2At4VvJ2PtfhKRtPWTnKh_secret_MZAVRP2SXO5bvZzZ2bi1W7o5Wsz4BuN",
      applePayParams: nil
    )

    let input = UpdateBackingInput.input(from: data, isApplePay: false)

    XCTAssertEqual(input.amount, "105.00")
    XCTAssertNil(input.applePay)
    XCTAssertNil(input.paymentSourceId)
    XCTAssertEqual(input.id, "QmFja2luZy0x")
    XCTAssertEqual(input.locationId, "42")
    XCTAssertEqual(
      input.setupIntentClientSecret,
      "seti_1Lq2At4VvJ2PtfhKRtPWTnKh_secret_MZAVRP2SXO5bvZzZ2bi1W7o5Wsz4BuN"
    )
    XCTAssertEqual(input.rewardIds, ["UmV3YXJkLTE="])
  }

  func testUpdateBackingInput_UpdateBackingData_NotApplePay() {
    let applePayParams = ApplePayParams(
      paymentInstrumentName: "paymentInstrumentName",
      paymentNetwork: "paymentNetwork",
      transactionIdentifier: "transactionIdentifier",
      token: "token"
    )

    let reward = Reward.template

    let data: UpdateBackingData = (
      backing: Backing.template,
      rewards: [reward],
      pledgeTotal: 105,
      selectedQuantities: [reward.id: 1],
      shippingRule: ShippingRule.template,
      paymentSourceId: UserCreditCards.amex.id,
      setupIntentClientSecret: nil,
      applePayParams: applePayParams
    )

    let input = UpdateBackingInput.input(from: data, isApplePay: false)

    XCTAssertEqual(input.amount, "105.00")
    XCTAssertNil(input.applePay)
    XCTAssertEqual(input.id, "QmFja2luZy0x")
    XCTAssertEqual(input.locationId, "42")
    XCTAssertEqual(input.paymentSourceId, "6")
    XCTAssertEqual(input.rewardIds, ["UmV3YXJkLTE="])
  }

  func testUpdateBackingInput_UpdateBackingData_IsApplePay() {
    let applePayParams = ApplePayParams(
      paymentInstrumentName: "paymentInstrumentName",
      paymentNetwork: "paymentNetwork",
      transactionIdentifier: "transactionIdentifier",
      token: "token"
    )

    let reward = Reward.template

    let data: UpdateBackingData = (
      backing: Backing.template,
      rewards: [reward],
      pledgeTotal: 105,
      selectedQuantities: [reward.id: 1],
      shippingRule: ShippingRule.template,
      paymentSourceId: UserCreditCards.amex.id,
      setupIntentClientSecret: nil,
      applePayParams: applePayParams
    )

    let input = UpdateBackingInput.input(from: data, isApplePay: true)

    XCTAssertEqual(input.amount, "105.00")
    XCTAssertEqual(input.applePay, applePayParams)
    XCTAssertEqual(input.id, "QmFja2luZy0x")
    XCTAssertEqual(input.locationId, "42")
    XCTAssertNil(input.paymentSourceId)
    XCTAssertEqual(input.rewardIds, ["UmV3YXJkLTE="])
  }

  func testUpdateBackingInput_WithShipping_RefTag_HasAddOns() {
    let reward = Reward.template
    let shippingRule = ShippingRule.template
      |> ShippingRule.lens.location .. Location.lens.id .~ 1
      |> ShippingRule.lens.cost .~ 5.0

    let applePayParams = ApplePayParams(
      paymentInstrumentName: "paymentInstrumentName",
      paymentNetwork: "paymentNetwork",
      transactionIdentifier: "transactionIdentifier",
      token: "token"
    )

    let addOn1 = Reward.template
      |> Reward.lens.id .~ 2
    let addOn2 = Reward.template
      |> Reward.lens.id .~ 3

    let data: UpdateBackingData = (
      backing: Backing.template,
      rewards: [reward, addOn1, addOn2],
      pledgeTotal: 15,
      selectedQuantities: [reward.id: 1, addOn1.id: 2, addOn2.id: 3],
      shippingRule: shippingRule,
      paymentSourceId: "123",
      setupIntentClientSecret: nil,
      applePayParams: applePayParams
    )

    let input = UpdateBackingInput.input(from: data, isApplePay: true)

    XCTAssertEqual(input.amount, "15.00")
    XCTAssertEqual(input.applePay, applePayParams)
    XCTAssertEqual(input.locationId, "1")
    XCTAssertEqual(input.id, "QmFja2luZy0x")
    XCTAssertEqual(
      input.rewardIds,
      ["UmV3YXJkLTE=", "UmV3YXJkLTI=", "UmV3YXJkLTI=", "UmV3YXJkLTM=", "UmV3YXJkLTM=", "UmV3YXJkLTM="]
    )
    XCTAssertNil(input.paymentSourceId)
  }
}
