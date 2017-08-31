// swiftlint:disable force_unwrapping
import XCTest
@testable import KsApi

final class ServiceTypeTests: XCTestCase {
  private let service = Service(
    appId: "com.kickstarter.test",
    serverConfig: ServerConfig(
      apiBaseUrl: URL(string: "http://api.ksr.com")!,
      webBaseUrl: URL(string: "http://www.ksr.com")!,
      apiClientAuth: ClientAuth(
        clientId: "deadbeef"
      ),
      basicHTTPAuth: BasicHTTPAuth(
        username: "username",
        password: "password"
      )
    ),
    oauthToken: OauthToken(
      token: "cafebeef"
    ),
    language: "ksr",
    buildVersion: "1234567890"
  )

  private let anonAdHocService = Service(
    appId: "com.kickstarter.test",
    serverConfig: ServerConfig(
      apiBaseUrl: URL(string: "http://api-hq.dev.ksr.com")!,
      webBaseUrl: URL(string: "http://hq.dev.ksr.com")!,
      apiClientAuth: ClientAuth(
        clientId: "deadbeef"
      ),
      basicHTTPAuth: BasicHTTPAuth(
        username: "username",
        password: "password"
      )
    )
  )

  private let anonService = Service(
    appId: "com.kickstarter.test",
    serverConfig: ServerConfig(
      apiBaseUrl: URL(string: "http://api.ksr.com")!,
      webBaseUrl: URL(string: "http://hq.ksr.com")!,
      apiClientAuth: ClientAuth(
        clientId: "deadbeef"
      ),
      basicHTTPAuth: nil
    )
  )

  func testEquals() {
    XCTAssertTrue(Service() != MockService())
  }

  func testIsPreparedAdhocWithoutOauthToken() {
    let url = URL(string: "http://api-dev.ksr.com/v1/test?key=value")!
    let request = URLRequest(url: url)
    XCTAssertFalse(self.anonAdHocService.isPrepared(request: request))
    XCTAssertTrue(self.anonAdHocService.isPrepared(request:
      self.anonAdHocService.preparedRequest(forRequest: request))
    )
  }

  func testIsPreparedWithOauthToken() {
    let url = URL(string: "http://api.ksr.com/v1/test?key=value&oauth_token=cafebeef")!
    let request = URLRequest(url: url)
    XCTAssertFalse(self.service.isPrepared(request: request))
    XCTAssertTrue(self.service.isPrepared(request: self.service.preparedRequest(forRequest: request)))
  }

  func testIsPreparedWithoutOauthToken() {
    let url = URL(string: "http://api.ksr.com/v1/test?key=value")!
    let request = URLRequest(url: url)
    XCTAssertFalse(self.anonService.isPrepared(request: request))
    XCTAssertTrue(self.anonService.isPrepared(request: self.anonService.preparedRequest(forRequest: request)))
  }

  func testPreparedRequest() {
    let url = URL(string: "http://api.ksr.com/v1/test?key=value")!
    let request = self.service.preparedRequest(forRequest: .init(url: url))

    XCTAssertEqual(
      "http://api.ksr.com/v1/test?client_id=deadbeef&currency=USD&key=value&oauth_token=cafebeef",
      request.url?.absoluteString)
    XCTAssertEqual(
      ["Kickstarter-iOS-App": "1234567890", "Authorization": "token cafebeef", "Accept-Language": "ksr",
        "Kickstarter-App-Id": "com.kickstarter.test",
        "User-Agent": userAgent()],
      request.allHTTPHeaderFields!
    )
  }

  func testPreparedURL() {
    let url = URL(string: "http://api.ksr.com/v1/test?key=value")!
    let request = self.service.preparedRequest(forURL: url, query: ["extra": "1"])

    XCTAssertEqual(
      "http://api.ksr.com/v1/test?client_id=deadbeef&currency=USD&extra=1&key=value&oauth_token=cafebeef",
      request.url?.absoluteString)
    XCTAssertEqual(
      ["Kickstarter-iOS-App": "1234567890", "Authorization": "token cafebeef", "Accept-Language": "ksr",
        "Kickstarter-App-Id": "com.kickstarter.test",
        "User-Agent": userAgent()],
      request.allHTTPHeaderFields!
    )
    XCTAssertEqual("GET", request.httpMethod)
  }

  func testPreparedDeleteURL() {
    let url = URL(string: "http://api.ksr.com/v1/test?key=value")!
    let request = self.service.preparedRequest(forURL: url, method: .DELETE, query: ["extra": "1"])

    XCTAssertEqual(
      "http://api.ksr.com/v1/test?client_id=deadbeef&currency=USD&extra=1&key=value&oauth_token=cafebeef",
      request.url?.absoluteString)
    XCTAssertEqual(
      ["Kickstarter-iOS-App": "1234567890", "Authorization": "token cafebeef", "Accept-Language": "ksr",
        "Kickstarter-App-Id": "com.kickstarter.test",
        "User-Agent": userAgent()],
      request.allHTTPHeaderFields!
    )
    XCTAssertEqual("DELETE", request.httpMethod)
  }

  func testPreparedPostURL() {
    let url = URL(string: "http://api.ksr.com/v1/test?key=value")!
    let request = self.service.preparedRequest(forURL: url, method: .POST, query: ["extra": "1"])

    XCTAssertEqual(
      "http://api.ksr.com/v1/test?client_id=deadbeef&currency=USD&key=value&oauth_token=cafebeef",
      request.url?.absoluteString)
    XCTAssertEqual(
      ["Kickstarter-iOS-App": "1234567890", "Authorization": "token cafebeef", "Accept-Language": "ksr",
        "Kickstarter-App-Id": "com.kickstarter.test",
        "Content-Type": "application/json; charset=utf-8",
        "User-Agent": userAgent()],
      request.allHTTPHeaderFields!
    )
    XCTAssertEqual("POST", request.httpMethod)
    XCTAssertEqual("{\"extra\":\"1\"}",
                   String(data: request.httpBody ?? Data(), encoding: .utf8))
  }

  func testPreparedPostURLWithBody() {
    let url = URL(string: "http://api.ksr.com/v1/test?key=value")!
    var baseRequest = URLRequest(url: url)
    let body = "test".data(using: .utf8, allowLossyConversion: false)
    baseRequest.httpBody = body
    baseRequest.httpMethod = "POST"
    let request = self.service.preparedRequest(forRequest: baseRequest, query: ["extra": "1"])

    XCTAssertEqual(
      "http://api.ksr.com/v1/test?client_id=deadbeef&currency=USD&key=value&oauth_token=cafebeef",
      request.url?.absoluteString)
    XCTAssertEqual(
      ["Kickstarter-iOS-App": "1234567890", "Authorization": "token cafebeef", "Accept-Language": "ksr",
        "Kickstarter-App-Id": "com.kickstarter.test",
        "User-Agent": userAgent()],
      request.allHTTPHeaderFields!
    )
    XCTAssertEqual("POST", request.httpMethod)
    XCTAssertEqual(body, request.httpBody, "Body remains unchanged")
  }

  func testPreparedAdHocWithoutOauthToken() {
    let url = URL(string: "http://api-hq.ksr.com/v1/test?key=value")!
    let request = anonAdHocService.preparedRequest(forRequest: .init(url: url))

    XCTAssertEqual(
      "http://api-hq.ksr.com/v1/test?client_id=deadbeef&currency=USD&key=value",
      request.url?.absoluteString)
    XCTAssertEqual(
      ["Kickstarter-iOS-App": "1", "Authorization": "Basic dXNlcm5hbWU6cGFzc3dvcmQ=",
        "Accept-Language": "en", "Kickstarter-App-Id": "com.kickstarter.test",
        "User-Agent": userAgent()],
      request.allHTTPHeaderFields!
    )
  }

  func testPreparedRequestWithoutOauthToken() {
    let anonService = Service(
      appId: "com.kickstarter.test",
      serverConfig: ServerConfig(
        apiBaseUrl: URL(string: "http://api.ksr.com")!,
        webBaseUrl: URL(string: "http://www.ksr.com")!,
        apiClientAuth: ClientAuth(
          clientId: "deadbeef"
        ),
        basicHTTPAuth: BasicHTTPAuth(
          username: "username",
          password: "password"
        )
      )
    )

    let url = URL(string: "http://api.ksr.com/v1/test?key=value")!
    let request = anonService.preparedRequest(forRequest: .init(url: url))

    XCTAssertEqual("http://api.ksr.com/v1/test?client_id=deadbeef&currency=USD&key=value",
                   request.url?.absoluteString)
    XCTAssertEqual(
      ["Kickstarter-iOS-App": "1", "Authorization": "Basic dXNlcm5hbWU6cGFzc3dvcmQ=",
        "Accept-Language": "en", "Kickstarter-App-Id": "com.kickstarter.test",
        "User-Agent": userAgent()],
      request.allHTTPHeaderFields!
    )
  }
}

private func userAgent() -> String {
  return "Kickstarter/1 (\(UIDevice.current.model); iOS \(UIDevice.current.systemVersion) "
    + "Scale/\(UIScreen.main.scale))"
}
