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

    let data = CreateBackingData(
      project: project,
      rewards: [reward],
      pledgeTotal: 10,
      selectedQuantities: [reward.id: 1],
      shippingRule: nil,
      paymentSourceId: UserCreditCards.amex.id,
      setupIntentClientSecret: nil,
      applePayParams: applePayParams,
      refTag: RefTag.projectPage
    )

    let input = CreateBackingInput.input(from: data, isApplePay: false)

    XCTAssertEqual(input.amount, "10.00")
    XCTAssertNil(input.applePay)
    XCTAssertNil(input.locationId)
    XCTAssertEqual(input.projectId, "UHJvamVjdC0x")
    XCTAssertEqual(input.rewardIds, ["UmV3YXJkLTA="])
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
      rewards: [reward],
      pledgeTotal: 15,
      selectedQuantities: [reward.id: 1],
      shippingRule: shippingRule,
      paymentSourceId: "123",
      setupIntentClientSecret: "xyz",
      applePayParams: applePayParams,
      refTag: nil
    )

    let input = CreateBackingInput.input(from: data, isApplePay: true)

    XCTAssertEqual(input.amount, "15.00")
    XCTAssertEqual(input.applePay, applePayParams)
    XCTAssertEqual(input.locationId, "1")
    XCTAssertEqual(input.projectId, "UHJvamVjdC0x")
    XCTAssertEqual(input.rewardIds, ["UmV3YXJkLTE="])
    XCTAssertNil(input.paymentSourceId)
    XCTAssertNil(input.refParam)
  }

  func testCreateBackingInput_WithShipping_RefTag_HasAddOns() {
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

    let addOn1 = Reward.template
      |> Reward.lens.id .~ 2
    let addOn2 = Reward.template
      |> Reward.lens.id .~ 3

    let data: CreateBackingData = (
      project: project,
      rewards: [reward, addOn1, addOn2],
      pledgeTotal: 15,
      selectedQuantities: [reward.id: 1, addOn1.id: 2, addOn2.id: 3],
      shippingRule: shippingRule,
      paymentSourceId: "123",
      setupIntentClientSecret: "xyz",
      applePayParams: applePayParams,
      refTag: .discovery
    )

    let input = CreateBackingInput.input(from: data, isApplePay: true)

    XCTAssertEqual(input.amount, "15.00")
    XCTAssertEqual(input.applePay, applePayParams)
    XCTAssertEqual(input.locationId, "1")
    XCTAssertEqual(input.projectId, "UHJvamVjdC0x")
    XCTAssertEqual(
      input.rewardIds,
      ["UmV3YXJkLTE=", "UmV3YXJkLTI=", "UmV3YXJkLTI=", "UmV3YXJkLTM=", "UmV3YXJkLTM=", "UmV3YXJkLTM="]
    )
    XCTAssertNil(input.paymentSourceId)
    XCTAssertEqual(input.refParam, "discovery")
  }

  func testCreateBackingInput_WithApplePay_AndPaymentSource_AndSetupIntentClientSecret_OnlyApplePayIsValid_Success() {
    let applePayParams = ApplePayParams(
      paymentInstrumentName: "paymentInstrumentName",
      paymentNetwork: "paymentNetwork",
      transactionIdentifier: "transactionIdentifier",
      token: "token"
    )

    let data: CreateBackingData = (
      project: .template,
      rewards: [.noReward],
      pledgeTotal: 10,
      selectedQuantities: [Reward.noReward.id: 1],
      shippingRule: nil,
      paymentSourceId: UserCreditCards.amex.id,
      setupIntentClientSecret: "xyz",
      applePayParams: applePayParams,
      refTag: RefTag.projectPage
    )

    let input = CreateBackingInput.input(from: data, isApplePay: true)

    XCTAssertNotNil(input.applePay)
    XCTAssertNil(input.paymentSourceId)
    XCTAssertNil(input.setupIntentClientSecret)
  }

  func testCreateBackingInput_WithNoApplePay_AndPaymentSource_AndSetupIntentClientSecret_OnlyPaymentSourceIsValid_Success() {
    let data: CreateBackingData = (
      project: .template,
      rewards: [.noReward],
      pledgeTotal: 10,
      selectedQuantities: [Reward.noReward.id: 1],
      shippingRule: nil,
      paymentSourceId: UserCreditCards.amex.id,
      setupIntentClientSecret: nil,
      applePayParams: nil,
      refTag: RefTag.projectPage
    )

    let input = CreateBackingInput.input(from: data, isApplePay: false)

    XCTAssertNil(input.applePay)
    XCTAssertEqual(input.paymentSourceId, UserCreditCards.amex.id)
    XCTAssertNil(input.setupIntentClientSecret)
  }

  func testCreateBackingInput_WithNoApplePay_NoPaymentSource_AndSetupIntentClientSecret_OnlySetupIntentClientSecretIsValid_Success() {
    let data: CreateBackingData = (
      project: .template,
      rewards: [.noReward],
      pledgeTotal: 10,
      selectedQuantities: [Reward.noReward.id: 1],
      shippingRule: nil,
      paymentSourceId: nil,
      setupIntentClientSecret: "xyz",
      applePayParams: nil,
      refTag: RefTag.projectPage
    )

    let input = CreateBackingInput.input(from: data, isApplePay: false)

    XCTAssertNil(input.applePay)
    XCTAssertNil(input.paymentSourceId)
    XCTAssertEqual(input.setupIntentClientSecret, "xyz")
  }
}
