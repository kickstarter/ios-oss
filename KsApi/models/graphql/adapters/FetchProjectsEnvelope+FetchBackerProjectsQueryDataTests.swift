@testable import KsApi
import XCTest

final class FetchProjectsEnvelope_FetchBackerProjectsQueryDataTests: XCTestCase {
  func testFetchProjectsEnvelope_withValidData_Success() {
    let envProducer = FetchProjectsEnvelope
      .fetchProjectsEnvelope(from: FetchBackerProjectsQueryDataTemplate.valid.data)

    guard let env = MockGraphQLClient.shared.client.data(from: envProducer) else {
      XCTFail()
      return
    }

    XCTAssertEqual(env.projects.count, 3)
    XCTAssertEqual(env.projects.first?.name, "The After Death Book One")
    XCTAssertEqual(env.totalCount, 3)
  }
}
