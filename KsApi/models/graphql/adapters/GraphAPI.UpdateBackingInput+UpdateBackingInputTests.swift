@testable import KsApi
import XCTest

class GraphAPI_UpdateBackingInput_UpdateBackingInputTests: XCTestCase {
  func test_NoApplePay() {
    let input = UpdateBackingInput(
      amount: "50.00",
      applePay: nil,
      id: "backing-id",
      locationId: "1234",
      paymentSourceId: "1111",
      rewardIds: ["reward-1", "reward-2"],
      setupIntentClientSecret: nil
    )

    let graphInput = GraphAPI.UpdateBackingInput.from(input)

    XCTAssertEqual(graphInput.amount, input.amount)
    XCTAssertNil(graphInput.applePay??.token)
    XCTAssertEqual(graphInput.locationId, input.locationId)
    XCTAssertEqual(graphInput.paymentSourceId, input.paymentSourceId)
    XCTAssertEqual(graphInput.id, input.id)
    XCTAssertEqual(graphInput.rewardIds, input.rewardIds)
    XCTAssertNil(graphInput.intentClientSecret as? String)
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
      locationId: "1234",
      paymentSourceId: "1111",
      rewardIds: ["reward-1", "reward-2"],
      setupIntentClientSecret: nil
    )

    let graphInput = GraphAPI.UpdateBackingInput.from(input)

    XCTAssertEqual(graphInput.amount, input.amount)
    XCTAssertEqual(graphInput.applePay??.token, "token")
    XCTAssertEqual(graphInput.applePay??.paymentInstrumentName, "instrument-name")
    XCTAssertEqual(graphInput.applePay??.paymentNetwork, "payment-network")
    XCTAssertEqual(graphInput.applePay??.transactionIdentifier, "transaction-identifier")
    XCTAssertEqual(graphInput.locationId, input.locationId)
    XCTAssertEqual(graphInput.paymentSourceId, input.paymentSourceId)
    XCTAssertEqual(graphInput.id, input.id)
    XCTAssertEqual(graphInput.rewardIds, input.rewardIds)
    XCTAssertNil(graphInput.intentClientSecret as? String)
  }

  func test_SetupIntentClientSecret() {
    let input = UpdateBackingInput(
      amount: "50.00",
      applePay: nil,
      id: "backing-id",
      locationId: "1234",
      paymentSourceId: nil,
      rewardIds: ["reward-1", "reward-2"],
      setupIntentClientSecret: "seti_1Lq2At4VvJ2PtfhKRtPWTnKh_secret_MZAVRP2SXO5bvZzZ2bi1W7o5Wsz4BuN"
    )

    let graphInput = GraphAPI.UpdateBackingInput.from(input)

    XCTAssertEqual(graphInput.amount, input.amount)
    XCTAssertNil(graphInput.applePay as? GraphAPI.ApplePayInput)
    XCTAssertEqual(graphInput.locationId, input.locationId)
    XCTAssertNil(graphInput.paymentSourceId as? String)
    XCTAssertEqual(graphInput.id, input.id)
    XCTAssertEqual(graphInput.rewardIds, input.rewardIds)
    XCTAssertEqual(
      graphInput.intentClientSecret,
      "seti_1Lq2At4VvJ2PtfhKRtPWTnKh_secret_MZAVRP2SXO5bvZzZ2bi1W7o5Wsz4BuN"
    )
  }
}
