@testable import KsApi
import XCTest

final class ApplePayParamsTests: XCTestCase {
  func testApplePayParams() {
    let params = ApplePayParams(
      paymentInstrumentName: "instrument-name",
      paymentNetwork: "payment-network",
      transactionIdentifier: "tx-identifier",
      token: "token"
    )

    let dict = params.dictionaryRepresentation ?? [:]

    XCTAssertEqual(dict["paymentInstrumentName"] as? String, "instrument-name")
    XCTAssertEqual(dict["paymentNetwork"] as? String, "payment-network")
    XCTAssertEqual(dict["transactionIdentifier"] as? String, "tx-identifier")
    XCTAssertEqual(dict["token"] as? String, "token")
  }
}
