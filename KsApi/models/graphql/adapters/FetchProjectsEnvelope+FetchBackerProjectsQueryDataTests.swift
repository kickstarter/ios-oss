@testable import KsApi
import XCTest

final class FetchProjectsEnvelope_FetchBackerProjectsQueryDataTests: XCTestCase {
  func testFetchProjectsEnvelope_withValidSavedProjectsData_Success() {
    let envProducer = FetchProjectsEnvelope
      .fetchProjectsEnvelope(from: FetchBackerProjectsQueryDataTemplate.valid.savedProjectsData)

    guard let env = MockGraphQLClient.shared.client.data(from: envProducer) else {
      XCTFail()
      return
    }

    XCTAssertEqual(env.projects.count, 4)
    XCTAssertEqual(env.projects.first?.name, "Zan's Late Pledge Campaign")
    XCTAssertEqual(env.totalCount, 4)
  }

  func testFetchProjectsEnvelope_withValidBackedProjectsData_Success() {
    let envProducer = FetchProjectsEnvelope
      .fetchProjectsEnvelope(from: FetchBackerProjectsQueryDataTemplate.valid.backedProjectsData)

    guard let env = MockGraphQLClient.shared.client.data(from: envProducer) else {
      XCTFail()
      return
    }

    XCTAssertEqual(env.projects.count, 3)
    XCTAssertEqual(env.projects.first?.name, "Zan's Late Pledge Campaign")
    XCTAssertEqual(env.totalCount, 3)
  }
}
