import Foundation
@testable import KsApi
@testable import Library
import XCTest

final class TrackingClientConfigurationTests: TestCase {
  // MARK: - Koala

  func testKoalaMethod() {
    XCTAssertEqual(TrackingClientConfiguration.koala.httpMethod, .POST)
  }

  func testKoalaIdentifier() {
    XCTAssertEqual(TrackingClientConfiguration.koala.identifier, .koala)
  }

  func testKoalaRecordDictionary() {
    let config = TrackingClientConfiguration.koala

    let recordDictionary = config.recordDictionary("event-name", ["key": "value"])
    let propertiesDictionary = (recordDictionary["properties"] as? [String: Any])

    XCTAssertEqual(recordDictionary["event"] as? String, "event-name")
    XCTAssertEqual(propertiesDictionary?["key"] as? String, "value")
  }

  func testKoalaEnvelope() {
    let config = TrackingClientConfiguration.koala

    let record: [String: Any] = [
      "event": "event-name",
      "properties": ["key": "value"]
    ]

    let recordDictionary = config.envelope(record) as? [String: Any]
    let propertiesDictionary = (recordDictionary?["properties"] as? [String: Any])

    XCTAssertEqual(recordDictionary?["event"] as? String, "event-name")
    XCTAssertEqual(propertiesDictionary?["key"] as? String, "value")
  }

  func testKoalaRequest() {
    let config = TrackingClientConfiguration.koala

    let data = Data("some-data".utf8)
    let request = config.request(config, .staging, data)

    XCTAssertEqual(request?.httpBody, nil)
    XCTAssertEqual(request?.httpMethod, "POST")
    XCTAssertEqual(request?.url?.absoluteString, "\(Secrets.KoalaEndpoint.staging)?data=c29tZS1kYXRh")
  }

  func testKoalaURL() {
    let config = TrackingClientConfiguration.koala

    let stagingUrl = config.url(.staging)
    let productionUrl = config.url(.production)

    XCTAssertEqual(stagingUrl?.absoluteString, Secrets.KoalaEndpoint.staging)
    XCTAssertEqual(productionUrl?.absoluteString, Secrets.KoalaEndpoint.production)
  }

  // MARK: - DataLake

  func testDataLakeMethod() {
    XCTAssertEqual(TrackingClientConfiguration.dataLake.httpMethod, .PUT)
  }

  func testDataLakeIdentifier() {
    XCTAssertEqual(TrackingClientConfiguration.dataLake.identifier, .dataLake)
  }

  func testDataLakeRecordDictionary_LoggedOut_NoIdentifierForVendor() {
    let config = TrackingClientConfiguration.dataLake

    let recordDictionary = config.recordDictionary("event-name", ["key": "value"])
    let propertiesDictionary = (recordDictionary["data"] as? [String: Any])?["properties"] as? [String: Any]

    XCTAssertEqual((recordDictionary["data"] as? [String: Any])?["event"] as? String, "event-name")
    XCTAssertEqual(propertiesDictionary?["key"] as? String, "value")

    guard let uuidString = recordDictionary["partition-key"] as? String else {
      XCTFail("Should have a UUID String")
      return
    }

    XCTAssertNotNil(UUID(uuidString: uuidString))
  }

  func testDataLakeRecordDictionary_LoggedIn_IdentifierForVendor() {
    withEnvironment(currentUser: .template, device: MockDevice()) {
      let config = TrackingClientConfiguration.dataLake

      let recordDictionary = config.recordDictionary("event-name", ["key": "value"])
      let propertiesDictionary = (recordDictionary["data"] as? [String: Any])?["properties"] as? [String: Any]

      XCTAssertEqual((recordDictionary["data"] as? [String: Any])?["event"] as? String, "event-name")
      XCTAssertEqual(propertiesDictionary?["key"] as? String, "value")
      XCTAssertEqual(recordDictionary["partition-key"] as? String, "1")
    }
  }

  func testDataLakeRecordDictionary_LoggedOut_IdentifierForVendor() {
    withEnvironment(device: MockDevice()) {
      let config = TrackingClientConfiguration.dataLake

      let recordDictionary = config.recordDictionary("event-name", ["key": "value"])
      let propertiesDictionary = (recordDictionary["data"] as? [String: Any])?["properties"] as? [String: Any]

      XCTAssertEqual((recordDictionary["data"] as? [String: Any])?["event"] as? String, "event-name")
      XCTAssertEqual(propertiesDictionary?["key"] as? String, "value")
      XCTAssertEqual(recordDictionary["partition-key"] as? String, "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFBEEF")
    }
  }

  func testDataLakeEnvelope() {
    let config = TrackingClientConfiguration.dataLake

    let record: [String: Any] = [
      "data": [
        "event": "event-name",
        "properties": "props"
      ],
      "partition-key": "key"
    ]

    let envelope = config.envelope(record) as? [String: Any]
    let recordDictionary = (envelope?["records"] as? [String: Any])

    XCTAssertTrue(envelope?.keys.contains("records") ?? false)
    XCTAssertEqual((recordDictionary?["data"] as? [String: Any])?["event"] as? String, "event-name")
    XCTAssertEqual((recordDictionary?["data"] as? [String: Any])?["properties"] as? String, "props")
    XCTAssertEqual(recordDictionary?["partition-key"] as? String, "key")
  }

  func testDataLakeRequest() {
    let config = TrackingClientConfiguration.dataLake

    let data = Data("some-data".utf8)
    guard let request = config.request(config, .staging, data) else {
      XCTFail("Should have a request")
      return
    }

    XCTAssertEqual(request.httpBody, data)
    XCTAssertEqual(request.httpMethod, "PUT")
    XCTAssertEqual(request.allHTTPHeaderFields?["Content-Type"], "application/json; charset=utf-8")
    XCTAssertEqual(
      request.url?.absoluteString,
      expectedPreparedURL(with: Secrets.LakeEndpoint.staging)?.absoluteString
    )
    XCTAssertTrue(AppEnvironment.current.apiService.isPrepared(request: request))
  }

  func testDataLakeURL() {
    let config = TrackingClientConfiguration.dataLake

    let stagingUrl = config.url(.staging)
    let productionUrl = config.url(.production)

    XCTAssertEqual(stagingUrl?.absoluteString, Secrets.LakeEndpoint.staging)
    XCTAssertEqual(productionUrl?.absoluteString, Secrets.LakeEndpoint.production)
  }
}

private func expectedPreparedURL(with urlString: String?) -> URL? {
  var components = URLComponents(string: urlString ?? "")

  components?.queryItems = [
    URLQueryItem(
      name: "client_id",
      value: AppEnvironment.current.apiService.serverConfig.apiClientAuth.clientId
    ),
    URLQueryItem(name: "currency", value: "USD")
  ]
  .compactMap { $0 }

  return components?.url
}
