@testable import KsApi
import XCTest

class ErrorEnvelopeTests: XCTestCase {
  func testJsonDecodingWithFullData() {
    let env: ErrorEnvelope = try! ErrorEnvelope.decodeJSONDictionary([
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
    let env: ErrorEnvelope = try! ErrorEnvelope.decodeJSONDictionary([
      "error_messages": ["hello"],
      "ksr_code": "doesnt_exist",
      "http_code": 401,
      "exception": [
        "backtrace": ["hello"],
        "message": "hello"
      ]
    ])
    XCTAssertNotNil(env)
    XCTAssertEqual(ErrorEnvelope.KsrCode.UnknownCode, env.ksrCode)
  }

  func testJsonDecodingWithNonStandardError() {
    let env: ErrorEnvelope = try! ErrorEnvelope.decodeJSONDictionary([
      "status": 406,
      "data": [
        "errors": [
          "amount": [
            "Bad amount"
          ]
        ]
      ]
    ])
    XCTAssertNotNil(env)
    XCTAssertEqual(ErrorEnvelope.KsrCode.UnknownCode, env.ksrCode)
    XCTAssertEqual(["Bad amount"], env.errorMessages)
    XCTAssertEqual(406, env.httpCode)
  }

  func testJsonDecodingWithNonStandardErrorBackerReward() {
    let env: ErrorEnvelope = try! ErrorEnvelope.decodeJSONDictionary([
      "status": 406,
      "data": [
        "errors": [
          "backer_reward": [
            "Bad amount"
          ]
        ]
      ]
    ])
    XCTAssertNotNil(env)
    XCTAssertEqual(ErrorEnvelope.KsrCode.UnknownCode, env.ksrCode)
    XCTAssertEqual(["Bad amount"], env.errorMessages)
    XCTAssertEqual(406, env.httpCode)
  }
}
