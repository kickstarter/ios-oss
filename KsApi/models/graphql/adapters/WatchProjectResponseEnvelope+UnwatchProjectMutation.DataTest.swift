@testable import KsApi
import XCTest

final class WatchProjectResponseEnvelope_UnwatchProjectMutationTests: XCTestCase {
  func test_envelopeFrom() {
    let envelope = WatchProjectResponseEnvelope.from(WatchProjectResponseMutationTemplate.valid(watched: false).data)

    XCTAssertEqual(envelope?.watchProject.project.id, "id")
    XCTAssertEqual(envelope?.watchProject.project.isWatched, false)

    XCTAssertEqual(WatchProjectResponseEnvelope.producer(from: WatchProjectResponseMutationTemplate.valid(watched: false).data).allValues().count, 1)
  }

  func test_envelopeFrom_ReturnsNil() {
    XCTAssertNil(WatchProjectResponseEnvelope.from(WatchProjectResponseMutationTemplate.errored(watched: false).data))
  }
}
