@testable import KsApi
import XCTest
import ApolloTestSupport
import GraphAPI

final class WatchProjectResponseEnvelope_WatchProjectMutationTests: XCTestCase {
  func test_envelopeFrom() {
    let mock = Mock<WatchProjectPayload>()
    mock.project = Mock<Project>()
    mock.project?.id = "id"
    mock.project?.isWatched = true
    mock.project?.watchesCount = 100

    
    let data = GraphAPI.WatchProjectMutation.Data.from(mock)

    let envelopeProducer = WatchProjectResponseEnvelope
      .producer(from: WatchProjectResponseMutationTemplate.valid(watched: true).watchData)

    let envelope = MockGraphQLClient.shared.client.data(from: envelopeProducer)

    XCTAssertEqual(envelope?.watchProject.project.id, "id")
    XCTAssertEqual(envelope?.watchProject.project.isWatched, true)
    XCTAssertEqual(envelope?.watchProject.project.watchesCount, 100)
  }

  func fixable_test_envelopeFrom_ReturnsNil() {
    let errorProducer = WatchProjectResponseEnvelope
      .producer(from: WatchProjectResponseMutationTemplate.errored(watched: true).watchData)
    let error = MockGraphQLClient.shared.client.error(from: errorProducer)

    XCTAssertNotNil(error?.ksrCode)
  }
}
