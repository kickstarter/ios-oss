import XCTest
@testable import KsApi
@testable import Argo

class ErrorEnvelopeTests: XCTestCase {

  func testJsonDecodingWithFullData() {
    let env = ErrorEnvelope.decodeJSONDictionary([
      "error_messages": ["hello"],
      "ksr_code": "access_token_invalid",
      "http_code": 401,
      "exception": [
        "backtrace": ["hello"],
        "message": "hello"
      ]
      ])
    XCTAssertNotNil(env)
  }

  func testJsonDecodingWithBadKsrCode() {
    let env = ErrorEnvelope.decodeJSONDictionary([
      "error_messages": ["hello"],
      "ksr_code": "doesnt_exist",
      "http_code": 401,
      "exception": [
        "backtrace": ["hello"],
        "message": "hello"
      ]
      ])
    XCTAssertNil(env.error)
    XCTAssertEqual(ErrorEnvelope.KsrCode.UnknownCode, env.value?.ksrCode)
  }

  func testJsonDecodingWithNonStandardError() {
    let env = ErrorEnvelope.decodeJSONDictionary([
      "status": 406,
      "data": [
        "errors": [
          "amount": [
            "Bad amount"
          ]
        ]
      ]
    ])
    XCTAssertNil(env.error)
    XCTAssertEqual(ErrorEnvelope.KsrCode.UnknownCode, env.value?.ksrCode)
    // swiftlint:disable:next force_unwrapping
    XCTAssertEqual(["Bad amount"], env.value!.errorMessages)
    XCTAssertEqual(406, env.value?.httpCode)
  }
}
