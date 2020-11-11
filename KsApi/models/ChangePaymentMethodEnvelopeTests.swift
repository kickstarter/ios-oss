@testable import KsApi
import XCTest

final class ChangePaymentMethodEnvelopeTests: XCTestCase {
  func testDecodingWithStringStatus() {
    let decoded: ChangePaymentMethodEnvelope = try! ChangePaymentMethodEnvelope
      .decodeJSONDictionary(["status": "200"])
    XCTAssertNotNil(decoded)
    XCTAssertEqual(200, decoded.status)
  }

  func testDecodingWithIntStatus() {
    let decoded: ChangePaymentMethodEnvelope = try! ChangePaymentMethodEnvelope
      .decodeJSONDictionary(["status": 200])
    XCTAssertNotNil(decoded)
    XCTAssertEqual(200, decoded.status)
  }

  func testDecodingWithMissingStatus() {
    let decoded: ChangePaymentMethodEnvelope? = ChangePaymentMethodEnvelope.decodeJSONDictionary([:])
    XCTAssertNil(decoded)
  }

  func testDecodingWithBadStatusData() {
    let decoded: ChangePaymentMethodEnvelope = try! ChangePaymentMethodEnvelope
      .decodeJSONDictionary(["status": "bad data"])
    XCTAssertNotNil(decoded)
    XCTAssertEqual(0, decoded.status)
  }

  func testDecodingWithNewCheckoutUrl() {
    let decoded: ChangePaymentMethodEnvelope = try! ChangePaymentMethodEnvelope
      .decodeJSONDictionary(["status": "200", "data": ["new_checkout_url": "test_url"]])
    XCTAssertNotNil(decoded)
    XCTAssertEqual(200, decoded.status)
    XCTAssertEqual("test_url", decoded.newCheckoutUrl)
  }
}
