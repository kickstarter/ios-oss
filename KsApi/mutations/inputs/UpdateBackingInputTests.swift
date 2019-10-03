@testable import KsApi
import XCTest

final class UpdateBackingInputTests: XCTestCase {
  func testInput() {
    let input = UpdateBackingInput(
      amount: "800",
      applePay: .init(
        paymentInstrumentName: "instrument-name",
        paymentNetwork: "payment-network",
        transactionIdentifier: "tx-identifier",
        token: "token"
      ),
      id: "id-123",
      locationId: "12345",
      paymentSourceId: "33234234",
      rewardId: "234442"
    )

    let inputDictionary = input.toInputDictionary()

    let applePayDictionary = inputDictionary["applePay"] as? [String: Any]

    XCTAssertEqual(inputDictionary["amount"] as? String, "800")
    XCTAssertEqual(applePayDictionary?["paymentInstrumentName"] as? String, "instrument-name")
    XCTAssertEqual(applePayDictionary?["paymentNetwork"] as? String, "payment-network")
    XCTAssertEqual(applePayDictionary?["transactionIdentifier"] as? String, "tx-identifier")
    XCTAssertEqual(applePayDictionary?["token"] as? String, "token")
    XCTAssertEqual(inputDictionary["id"] as? String, "id-123")
    XCTAssertEqual(inputDictionary["locationId"] as? String, "12345")
    XCTAssertEqual(inputDictionary["paymentSourceId"] as? String, "33234234")
    XCTAssertEqual(inputDictionary["rewardId"] as? String, "234442")
  }

  func testInput_NoApplePay() {
    let input = UpdateBackingInput(
      amount: "800",
      applePay: nil,
      id: "id-123",
      locationId: "12345",
      paymentSourceId: "33234234",
      rewardId: "234442"
    )

    let inputDictionary = input.toInputDictionary()

    XCTAssertFalse(inputDictionary.keys.contains("applePay"))

    XCTAssertEqual(inputDictionary["amount"] as? String, "800")
    XCTAssertEqual(inputDictionary["id"] as? String, "id-123")
    XCTAssertEqual(inputDictionary["locationId"] as? String, "12345")
    XCTAssertEqual(inputDictionary["paymentSourceId"] as? String, "33234234")
    XCTAssertEqual(inputDictionary["rewardId"] as? String, "234442")
  }
}
