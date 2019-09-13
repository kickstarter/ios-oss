import Foundation
@testable import KsApi
@testable import Library
import Prelude
import XCTest

final class CreateApplePayBackingInputConstructorTests: XCTestCase {
  func testCreateApplePayBackingInput_NoShipping() {
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
      stripeToken: "stripe-token"
    )

    XCTAssertEqual(input.amount, "10.00")
    XCTAssertNil(input.locationId)
    XCTAssertEqual(input.paymentInstrumentName, "Visa 123")
    XCTAssertEqual(input.paymentNetwork, "Visa")
    XCTAssertEqual(input.projectId, project.graphID)
    XCTAssertNil(input.rewardId)
    XCTAssertEqual(input.stripeToken, "stripe-token")
    XCTAssertEqual(input.transactionIdentifier, "12345")
  }

  func testCreateApplePayBackingInput_WithShipping() {
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
      stripeToken: "stripe-token"
    )

    XCTAssertEqual(input.amount, "15.00")
    XCTAssertEqual(input.locationId, "1")
    XCTAssertEqual(input.paymentInstrumentName, "Visa 123")
    XCTAssertEqual(input.paymentNetwork, "Visa")
    XCTAssertEqual(input.projectId, project.graphID)
    XCTAssertEqual(input.rewardId, reward.graphID)
    XCTAssertEqual(input.stripeToken, "stripe-token")
    XCTAssertEqual(input.transactionIdentifier, "12345")
  }
}
