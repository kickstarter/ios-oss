import XCTest
@testable import KsApi

final class SubmitApplePayEnvelopeTests: XCTestCase {

  func testDecodingWithStringStatus() {
    let decoded = SubmitApplePayEnvelope.decodeJSONDictionary(
      [
        "data": [
          "thankyou_url": "https://www.kickstarter.com/thanks"
        ],
        "status": "200"
      ]
    )

    XCTAssertNil(decoded.error)
    XCTAssertEqual(200, decoded.value?.status)
  }

  func testDecodingWithStatus() {
    let decoded = SubmitApplePayEnvelope.decodeJSONDictionary(
      [
        "data": [
          "thankyou_url": "https://www.kickstarter.com/thanks"
        ],
        "status": 200
      ]
    )

    XCTAssertNil(decoded.error)
    XCTAssertEqual(200, decoded.value?.status)
  }

  func testDecodingWithMissingStatus() {

    let decoded = SubmitApplePayEnvelope.decodeJSONDictionary(
      [
        "data": [
          "thankyou_url": "https://www.kickstarter.com/thanks"
        ]
      ]
    )

    XCTAssertNotNil(decoded.error)
  }

  func testDecodingWithBadStatusData() {
    let decoded = SubmitApplePayEnvelope.decodeJSONDictionary(
      [
        "data": [
          "thankyou_url": "bad data"
        ],
        "status": "bad data"
      ]
    )

    XCTAssertNil(decoded.error)
    XCTAssertEqual(0, decoded.value?.status)
  }
}
