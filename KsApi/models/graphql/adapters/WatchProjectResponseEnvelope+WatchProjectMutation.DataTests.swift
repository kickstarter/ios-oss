@testable import KsApi
import XCTest

final class WatchProjectResponseEnvelope_WatchProjectMutationTests: XCTestCase {
  func test_envelopeFrom() {
    let envelopeProducer = WatchProjectResponseEnvelope
      .producer(from: WatchProjectResponseMutationTemplate.valid(watched: true).watchData)

    let envelope = MockGraphQLClient.shared.client.dataFromProducer(envelopeProducer)

    XCTAssertEqual(envelope?.watchProject.project.id, "id")
    XCTAssertEqual(envelope?.watchProject.project.isWatched, true)
  }

  func test_envelopeFrom_ReturnsNil() {
    let errorProducer = WatchProjectResponseEnvelope
      .producer(from: WatchProjectResponseMutationTemplate.errored(watched: true).watchData)
    let error = MockGraphQLClient.shared.client.errorFromProducer(errorProducer)

    XCTAssertNotNil(error?.ksrCode)
  }
}
