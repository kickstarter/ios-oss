import XCTest
@testable import KsApi

final class CreatePledgeEnvelopeTests: XCTestCase {

  func testDecodingWithStringStatus() {
    let decoded = CreatePledgeEnvelope.decodeJSONDictionary(["status": "200"])
    XCTAssertNil(decoded.error)
    XCTAssertEqual(200, decoded.value?.status)
  }

  func testDecodingWithIntStatus() {
    let decoded = CreatePledgeEnvelope.decodeJSONDictionary(["status": 200])
    XCTAssertNil(decoded.error)
    XCTAssertEqual(200, decoded.value?.status)
  }

  func testDecodingWithMissingStatus() {
    let decoded = CreatePledgeEnvelope.decodeJSONDictionary([:])
    XCTAssertNotNil(decoded.error)
  }

  func testDecodingWithBadStatusData() {
    let decoded = CreatePledgeEnvelope.decodeJSONDictionary(["status": "bad data"])
    XCTAssertNil(decoded.error)
    XCTAssertEqual(0, decoded.value?.status)
  }
}
