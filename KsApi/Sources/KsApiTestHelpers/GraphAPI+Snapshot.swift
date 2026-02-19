import Apollo
import GraphAPI
@testable import KsApi
import XCTest

public extension GraphQLQuery {
  func snapshot(_ snapshotName: String, record: Bool = false, filePath: String = #filePath) -> Data? {
    if record {
      self.toSnapshot(snapshotName, forTestPath: filePath)
    }

    return self.fromSnapshot(snapshotName, forTestPath: filePath)
  }

  internal var stagingClient: ApolloClient {
    // This is currently hardcoded to staging, and it's logged out.
    // It would be a fun party trick to use this only in hosted tests;
    // then you could log into the app and get whatever state you wanted when you hit record.
    let configuration = ServerConfig.staging
    let service = Service(serverConfig: configuration)

    return ApolloClient.client(
      with: configuration.graphQLEndpointUrl,
      headers: service.defaultHeaders,
      additionalHeaders: { service.defaultHeaders }
    )
  }

  internal func snapshotURL(_ snapshotName: String, forTestPath path: String) -> URL {
    let fileUrl = URL(fileURLWithPath: path, isDirectory: false)
    let testDirectory = fileUrl.deletingLastPathComponent()

    // TODO: Put this in a directory like __Data__
    let snapshotName = "\(snapshotName).json"
    return testDirectory.appendingPathComponent(snapshotName)
  }

  internal func toSnapshot(_ snapshotName: String, forTestPath path: String) {
    let snapshotURL = snapshotURL(snapshotName, forTestPath: path)
    let expectation = XCTestExpectation(description: "Fetching GraphQL query for snapshot.")

    let client = self.stagingClient
    client.fetch(query: self, cachePolicy: .fetchIgnoringCacheCompletely) { [weak self] result in
      switch result {
      case let .success(data):
        self?.writeData(data, toURL: snapshotURL)
      case let .failure(error):
        XCTFail("Failed to fetch GraphQL request for snapshot: \(error.localizedDescription)")
      }
      expectation.fulfill()
    }

    let waiter = XCTWaiter()
    waiter.wait(for: [expectation], timeout: 10.0)
  }

  internal func writeData(_ result: GraphQLResult<Self.Data>, toURL snapshotURL: URL) {
    do {
      let data = result.asJSONDictionary()
      let serializedData = try JSONSerialization.data(withJSONObject: data)
      try serializedData.write(to: snapshotURL)

      XCTFail("Successfully recorded snapshot. Turn off recording to make your test pass.")
    } catch {
      XCTFail("Failed to write GraphQL data to snapshot: \(error.localizedDescription)")
    }
  }

  internal func fromSnapshot(_ snapshotName: String, forTestPath path: String) -> Data? {
    let url = self.snapshotURL(snapshotName, forTestPath: path)

    do {
      let jsonData = try Foundation.Data(contentsOf: url)
      let json = try JSONSerialization.jsonObject(with: jsonData) as! JSONObject
      let data = json["data"]
      return try Data.init(data: data as! JSONObject, variables: self.__variables)
    } catch {
      XCTFail("Unable to create data for \(snapshotName). Did you mean to use record?")
      return nil
    }
  }
}
