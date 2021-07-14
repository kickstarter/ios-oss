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
      rewardIds: ["reward-1", "reward-2"]
    )

    let graphInput = GraphAPI.UpdateBackingInput.from(input)

    XCTAssertEqual(graphInput.amount, input.amount)
    XCTAssertNil(graphInput.applePay??.token)
    XCTAssertEqual(graphInput.locationId, input.locationId)
    XCTAssertEqual(graphInput.paymentSourceId, input.paymentSourceId)
    XCTAssertEqual(graphInput.id, input.id)
    XCTAssertEqual(graphInput.rewardIds, input.rewardIds)
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
      rewardIds: ["reward-1", "reward-2"]
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
  }
}
