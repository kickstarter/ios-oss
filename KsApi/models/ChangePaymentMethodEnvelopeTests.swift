import XCTest
@testable import KsApi

final class ChangePaymentMethodEnvelopeTests: XCTestCase {

  func testDecodingWithStringStatus() {
    let decoded = ChangePaymentMethodEnvelope.decodeJSONDictionary(["status": "200"])
    XCTAssertNil(decoded.error)
    XCTAssertEqual(200, decoded.value?.status)
  }

  func testDecodingWithIntStatus() {
    let decoded = ChangePaymentMethodEnvelope.decodeJSONDictionary(["status": 200])
    XCTAssertNil(decoded.error)
    XCTAssertEqual(200, decoded.value?.status)
  }

  func testDecodingWithMissingStatus() {
    let decoded = ChangePaymentMethodEnvelope.decodeJSONDictionary([:])
    XCTAssertNotNil(decoded.error)
  }

  func testDecodingWithBadStatusData() {
    let decoded = ChangePaymentMethodEnvelope.decodeJSONDictionary(["status": "bad data"])
    XCTAssertNil(decoded.error)
    XCTAssertEqual(0, decoded.value?.status)
  }
}
