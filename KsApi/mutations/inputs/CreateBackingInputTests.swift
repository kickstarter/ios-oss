@testable import KsApi
import Prelude
import XCTest

final class CreateBackingInputTests: XCTestCase {
  func testCreateBackingInputDictionary() {
    let createBackingInput = CreateBackingInput(
      amount: "200.00",
      applePay: .init(
        paymentInstrumentName: "instrument-name",
        paymentNetwork: "payment-network",
        transactionIdentifier: "tx-identifier",
        token: "token"
      ),
      locationId: "NY",
      paymentSourceId: "paymentSourceId",
      projectId: "projectId",
      refParam: "activity",
      rewardIds: ["rewardId"],
      setupIntentClientSecret: "seti_1LVlHO4VvJ2PtfhK43R6p7FI_secret_MEDiGbxfYVnHGsQy8v8TbZJTQhlNKLZ"
    )

    let input = createBackingInput.toInputDictionary()
    let applePayDictionary = input["applePay"] as? [String: Any]

    XCTAssertEqual(input["amount"] as? String, "200.00")
    XCTAssertEqual(applePayDictionary?["paymentInstrumentName"] as? String, "instrument-name")
    XCTAssertEqual(applePayDictionary?["paymentNetwork"] as? String, "payment-network")
    XCTAssertEqual(applePayDictionary?["transactionIdentifier"] as? String, "tx-identifier")
    XCTAssertEqual(applePayDictionary?["token"] as? String, "token")
    XCTAssertEqual(input["locationId"] as? String, "NY")
    XCTAssertEqual(input["paymentSourceId"] as? String, "paymentSourceId")
    XCTAssertEqual(input["projectId"] as? String, "projectId")
    XCTAssertEqual(input["rewardIds"] as? [String], ["rewardId"])
    XCTAssertEqual(input["refParam"] as? String, "activity")
    XCTAssertEqual(
      input["setupIntentClientSecret"] as? String,
      "seti_1LVlHO4VvJ2PtfhK43R6p7FI_secret_MEDiGbxfYVnHGsQy8v8TbZJTQhlNKLZ"
    )
  }

  func testCreateBackingInputDictionary_NoApplePay() {
    let createBackingInput = CreateBackingInput(
      amount: "200.00",
      applePay: nil,
      locationId: "NY",
      paymentSourceId: "paymentSourceId",
      projectId: "projectId",
      refParam: "activity",
      rewardIds: ["rewardId"],
      setupIntentClientSecret: nil
    )

    let input = createBackingInput.toInputDictionary()

    XCTAssertFalse(input.keys.contains("applePay"))

    XCTAssertEqual(input["amount"] as? String, "200.00")
    XCTAssertEqual(input["locationId"] as? String, "NY")
    XCTAssertEqual(input["paymentSourceId"] as? String, "paymentSourceId")
    XCTAssertEqual(input["projectId"] as? String, "projectId")
    XCTAssertEqual(input["rewardIds"] as? [String], ["rewardId"])
    XCTAssertEqual(input["refParam"] as? String, "activity")
    XCTAssertNil(input["setupIntentClientSecret"])
  }

  func testCreateBackingInputDictionary_Location_IsNil() {
    let createBackingInput = CreateBackingInput(
      amount: "200.00",
      applePay: .init(
        paymentInstrumentName: "instrument-name",
        paymentNetwork: "payment-network",
        transactionIdentifier: "tx-identifier",
        token: "token"
      ),
      locationId: nil,
      paymentSourceId: "paymentSourceId",
      projectId: "projectId",
      refParam: nil,
      rewardIds: ["rewardId"],
      setupIntentClientSecret: nil
    )

    let input = createBackingInput.toInputDictionary()

    XCTAssertEqual(input["amount"] as? String, "200.00")
    XCTAssertNil(input["locationId"])
    XCTAssertEqual(input["paymentSourceId"] as? String, "paymentSourceId")
    XCTAssertEqual(input["projectId"] as? String, "projectId")
    XCTAssertEqual(input["rewardIds"] as? [String], ["rewardId"])
    XCTAssertNil(input["refParam"])
    XCTAssertNil(input["setupIntentClientSecret"])
  }
}
