@testable import KsApi
import Prelude
import XCTest

final class PerimeterXClientTypeTests: XCTestCase {
  func testHeaders() {
    let mockPXClient = MockPerimeterXClient()

    XCTAssertEqual(mockPXClient.headers(), ["PX-AUTH-TEST": "foobar"])
  }

  func testHeaders_IncorrectHeader() {
    let mockPXClient = MockPerimeterXClient()

    XCTAssertNotEqual(mockPXClient.headers(), ["PX-INCORRECT-HEADER": "foobar"])
  }

  func testHandleError_StatusCode_403() {
    let mockPXClient = MockPerimeterXClient()
    let data = "test".data(using: .utf8, allowLossyConversion: false)
    guard let blockResponse = HTTPURLResponse(
      url: URL(string: "http://api.ksr.com/v1/test?key=value")!,
      statusCode: 403,
      httpVersion: nil,
      headerFields: nil
    ) else {
      XCTFail("Could not unwrap HTTPURLResponse.")
      return
    }

    XCTAssertTrue(mockPXClient.handleError(blockResponse: blockResponse, and: data!))

    XCTAssertEqual(mockPXClient.pxblockType, .captcha)
    XCTAssertTrue(mockPXClient.handleErrorCalled)
  }

  func testHandleError_StatusCode_200() {
    let mockPXClient = MockPerimeterXClient()
    let data = "test".data(using: .utf8, allowLossyConversion: false)
    guard let blockResponse = HTTPURLResponse(
      url: URL(string: "http://api.ksr.com/v1/test?key=value")!,
      statusCode: 200,
      httpVersion: nil,
      headerFields: nil
    ) else {
      XCTFail("Could not unwrap HTTPURLResponse.")
      return
    }

    XCTAssertFalse(mockPXClient.handleError(blockResponse: blockResponse, and: data!))

    XCTAssertEqual(mockPXClient.pxblockType, .valid)
    XCTAssertFalse(mockPXClient.handleErrorCalled)
  }
}
