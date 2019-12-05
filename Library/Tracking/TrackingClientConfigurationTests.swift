import Foundation
import KsApi
import Library
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

  func testDataLakeRecordDictionary() {
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
    let request = config.request(config, .staging, data)

    XCTAssertEqual(request?.httpBody, data)
    XCTAssertEqual(request?.httpMethod, "PUT")
    XCTAssertEqual(request?.allHTTPHeaderFields, ["Content-Type": "application/json; charset=utf-8"])
    XCTAssertEqual(request?.url?.absoluteString, Secrets.LakeEndpoint.staging)
  }

  func testDataLakeURL() {
    let config = TrackingClientConfiguration.dataLake

    let stagingUrl = config.url(.staging)
    let productionUrl = config.url(.production)

    XCTAssertEqual(stagingUrl?.absoluteString, Secrets.LakeEndpoint.staging)
    XCTAssertEqual(productionUrl?.absoluteString, Secrets.LakeEndpoint.production)
  }
}
