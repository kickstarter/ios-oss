@testable import KsApi
import XCTest

class EmailVerificationResponseEnvelopeTests: XCTestCase {
  func testJsonDecodingWithFullData() {
    let env: EmailVerificationResponseEnvelope? = EmailVerificationResponseEnvelope.decodeJSONDictionary([
      "message": "You have successfully verified your email address."
    ])
    XCTAssertNotNil(env)
    XCTAssertEqual(env?.message, "You have successfully verified your email address.")
  }
}
