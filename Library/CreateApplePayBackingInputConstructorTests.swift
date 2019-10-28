import Foundation
@testable import KsApi
@testable import Library
import Prelude
import XCTest

final class CreateApplePayBackingInputConstructorTests: XCTestCase {
  func testCreateApplePayBackingInput_NoShipping_NoReward() {
    let project = Project.template
    let reward = Reward.noReward

    let input = CreateApplePayBackingInput.input(
      from: project,
      reward: reward,
      pledgeAmount: 10,
      selectedShippingRule: nil,
      pkPaymentData: PKPaymentData(
        displayName: "Visa 123",
        network: "Visa",
        transactionIdentifier: "12345"
      ),
      stripeToken: "stripe-token",
      refTag: RefTag.projectPage
    )

    XCTAssertEqual(input.amount, "10.00")
    XCTAssertNil(input.locationId)
    XCTAssertEqual(input.paymentInstrumentName, "Visa 123")
    XCTAssertEqual(input.paymentNetwork, "Visa")
    XCTAssertEqual(input.projectId, project.graphID)
    XCTAssertEqual(input.rewardId, "UmV3YXJkLTA=")
    XCTAssertEqual(input.stripeToken, "stripe-token")
    XCTAssertEqual(input.transactionIdentifier, "12345")
    XCTAssertEqual(input.refParam, "project_page")
  }

  func testCreateApplePayBackingInput_WithShipping_WithReward() {
    let project = Project.template
    let reward = Reward.template
    let shippingRule = ShippingRule.template
      |> ShippingRule.lens.location .. Location.lens.id .~ 1
      |> ShippingRule.lens.cost .~ 5

    let input = CreateApplePayBackingInput.input(
      from: project,
      reward: reward,
      pledgeAmount: 10,
      selectedShippingRule: shippingRule,
      pkPaymentData: PKPaymentData(
        displayName: "Visa 123",
        network: "Visa",
        transactionIdentifier: "12345"
      ),
      stripeToken: "stripe-token",
      refTag: nil
    )

    XCTAssertEqual(input.amount, "15.00")
    XCTAssertEqual(input.locationId, "1")
    XCTAssertEqual(input.paymentInstrumentName, "Visa 123")
    XCTAssertEqual(input.paymentNetwork, "Visa")
    XCTAssertEqual(input.projectId, project.graphID)
    XCTAssertEqual(input.rewardId, reward.graphID)
    XCTAssertEqual(input.stripeToken, "stripe-token")
    XCTAssertEqual(input.transactionIdentifier, "12345")
    XCTAssertNil(input.refParam)
  }
}
