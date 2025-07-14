import ApolloTestSupport
import GraphAPI
import GraphAPITestMocks
@testable import KsApi
import XCTest

final class WatchProjectResponseEnvelope_WatchProjectMutationTests: XCTestCase {
  func test_envelopeFrom() {
    let mock = Mock<GraphAPITestMocks.Mutation>()
    // One odd thing with the autogen mocks is it typed this as
    // UnwatchProjectPayload and not WatchProjectPayload. Related?
    // Need to dig more into why those are two separate types,
    // but AFAICT it doesn't seem to affect this particular bug.
    mock.watchProject = Mock<GraphAPITestMocks.UnwatchProjectPayload>()
    mock.watchProject?.project = Mock<GraphAPITestMocks.Project>()
    mock.watchProject?.project?.id = "id"
    mock.watchProject?.project?.isWatched = true
    mock.watchProject?.project?.watchesCount = 100

    let data = GraphAPI.WatchProjectMutation.Data.from(mock)

    // These calls work!
    XCTAssertNotNil(data.watchProject)
    XCTAssertNotNil(data.watchProject?.project)

    // But this breaks when it calls data.watchProject!
    let envelopeProducer = WatchProjectResponseEnvelope
      .producer(from: data)

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
