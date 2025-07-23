import ApolloTestSupport
import GraphAPI
import GraphAPITestMocks
@testable import KsApi
import XCTest

final class WatchProjectResponseEnvelope_UnwatchProjectMutationTests: XCTestCase {
  func test_envelopeFrom() {
    let mock = Mock<GraphAPITestMocks.Mutation>()
    mock.watchProject = Mock<GraphAPITestMocks.WatchProjectPayload>()
    mock.watchProject?.project = Mock<GraphAPITestMocks.Project>()
    mock.watchProject?.project?.id = "id"
    mock.watchProject?.project?.isWatched = false
    mock.watchProject?.project?.watchesCount = 100

    let data = GraphAPI.UnwatchProjectMutation.Data.from(mock)
    let envelopeProducer = WatchProjectResponseEnvelope
      .producer(from: data)
    let envelope = MockGraphQLClient.shared.client.data(from: envelopeProducer)

    XCTAssertEqual(envelope?.watchProject.project.id, "id")
    XCTAssertEqual(envelope?.watchProject.project.isWatched, false)
    XCTAssertEqual(envelope?.watchProject.project.watchesCount, 100)
  }

  func test_envelopeFrom_ReturnsNil() {
    let erroredData: GraphAPI.UnwatchProjectMutation.Data = try! testGraphObject(jsonString: "{}")
    let errorProducer = WatchProjectResponseEnvelope
      .producer(from: erroredData)

    let error = MockGraphQLClient.shared.client.error(from: errorProducer)

    XCTAssertNotNil(error?.ksrCode)
  }
}
