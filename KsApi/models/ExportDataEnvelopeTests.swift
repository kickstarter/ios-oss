@testable import KsApi
import XCTest

class ExportDataEnvelopeTests: XCTestCase {
  func testJsonDecodingWithValidState() {
    let env: ExportDataEnvelope = try! ExportDataEnvelope.decodeJSONDictionary([
      "expires_at":"fake-date",
      "state":"none",
      "data_url":"fake-url"
    ])
    XCTAssertNotNil(env)
    XCTAssertEqual(env.state, .none)
  }

  func testJsonDecodingWithInvalidState() {
    let env: ExportDataEnvelope = try! ExportDataEnvelope.decodeJSONDictionary([
      "expires_at":"fake-date",
      "state":"invalid-state",
      "data_url":"fake-url"
    ])
    XCTAssertNotNil(env)
    XCTAssertEqual(env.state, .unknown)
  }
  
}
