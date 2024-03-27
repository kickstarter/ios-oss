import Foundation
@testable import KsApi
@testable import Library
import PassKit
import Prelude
import XCTest

final class PKPaymentRequestHelpersTests: XCTestCase {
  func testPaymentRequest_NoShipping() {
    var project = Project.template
    project.country = .us
    project.isInPostCampaignPledgingPhase = false

    let reward = Reward.noReward
    let merchantId = "merchant_id"

    let paymentRequest = PKPaymentRequest.paymentRequest(
      for: project,
      reward: reward,
      allRewardsTotal: 100,
      additionalPledgeAmount: 50,
      allRewardsShippingTotal: 0,
      merchantIdentifier: merchantId
    )

    XCTAssertEqual(paymentRequest.merchantIdentifier, merchantId)
    XCTAssertEqual(paymentRequest.merchantCapabilities, .capability3DS)
    XCTAssertEqual(paymentRequest.countryCode, "US")
    XCTAssertEqual(paymentRequest.currencyCode, "USD")
    XCTAssertEqual(paymentRequest.shippingType, .shipping)
    XCTAssertEqual(paymentRequest.paymentSummaryItems.count, 2)
    XCTAssertEqual(paymentRequest.paymentSummaryItems.first?.label, "Total")
    XCTAssertEqual(paymentRequest.paymentSummaryItems.first?.amount.doubleValue, 50)
    XCTAssertEqual(paymentRequest.paymentSummaryItems.first?.type, .final)
    XCTAssertEqual(paymentRequest.paymentSummaryItems.last?.label, "Kickstarter (if funded)")
    XCTAssertEqual(paymentRequest.paymentSummaryItems.last?.amount.doubleValue, 50)
    XCTAssertEqual(paymentRequest.paymentSummaryItems.last?.type, .final)
  }

  func testPaymentRequest_WithShipping() {
    var project = Project.template
    project.country = .ca
    project.stats.currency = Project.Country.ca.currencyCode
    project.isInPostCampaignPledgingPhase = false

    let reward = Reward.template
      |> Reward.lens.title .~ "A cool reward"
      |> Reward.lens.minimum .~ 5
      |> Reward.lens.shipping.enabled .~ true
    let shippingRule = ShippingRule.template
      |> ShippingRule.lens.cost .~ 6
    let merchantId = "merchant_id"

    let paymentRequest = PKPaymentRequest.paymentRequest(
      for: project,
      reward: reward,
      allRewardsTotal: 5,
      additionalPledgeAmount: 50,
      allRewardsShippingTotal: shippingRule.cost,
      merchantIdentifier: merchantId
    )

    XCTAssertEqual(paymentRequest.merchantIdentifier, merchantId)
    XCTAssertEqual(paymentRequest.merchantCapabilities, .capability3DS)
    XCTAssertEqual(paymentRequest.countryCode, "CA")
    XCTAssertEqual(paymentRequest.currencyCode, "CAD")
    XCTAssertEqual(paymentRequest.shippingType, .shipping)
    XCTAssertEqual(paymentRequest.paymentSummaryItems.count, 4)
    XCTAssertEqual(paymentRequest.paymentSummaryItems[0].label, "Reward")
    XCTAssertEqual(paymentRequest.paymentSummaryItems[0].amount.doubleValue, 5)
    XCTAssertEqual(paymentRequest.paymentSummaryItems[0].type, .final)
    XCTAssertEqual(paymentRequest.paymentSummaryItems[1].label, "Bonus")
    XCTAssertEqual(paymentRequest.paymentSummaryItems[1].amount.doubleValue, 50)
    XCTAssertEqual(paymentRequest.paymentSummaryItems[1].type, .final)
    XCTAssertEqual(paymentRequest.paymentSummaryItems[2].label, "Shipping")
    XCTAssertEqual(paymentRequest.paymentSummaryItems[2].amount.doubleValue, 6)
    XCTAssertEqual(paymentRequest.paymentSummaryItems[2].type, .final)
    XCTAssertEqual(paymentRequest.paymentSummaryItems[3].label, "Kickstarter (if funded)")
    XCTAssertEqual(paymentRequest.paymentSummaryItems[3].amount.doubleValue, 61)
    XCTAssertEqual(paymentRequest.paymentSummaryItems[3].type, .final)
  }

  func testPaymentRequest_WithShipping_CountryDifferentFromCurrency() {
    var project = Project.template
    project.country = .ca
    project.stats.currency = Project.Country.us.currencyCode
    project.isInPostCampaignPledgingPhase = false

    let reward = Reward.template
      |> Reward.lens.title .~ "A cool reward"
      |> Reward.lens.minimum .~ 5
      |> Reward.lens.shipping.enabled .~ true
    let shippingRule = ShippingRule.template
      |> ShippingRule.lens.cost .~ 6
    let merchantId = "merchant_id"

    let paymentRequest = PKPaymentRequest.paymentRequest(
      for: project,
      reward: reward,
      allRewardsTotal: 5,
      additionalPledgeAmount: 50,
      allRewardsShippingTotal: shippingRule.cost,
      merchantIdentifier: merchantId
    )

    XCTAssertEqual(paymentRequest.merchantIdentifier, merchantId)
    XCTAssertEqual(paymentRequest.merchantCapabilities, .capability3DS)
    XCTAssertEqual(paymentRequest.countryCode, "CA")
    XCTAssertEqual(paymentRequest.currencyCode, "USD")
    XCTAssertEqual(paymentRequest.shippingType, .shipping)
    XCTAssertEqual(paymentRequest.paymentSummaryItems.count, 4)
    XCTAssertEqual(paymentRequest.paymentSummaryItems[0].label, "Reward")
    XCTAssertEqual(paymentRequest.paymentSummaryItems[0].amount.doubleValue, 5)
    XCTAssertEqual(paymentRequest.paymentSummaryItems[0].type, .final)
    XCTAssertEqual(paymentRequest.paymentSummaryItems[1].label, "Bonus")
    XCTAssertEqual(paymentRequest.paymentSummaryItems[1].amount.doubleValue, 50)
    XCTAssertEqual(paymentRequest.paymentSummaryItems[1].type, .final)
    XCTAssertEqual(paymentRequest.paymentSummaryItems[2].label, "Shipping")
    XCTAssertEqual(paymentRequest.paymentSummaryItems[2].amount.doubleValue, 6)
    XCTAssertEqual(paymentRequest.paymentSummaryItems[2].type, .final)
    XCTAssertEqual(paymentRequest.paymentSummaryItems[3].label, "Kickstarter (if funded)")
    XCTAssertEqual(paymentRequest.paymentSummaryItems[3].amount.doubleValue, 61)
    XCTAssertEqual(paymentRequest.paymentSummaryItems[3].type, .final)
  }

  func testPaymentRequest_WithShipping_NonWholeNumberPledgeAmount() {
    var project = Project.template
    project.country = .ca
    project.stats.currency = Project.Country.ca.currencyCode
    project.isInPostCampaignPledgingPhase = false

    let reward = Reward.template
      |> Reward.lens.title .~ "A cool reward"
      |> Reward.lens.minimum .~ 5
      |> Reward.lens.shipping.enabled .~ true
    let shippingRule = ShippingRule.template
      |> ShippingRule.lens.cost .~ 6
    let merchantId = "merchant_id"

    let paymentRequest = PKPaymentRequest.paymentRequest(
      for: project,
      reward: reward,
      allRewardsTotal: 10.60,
      additionalPledgeAmount: 20,
      allRewardsShippingTotal: shippingRule.cost,
      merchantIdentifier: merchantId
    )

    XCTAssertEqual(paymentRequest.merchantIdentifier, merchantId)
    XCTAssertEqual(paymentRequest.merchantCapabilities, .capability3DS)
    XCTAssertEqual(paymentRequest.countryCode, "CA")
    XCTAssertEqual(paymentRequest.currencyCode, "CAD")
    XCTAssertEqual(paymentRequest.shippingType, .shipping)
    XCTAssertEqual(paymentRequest.paymentSummaryItems.count, 4)
    XCTAssertEqual(paymentRequest.paymentSummaryItems[0].label, "Reward")
    XCTAssertEqual(paymentRequest.paymentSummaryItems[0].amount.doubleValue, 10.6)
    XCTAssertEqual(paymentRequest.paymentSummaryItems[0].type, .final)
    XCTAssertEqual(paymentRequest.paymentSummaryItems[1].label, "Bonus")
    XCTAssertEqual(paymentRequest.paymentSummaryItems[1].amount.doubleValue, 20)
    XCTAssertEqual(paymentRequest.paymentSummaryItems[1].type, .final)
    XCTAssertEqual(paymentRequest.paymentSummaryItems[2].label, "Shipping")
    XCTAssertEqual(paymentRequest.paymentSummaryItems[2].amount.doubleValue, 6)
    XCTAssertEqual(paymentRequest.paymentSummaryItems[2].type, .final)
    XCTAssertEqual(paymentRequest.paymentSummaryItems[3].label, "Kickstarter (if funded)")
    XCTAssertEqual(paymentRequest.paymentSummaryItems[3].amount.doubleValue, 36.6)
    XCTAssertEqual(paymentRequest.paymentSummaryItems[3].type, .final)
  }

  func testPaymentRequest_fromPostCampaignPaymentAuthorizationData_withReward() {
    var project = Project.template
    project.country = .jp
    project.stats.currency = Project.Country.jp.currencyCode
    project.isInPostCampaignPledgingPhase = true

    let reward = Reward.template
    let merchantId = "merchant_id"

    let data = PostCampaignPaymentAuthorizationData(
      project: project,
      hasNoReward: false,
      subtotal: 100,
      bonus: 200,
      shipping: 300,
      total: 500,
      merchantIdentifier: merchantId
    )

    let paymentRequest = PKPaymentRequest.paymentRequest(for: data)
    XCTAssertEqual(paymentRequest.merchantIdentifier, merchantId)
    XCTAssertEqual(paymentRequest.merchantCapabilities, .capability3DS)
    XCTAssertEqual(paymentRequest.countryCode, "JP")
    XCTAssertEqual(paymentRequest.currencyCode, "JPY")
    XCTAssertEqual(paymentRequest.shippingType, .shipping)
    XCTAssertEqual(paymentRequest.paymentSummaryItems.count, 4)
    XCTAssertEqual(paymentRequest.paymentSummaryItems[0].label, "Reward")
    XCTAssertEqual(paymentRequest.paymentSummaryItems[0].amount.doubleValue, 100)
    XCTAssertEqual(paymentRequest.paymentSummaryItems[0].type, .final)
    XCTAssertEqual(paymentRequest.paymentSummaryItems[1].label, "Bonus")
    XCTAssertEqual(paymentRequest.paymentSummaryItems[1].amount.doubleValue, 200)
    XCTAssertEqual(paymentRequest.paymentSummaryItems[1].type, .final)
    XCTAssertEqual(paymentRequest.paymentSummaryItems[2].label, "Shipping")
    XCTAssertEqual(paymentRequest.paymentSummaryItems[2].amount.doubleValue, 300)
    XCTAssertEqual(paymentRequest.paymentSummaryItems[2].type, .final)
    XCTAssertEqual(paymentRequest.paymentSummaryItems[3].label, "Kickstarter")
    XCTAssertEqual(paymentRequest.paymentSummaryItems[3].amount.doubleValue, 500)
    XCTAssertEqual(paymentRequest.paymentSummaryItems[3].type, .final)
  }

  func testPaymentRequest_fromPostCampaignPaymentAuthorizationData_noReward() {
    var project = Project.template
    project.country = .ca
    project.stats.currency = Project.Country.ca.currencyCode
    project.isInPostCampaignPledgingPhase = true

    let reward = Reward.noReward
    let merchantId = "merchant_id"

    let data = PostCampaignPaymentAuthorizationData(
      project: project,
      hasNoReward: true,
      subtotal: 500,
      bonus: 0,
      shipping: 0,
      total: 500,
      merchantIdentifier: merchantId
    )

    let paymentRequest = PKPaymentRequest.paymentRequest(for: data)
    XCTAssertEqual(paymentRequest.merchantIdentifier, merchantId)
    XCTAssertEqual(paymentRequest.merchantCapabilities, .capability3DS)
    XCTAssertEqual(paymentRequest.countryCode, "CA")
    XCTAssertEqual(paymentRequest.currencyCode, "CAD")
    XCTAssertEqual(paymentRequest.shippingType, .shipping)
    XCTAssertEqual(paymentRequest.paymentSummaryItems.count, 2)
    XCTAssertEqual(paymentRequest.paymentSummaryItems[0].label, "Total")
    XCTAssertEqual(paymentRequest.paymentSummaryItems[0].amount.doubleValue, 500)
    XCTAssertEqual(paymentRequest.paymentSummaryItems[0].type, .final)
    XCTAssertEqual(paymentRequest.paymentSummaryItems[1].label, "Kickstarter")
    XCTAssertEqual(paymentRequest.paymentSummaryItems[1].amount.doubleValue, 500)
    XCTAssertEqual(paymentRequest.paymentSummaryItems[1].type, .final)
  }
}
