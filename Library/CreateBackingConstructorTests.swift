import Foundation
@testable import KsApi
@testable import Library
import Prelude
import XCTest

final class CreateBackingInputConstructorTests: XCTestCase {
  func testCreateBackingInput_NoShipping_NotApplePay() {
    let project = Project.template
    let reward = Reward.noReward

    let applePayParams = ApplePayParams(
      paymentInstrumentName: "paymentInstrumentName",
      paymentNetwork: "paymentNetwork",
      transactionIdentifier: "transactionIdentifier",
      token: "token"
    )

    let data: CreateBackingData = (
      project: project,
      reward: reward,
      pledgeAmount: 10,
      shippingRule: nil,
      paymentSourceId: GraphUserCreditCard.amex.id,
      applePayParams: applePayParams,
      refTag: RefTag.projectPage
    )

    let input = CreateBackingInput.input(from: data, isApplePay: false)

    XCTAssertEqual(input.amount, "10.00")
    XCTAssertNil(input.applePay)
    XCTAssertNil(input.locationId)
    XCTAssertEqual(input.projectId, "UHJvamVjdC0x")
    XCTAssertEqual(input.rewardId, "UmV3YXJkLTA=")
    XCTAssertEqual(input.paymentSourceId, "6")
    XCTAssertEqual(input.refParam, "project_page")
  }

  func testCreateBackingInput_WithShipping_RefTagNil_IsApplePay() {
    let project = Project.template
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

    let data: CreateBackingData = (
      project: project,
      reward: reward,
      pledgeAmount: 10,
      shippingRule: shippingRule,
      paymentSourceId: "123",
      applePayParams: applePayParams,
      refTag: nil
    )

    let input = CreateBackingInput.input(from: data, isApplePay: true)

    XCTAssertEqual(input.amount, "15.00")
    XCTAssertEqual(input.applePay, applePayParams)
    XCTAssertEqual(input.locationId, "1")
    XCTAssertEqual(input.projectId, "UHJvamVjdC0x")
    XCTAssertEqual(input.rewardId, "UmV3YXJkLTE=")
    XCTAssertNil(input.paymentSourceId)
    XCTAssertNil(input.refParam)
  }
}
