@testable import KsApi
import XCTest

final class GraphAPI_CreateBackingInput_CreateBackingInputTests: XCTestCase {
  func test_NoApplePay() {
    let input = CreateBackingInput(
      amount: "50.00",
      applePay: nil,
      locationId: "1234",
      paymentSourceId: "1111",
      projectId: "5555",
      refParam: "ref-param",
      rewardIds: ["reward-1", "reward-2"],
      setupIntentClientSecret: "seti_1LVlHO4VvJ2PtfhK43R6p7FI_secret_MEDiGbxfYVnHGsQy8v8TbZJTQhlNKLZ"
    )

    let graphInput = GraphAPI.CreateBackingInput.from(input)

    XCTAssertEqual(graphInput.amount, input.amount)
    XCTAssertNil(graphInput.applePay??.token)
    XCTAssertEqual(graphInput.locationId, input.locationId)
    XCTAssertEqual(graphInput.paymentSourceId, input.paymentSourceId)
    XCTAssertEqual(graphInput.projectId, input.projectId)
    XCTAssertEqual(graphInput.refParam, input.refParam)
    XCTAssertEqual(graphInput.rewardIds, input.rewardIds)
    XCTAssertEqual(graphInput.setupIntentClientSecret!, input.setupIntentClientSecret)
  }

  func test_ApplePay() {
    let input = CreateBackingInput(
      amount: "50.00",
      applePay: ApplePayParams(
        paymentInstrumentName: "instrument-name",
        paymentNetwork: "payment-network",
        transactionIdentifier: "transaction-identifier",
        token: "token"
      ),
      locationId: "1234",
      paymentSourceId: "1111",
      projectId: "5555",
      refParam: "ref-param",
      rewardIds: ["reward-1", "reward-2"],
      setupIntentClientSecret: nil
    )

    let graphInput = GraphAPI.CreateBackingInput.from(input)

    XCTAssertEqual(graphInput.amount, input.amount)
    XCTAssertEqual(graphInput.applePay??.token, "token")
    XCTAssertEqual(graphInput.applePay??.paymentInstrumentName, "instrument-name")
    XCTAssertEqual(graphInput.applePay??.paymentNetwork, "payment-network")
    XCTAssertEqual(graphInput.applePay??.transactionIdentifier, "transaction-identifier")
    XCTAssertEqual(graphInput.locationId, input.locationId)
    XCTAssertEqual(graphInput.paymentSourceId, input.paymentSourceId)
    XCTAssertEqual(graphInput.projectId, input.projectId)
    XCTAssertEqual(graphInput.refParam, input.refParam)
    XCTAssertEqual(graphInput.rewardIds, input.rewardIds)
    XCTAssertNil(graphInput.setupIntentClientSecret as? String)
  }
}
