@testable import KsApi
import XCTest

final class WatchProjectResponseEnvelope_WatchProjectMutationTests: XCTestCase {
  func test_envelopeFrom() {
    let envelope = WatchProjectResponseEnvelope.from(WatchProjectResponseMutationTemplate.valid.data)

    XCTAssertEqual(envelope?.watchProject.project.id, "id")
    XCTAssertEqual(envelope?.watchProject.project.isWatched, true)
  }

  func test_envelopeFrom_ReturnsNil() {
    XCTAssertNil(WatchProjectResponseEnvelope.from(WatchProjectResponseMutationTemplate.errored.data))
  }
}
