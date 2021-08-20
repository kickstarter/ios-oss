@testable import KsApi
import XCTest

final class WatchProjectResponseEnvelope_UnwatchProjectMutationTests: XCTestCase {
  func test_envelopeFrom() {
    let envelopeProducer = WatchProjectResponseEnvelope
      .producer(from: WatchProjectResponseMutationTemplate.valid(watched: false).unwatchData)
    let envelope = MockGraphQLClient.shared.client.data(from: envelopeProducer)

    XCTAssertEqual(envelope?.watchProject.project.id, "id")
    XCTAssertEqual(envelope?.watchProject.project.isWatched, false)
  }

  func test_envelopeFrom_ReturnsNil() {
    let errorProducer = WatchProjectResponseEnvelope
      .producer(from: WatchProjectResponseMutationTemplate.errored(watched: false).unwatchData)

    let error = MockGraphQLClient.shared.client.error(from: errorProducer)

    XCTAssertNotNil(error?.ksrCode)
  }
}
