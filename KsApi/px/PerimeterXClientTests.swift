@testable import KsApi
import PerimeterX
import Prelude
import XCTest

final class PerimeterXClientTests: XCTestCase {
  func testCookie() {
    let manager = MockPerimeterXManager()
    let client = PerimeterXClient(manager: manager, dateType: ApiMockDate.self)

    guard let cookie = client.cookie else {
      XCTFail("Where's my cookie?")
      return
    }

    XCTAssertEqual(cookie.domain, "www.perimeterx.com")
    XCTAssertEqual(cookie.path, "/")
    XCTAssertEqual(cookie.name, "_pxmvid")
    XCTAssertEqual(cookie.value, manager.getVid())
    XCTAssertEqual(cookie.expiresDate, ApiMockDate.init(timeIntervalSinceNow: 3_600).date)
  }

  func testHeaders() {
    let manager = MockPerimeterXManager()
    let client = PerimeterXClient(manager: manager, dateType: ApiMockDate.self)

    XCTAssertEqual(client.headers(), ["PX-AUTH-TEST": "foobar"])
  }

  func testHeaders_IncorrectHeader() {
    let manager = MockPerimeterXManager()
    let client = PerimeterXClient(manager: manager, dateType: ApiMockDate.self)

    XCTAssertNotEqual(client.headers(), ["PX-INCORRECT-HEADER": "foobar"])
  }

  func testHandleError_StatusCode_403_Captcha() {
    let manager = MockPerimeterXManager()
    manager.responseType = MockPerimeterXBlockResponse(blockType: .Captcha)
    let client = PerimeterXClient(manager: manager, dateType: ApiMockDate.self)

    let data = "{}".data(using: .utf8, allowLossyConversion: false)
    guard let response = HTTPURLResponse(
      url: URL(string: "http://api.ksr.com/v1/test?key=value")!,
      statusCode: 403,
      httpVersion: nil,
      headerFields: nil
    ) else {
      XCTFail("Could not unwrap HTTPURLResponse.")
      return
    }

    XCTAssertTrue(client.handleError(response: response, and: data!))

    expectation(forNotification: Notification.Name.ksr_perimeterXCaptcha, object: nil) { note in
      Thread.isMainThread && (note.userInfo?["response"] as? PerimeterXBlockResponseType)?.type == .Captcha
    }

    waitForExpectations(timeout: 0.01, handler: nil)
  }

  func testHandleError_StatusCode_403_Block() {
    let manager = MockPerimeterXManager()
    manager.responseType = MockPerimeterXBlockResponse(blockType: .Block)
    let client = PerimeterXClient(manager: manager, dateType: ApiMockDate.self)

    let data = "{}".data(using: .utf8, allowLossyConversion: false)
    guard let response = HTTPURLResponse(
      url: URL(string: "http://api.ksr.com/v1/test?key=value")!,
      statusCode: 403,
      httpVersion: nil,
      headerFields: nil
    ) else {
      XCTFail("Could not unwrap HTTPURLResponse.")
      return
    }

    XCTAssertTrue(client.handleError(response: response, and: data!))

    expectation(forNotification: Notification.Name.ksr_perimeterXCaptcha, object: nil) { note in
      Thread.isMainThread && (note.userInfo?["response"] as? PerimeterXBlockResponseType)?.type == .Block
    }

    waitForExpectations(timeout: 0.01, handler: nil)
  }

  func testHandleError_StatusCode_200() {
    let manager = MockPerimeterXManager()
    manager.responseType = MockPerimeterXBlockResponse(blockType: .NotPXBlock)
    let client = PerimeterXClient(manager: manager, dateType: ApiMockDate.self)

    let data = "{}".data(using: .utf8, allowLossyConversion: false)
    guard let response = HTTPURLResponse(
      url: URL(string: "http://api.ksr.com/v1/test?key=value")!,
      statusCode: 200,
      httpVersion: nil,
      headerFields: nil
    ) else {
      XCTFail("Could not unwrap HTTPURLResponse.")
      return
    }

    var notificationResponse: MockPerimeterXBlockResponse?

    let token = NotificationCenter.default.addObserver(
      forName: Notification.Name.ksr_perimeterXCaptcha,
      object: nil,
      queue: OperationQueue.main
    ) { note in
      notificationResponse = note.object as? MockPerimeterXBlockResponse
    }

    XCTAssertFalse(client.handleError(response: response, and: data!))
    XCTAssertNil(notificationResponse)

    NotificationCenter.default.removeObserver(token)
  }
}
