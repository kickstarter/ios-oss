import GraphAPI
@testable import KsApi
import XCTest

class GraphAPI_UpdateBackingInput_UpdateBackingInputTests: XCTestCase {
  func test_NoApplePay() {
    let input = UpdateBackingInput(
      amount: "50.00",
      applePay: nil,
      id: "backing-id",
      incremental: false,
      locationId: "1234",
      paymentSourceId: "1111",
      rewardIds: ["reward-1", "reward-2"],
      setupIntentClientSecret: nil
    )

    let graphInput = GraphAPI.UpdateBackingInput.from(input)

    XCTAssertEqual(graphInput.amount.unwrapped, input.amount)
    XCTAssertEqual(graphInput.applePay.token, .none)
    XCTAssertEqual(graphInput.locationId.unwrapped, input.locationId)
    XCTAssertEqual(graphInput.paymentSourceId.unwrapped, input.paymentSourceId)
    XCTAssertEqual(graphInput.id, input.id)
    XCTAssertEqual(graphInput.rewardIds.unwrapped, input.rewardIds)
    XCTAssertNil(graphInput.intentClientSecret.unwrapped)
    XCTAssertEqual(graphInput.incremental.unwrapped, input.incremental)
  }

  func test_NoApplePay_AndIsIncremental() {
    let input = UpdateBackingInput(
      amount: "50.00",
      applePay: nil,
      id: "backing-id",
      incremental: true,
      locationId: "1234",
      paymentSourceId: "1111",
      rewardIds: ["reward-1", "reward-2"],
      setupIntentClientSecret: nil
    )

    let graphInput = GraphAPI.UpdateBackingInput.from(input)

    XCTAssertEqual(graphInput.amount.unwrapped, input.amount)
    XCTAssertNil(graphInput.applePay.token)
    XCTAssertEqual(graphInput.locationId.unwrapped, input.locationId)
    XCTAssertEqual(graphInput.paymentSourceId.unwrapped, input.paymentSourceId)
    XCTAssertEqual(graphInput.id, input.id)
    XCTAssertEqual(graphInput.rewardIds.unwrapped, input.rewardIds)
    XCTAssertNil(graphInput.intentClientSecret.unwrapped)
    XCTAssertEqual(graphInput.incremental.unwrapped, input.incremental)
  }

  func test_ApplePay() {
    let input = UpdateBackingInput(
      amount: "50.00",
      applePay: ApplePayParams(
        paymentInstrumentName: "instrument-name",
        paymentNetwork: "payment-network",
        transactionIdentifier: "transaction-identifier",
        token: "token"
      ),
      id: "backing-id",
      incremental: false,
      locationId: "1234",
      paymentSourceId: "1111",
      rewardIds: ["reward-1", "reward-2"],
      setupIntentClientSecret: nil
    )

    let graphInput = GraphAPI.UpdateBackingInput.from(input)

    XCTAssertEqual(graphInput.amount.unwrapped, input.amount)
    XCTAssertEqual(graphInput.applePay.token, "token")
    XCTAssertEqual(graphInput.applePay.paymentInstrumentName, "instrument-name")
    XCTAssertEqual(graphInput.applePay.paymentNetwork, "payment-network")
    XCTAssertEqual(graphInput.applePay.transactionIdentifier, "transaction-identifier")
    XCTAssertEqual(graphInput.locationId.unwrapped, input.locationId)
    XCTAssertEqual(graphInput.paymentSourceId.unwrapped, input.paymentSourceId)
    XCTAssertEqual(graphInput.id, input.id)
    XCTAssertEqual(graphInput.rewardIds.unwrapped, input.rewardIds)
    XCTAssertNil(graphInput.intentClientSecret.unwrapped)
    XCTAssertEqual(graphInput.incremental.unwrapped, input.incremental)
  }

  func test_SetupIntentClientSecret() {
    let input = UpdateBackingInput(
      amount: "50.00",
      applePay: nil,
      id: "backing-id",
      incremental: false,
      locationId: "1234",
      paymentSourceId: nil,
      rewardIds: ["reward-1", "reward-2"],
      setupIntentClientSecret: "seti_1Lq2At4VvJ2PtfhKRtPWTnKh_secret_MZAVRP2SXO5bvZzZ2bi1W7o5Wsz4BuN"
    )

    let graphInput = GraphAPI.UpdateBackingInput.from(input)

    XCTAssertEqual(graphInput.amount.unwrapped, input.amount)
    XCTAssertEqual(graphInput.applePay, .none)
    XCTAssertEqual(graphInput.locationId.unwrapped, input.locationId)
    XCTAssertEqual(graphInput.paymentSourceId, .none)
    XCTAssertEqual(graphInput.id, input.id)
    XCTAssertEqual(graphInput.rewardIds.unwrapped, input.rewardIds)
    XCTAssertEqual(
      graphInput.intentClientSecret,
      "seti_1Lq2At4VvJ2PtfhKRtPWTnKh_secret_MZAVRP2SXO5bvZzZ2bi1W7o5Wsz4BuN"
    )
    XCTAssertEqual(graphInput.incremental.unwrapped, input.incremental)
  }
}
