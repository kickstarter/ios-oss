@testable import KsApi
import XCTest

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
      ),
      graphQLEndpointUrl: URL(string: "http://www.ksr.com")!
    ),
    oauthToken: OauthToken(
      token: "cafebeef"
    ),
    language: "ksr",
    buildVersion: "1234567890",
    deviceIdentifier: "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFBEEF"
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
      ),
      graphQLEndpointUrl: URL(string: "http://ksr.dev/graph")!
    ),
    deviceIdentifier: "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFBEEF"
  )

  private let anonService = Service(
    appId: "com.kickstarter.test",
    serverConfig: ServerConfig(
      apiBaseUrl: URL(string: "http://api.ksr.com")!,
      webBaseUrl: URL(string: "http://hq.ksr.com")!,
      apiClientAuth: ClientAuth(
        clientId: "deadbeef"
      ),
      basicHTTPAuth: nil,
      graphQLEndpointUrl: URL(string: "http://ksr.dev/graph")!
    ),
    deviceIdentifier: "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFBEEF"
  )

  func testEquals() {
    XCTAssertTrue(Service() != MockService())
  }

  func testIsPreparedAdhocWithoutOauthToken() {
    let url = URL(string: "http://api-dev.ksr.com/v1/test?key=value")!
    let request = URLRequest(url: url)
    XCTAssertFalse(self.anonAdHocService.isPrepared(request: request))
    XCTAssertTrue(self.anonAdHocService.isPrepared(
      request:
      self.anonAdHocService.preparedRequest(forRequest: request)
    )
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
      request.url?.absoluteString
    )
    XCTAssertEqual(
      [
        "Kickstarter-iOS-App": "1234567890",
        "Authorization": "token cafebeef",
        "Accept-Language": "ksr",
        "Kickstarter-App-Id": "com.kickstarter.test",
        "X-KICKSTARTER-CLIENT": "deadbeef",
        "User-Agent": userAgent(),
        "Kickstarter-iOS-App-UUID": "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFBEEF"
      ],
      request.allHTTPHeaderFields!
    )
  }

  func testPreparedURL() {
    let url = URL(string: "http://api.ksr.com/v1/test?key=value")!
    let request = self.service.preparedRequest(forURL: url, query: ["extra": "1"])

    XCTAssertEqual(
      "http://api.ksr.com/v1/test?client_id=deadbeef&currency=USD&extra=1&key=value&oauth_token=cafebeef",
      request.url?.absoluteString
    )
    XCTAssertEqual(
      [
        "Kickstarter-iOS-App": "1234567890",
        "Authorization": "token cafebeef",
        "Accept-Language": "ksr",
        "Kickstarter-App-Id": "com.kickstarter.test",
        "X-KICKSTARTER-CLIENT": "deadbeef",
        "User-Agent": userAgent(),
        "Kickstarter-iOS-App-UUID": "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFBEEF"
      ],
      request.allHTTPHeaderFields!
    )
    XCTAssertEqual("GET", request.httpMethod)
  }

  func testPreparedDeleteURL() {
    let url = URL(string: "http://api.ksr.com/v1/test?key=value")!
    let request = self.service.preparedRequest(forURL: url, method: .DELETE, query: ["extra": "1"])

    XCTAssertEqual(
      "http://api.ksr.com/v1/test?client_id=deadbeef&currency=USD&extra=1&key=value&oauth_token=cafebeef",
      request.url?.absoluteString
    )
    XCTAssertEqual(
      [
        "Kickstarter-iOS-App": "1234567890",
        "Authorization": "token cafebeef",
        "Accept-Language": "ksr",
        "Kickstarter-App-Id": "com.kickstarter.test",
        "X-KICKSTARTER-CLIENT": "deadbeef",
        "User-Agent": userAgent(),
        "Kickstarter-iOS-App-UUID": "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFBEEF"
      ],
      request.allHTTPHeaderFields!
    )
    XCTAssertEqual("DELETE", request.httpMethod)
  }

  func testPreparedPostURL() {
    let url = URL(string: "http://api.ksr.com/v1/test?key=value")!
    let request = self.service.preparedRequest(forURL: url, method: .POST, query: ["extra": "1"])

    XCTAssertEqual(
      "http://api.ksr.com/v1/test?client_id=deadbeef&currency=USD&key=value&oauth_token=cafebeef",
      request.url?.absoluteString
    )
    XCTAssertEqual(
      [
        "Kickstarter-iOS-App": "1234567890",
        "Authorization": "token cafebeef",
        "Accept-Language": "ksr",
        "Kickstarter-App-Id": "com.kickstarter.test",
        "Content-Type": "application/json; charset=utf-8",
        "X-KICKSTARTER-CLIENT": "deadbeef",
        "User-Agent": userAgent(),
        "Kickstarter-iOS-App-UUID": "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFBEEF"
      ],
      request.allHTTPHeaderFields!
    )
    XCTAssertEqual("POST", request.httpMethod)
    XCTAssertEqual(
      "{\"extra\":\"1\"}",
      String(data: request.httpBody ?? Data(), encoding: .utf8)
    )
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
      request.url?.absoluteString
    )
    XCTAssertEqual(
      [
        "Kickstarter-iOS-App": "1234567890",
        "Authorization": "token cafebeef",
        "Accept-Language": "ksr",
        "Kickstarter-App-Id": "com.kickstarter.test",
        "X-KICKSTARTER-CLIENT": "deadbeef",
        "User-Agent": userAgent(),
        "Kickstarter-iOS-App-UUID": "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFBEEF"
      ],
      request.allHTTPHeaderFields!
    )
    XCTAssertEqual("POST", request.httpMethod)
    XCTAssertEqual(body, request.httpBody, "Body remains unchanged")
  }

  func testPreparedAdHocWithoutOauthToken() {
    let url = URL(string: "http://api-hq.ksr.com/v1/test?key=value")!
    let request = self.anonAdHocService.preparedRequest(forRequest: .init(url: url))

    XCTAssertEqual(
      "http://api-hq.ksr.com/v1/test?client_id=deadbeef&currency=USD&key=value",
      request.url?.absoluteString
    )
    XCTAssertEqual(
      [
        "Kickstarter-iOS-App": "\(testToolBuildNumber())",
        "Authorization": "Basic dXNlcm5hbWU6cGFzc3dvcmQ=",
        "Accept-Language": "en",
        "Kickstarter-App-Id": "com.kickstarter.test",
        "X-KICKSTARTER-CLIENT": "deadbeef",
        "User-Agent": userAgent(),
        "Kickstarter-iOS-App-UUID": "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFBEEF"
      ],
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
        ),
        graphQLEndpointUrl: URL(string: "http://ksr.dev/graph")!
      ),
      deviceIdentifier: "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFBEEF"
    )

    let url = URL(string: "http://api.ksr.com/v1/test?key=value")!
    let request = anonService.preparedRequest(forRequest: .init(url: url))

    XCTAssertEqual(
      "http://api.ksr.com/v1/test?client_id=deadbeef&currency=USD&key=value",
      request.url?.absoluteString
    )
    XCTAssertEqual(
      [
        "Kickstarter-iOS-App": "\(testToolBuildNumber())",
        "Authorization": "Basic dXNlcm5hbWU6cGFzc3dvcmQ=",
        "Accept-Language": "en",
        "Kickstarter-App-Id": "com.kickstarter.test",
        "X-KICKSTARTER-CLIENT": "deadbeef",
        "User-Agent": userAgent(),
        "Kickstarter-iOS-App-UUID": "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFBEEF"
      ],
      request.allHTTPHeaderFields!
    )
  }

  func testPreparedGraphRequest() {
    let url = self.service.serverConfig.graphQLEndpointUrl
    let request = try? self.service.preparedGraphRequest(
      forURL: url,
      queryString: "mutation",
      input: ["mutation_input": 123]
    )

    let jsonBody = try? JSONSerialization.jsonObject(
      with: request?.httpBody ?? Data(capacity: 1),
      options: []
    )

    XCTAssertNotNil(request)
    XCTAssertEqual(request?.httpMethod, "POST")
    XCTAssertEqual(request?.allHTTPHeaderFields?["Content-Type"], "application/json; charset=utf-8")
    XCTAssertNotNil(jsonBody)
    XCTAssertEqual(request?.allHTTPHeaderFields?["Accept-Language"], self.service.language)
    XCTAssertEqual(request?.allHTTPHeaderFields?["Authorization"], "token cafebeef")
    XCTAssertEqual(request?.allHTTPHeaderFields?["Kickstarter-App-Id"], self.service.appId)
    XCTAssertEqual(request?.allHTTPHeaderFields?["Kickstarter-iOS-App"], self.service.buildVersion)
    XCTAssertEqual(request?.allHTTPHeaderFields?["X-KICKSTARTER-CLIENT"], "deadbeef")
    XCTAssertEqual(request?.allHTTPHeaderFields?["User-Agent"], userAgent())
    XCTAssertEqual(
      request?.allHTTPHeaderFields?["Kickstarter-iOS-App-UUID"],
      "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFBEEF"
    )
  }

  func testGraphMutationRequestBody() {
    let body: [String: Any] = self.service.graphMutationRequestBody(
      mutation: "my_mutation",
      input: ["foo_bar": 123]
    )
    let variables = body["variables"] as? [String: Any]
    let input = variables?["input"] as? [String: Any]
    let foobar = input?["foo_bar"] as? Int

    XCTAssertEqual(body["query"] as? String, "my_mutation")
    XCTAssertNotNil(variables)
    XCTAssertNotNil(input)
    XCTAssertEqual(foobar, 123)
  }
}

// swiftformat:disable wrap
private func userAgent() -> String {
  return """
  com.apple.dt.xctest.tool/\(testToolBuildNumber()) (\(UIDevice.current.model); iOS \(UIDevice.current.systemVersion) Scale/\(UIScreen.main.scale))
  """
}

// swiftformat:enable wrap

private func testToolBuildNumber() -> String {
  return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
}
