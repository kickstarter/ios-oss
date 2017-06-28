import XCTest
@testable import KsApi

final class UpdatePledgeEnvelopeTests: XCTestCase {

  func testDecodingWithStringStatus() {
    let decoded = UpdatePledgeEnvelope.decodeJSONDictionary(["status": "200"])
    XCTAssertNil(decoded.error)
    XCTAssertEqual(200, decoded.value?.status)
  }

  func testDecodingWithIntStatus() {
    let decoded = UpdatePledgeEnvelope.decodeJSONDictionary(["status": 200])
    XCTAssertNil(decoded.error)
    XCTAssertEqual(200, decoded.value?.status)
  }

  func testDecodingWithMissingStatus() {
    let decoded = UpdatePledgeEnvelope.decodeJSONDictionary([:])
    XCTAssertNotNil(decoded.error)
  }

  func testDecodingWithBadStatusData() {
    let decoded = UpdatePledgeEnvelope.decodeJSONDictionary(["status": "bad data"])
    XCTAssertNil(decoded.error)
    XCTAssertEqual(0, decoded.value?.status)
  }
}
