import Foundation
@testable import KsApi
@testable import Library
import PassKit
import Prelude
import XCTest

final class PKPaymentRequestHelpersTests: XCTestCase {
  func testPaymentRequest_NoShipping() {
    let project = Project.template
      |> Project.lens.country .~ .us
    let reward = Reward.noReward
    let merchantId = "merchant_id"

    let paymentRequest = PKPaymentRequest.paymentRequest(
      for: project,
      reward: reward,
      pledgeAmount: 100,
      selectedShippingRule: nil,
      merchantIdentifier: merchantId
    )

    XCTAssertEqual(paymentRequest.merchantIdentifier, merchantId)
    XCTAssertEqual(paymentRequest.merchantCapabilities, .capability3DS)
    XCTAssertEqual(paymentRequest.countryCode, "US")
    XCTAssertEqual(paymentRequest.currencyCode, "USD")
    XCTAssertEqual(paymentRequest.shippingType, .shipping)
    XCTAssertEqual(paymentRequest.paymentSummaryItems.count, 2)
    XCTAssertEqual(paymentRequest.paymentSummaryItems.first?.label, "The Project")
    XCTAssertEqual(paymentRequest.paymentSummaryItems.first?.amount.doubleValue, 100)
    XCTAssertEqual(paymentRequest.paymentSummaryItems.first?.type, .final)
    XCTAssertEqual(paymentRequest.paymentSummaryItems.last?.label, "Kickstarter (if funded)")
    XCTAssertEqual(paymentRequest.paymentSummaryItems.last?.amount.doubleValue, 100)
    XCTAssertEqual(paymentRequest.paymentSummaryItems.last?.type, .final)
  }

  func testPaymentRequest_WithShipping() {
    let project = Project.template
      |> Project.lens.country .~ .ca
    let reward = Reward.template
      |> Reward.lens.title .~ "A cool reward"
      |> Reward.lens.minimum .~ 5
    let shippingRule = ShippingRule.template
      |> ShippingRule.lens.cost .~ 6
    let merchantId = "merchant_id"

    let paymentRequest = PKPaymentRequest.paymentRequest(
      for: project,
      reward: reward,
      pledgeAmount: 5,
      selectedShippingRule: shippingRule,
      merchantIdentifier: merchantId
    )

    XCTAssertEqual(paymentRequest.merchantIdentifier, merchantId)
    XCTAssertEqual(paymentRequest.merchantCapabilities, .capability3DS)
    XCTAssertEqual(paymentRequest.countryCode, "CA")
    XCTAssertEqual(paymentRequest.currencyCode, "CAD")
    XCTAssertEqual(paymentRequest.shippingType, .shipping)
    XCTAssertEqual(paymentRequest.paymentSummaryItems.count, 3)
    XCTAssertEqual(paymentRequest.paymentSummaryItems.first?.label, "A cool reward")
    XCTAssertEqual(paymentRequest.paymentSummaryItems.first?.amount.doubleValue, 5)
    XCTAssertEqual(paymentRequest.paymentSummaryItems.first?.type, .final)
    XCTAssertEqual(paymentRequest.paymentSummaryItems[1].label, "Shipping")
    XCTAssertEqual(paymentRequest.paymentSummaryItems[1].amount.doubleValue, 6)
    XCTAssertEqual(paymentRequest.paymentSummaryItems[1].type, .final)
    XCTAssertEqual(paymentRequest.paymentSummaryItems.last?.label, "Kickstarter (if funded)")
    XCTAssertEqual(paymentRequest.paymentSummaryItems.last?.amount.doubleValue, 11)
    XCTAssertEqual(paymentRequest.paymentSummaryItems.last?.type, .final)
  }

  func testPaymentRequest_WithShipping_NonWholeNumberPledgeAmount() {
    let project = Project.template
      |> Project.lens.country .~ .ca
    let reward = Reward.template
      |> Reward.lens.title .~ "A cool reward"
      |> Reward.lens.minimum .~ 5
    let shippingRule = ShippingRule.template
      |> ShippingRule.lens.cost .~ 6
    let merchantId = "merchant_id"

    let paymentRequest = PKPaymentRequest.paymentRequest(
      for: project,
      reward: reward,
      pledgeAmount: 10.60,
      selectedShippingRule: shippingRule,
      merchantIdentifier: merchantId
    )

    XCTAssertEqual(paymentRequest.merchantIdentifier, merchantId)
    XCTAssertEqual(paymentRequest.merchantCapabilities, .capability3DS)
    XCTAssertEqual(paymentRequest.countryCode, "CA")
    XCTAssertEqual(paymentRequest.currencyCode, "CAD")
    XCTAssertEqual(paymentRequest.shippingType, .shipping)
    XCTAssertEqual(paymentRequest.paymentSummaryItems.count, 3)
    XCTAssertEqual(paymentRequest.paymentSummaryItems.first?.label, "A cool reward")
    XCTAssertEqual(paymentRequest.paymentSummaryItems.first?.amount.doubleValue, 10.60)
    XCTAssertEqual(paymentRequest.paymentSummaryItems.first?.type, .final)
    XCTAssertEqual(paymentRequest.paymentSummaryItems[1].label, "Shipping")
    XCTAssertEqual(paymentRequest.paymentSummaryItems[1].amount.doubleValue, 6)
    XCTAssertEqual(paymentRequest.paymentSummaryItems[1].type, .final)
    XCTAssertEqual(paymentRequest.paymentSummaryItems.last?.label, "Kickstarter (if funded)")
    XCTAssertEqual(paymentRequest.paymentSummaryItems.last?.amount.doubleValue, 16.60)
    XCTAssertEqual(paymentRequest.paymentSummaryItems.last?.type, .final)
  }
}
