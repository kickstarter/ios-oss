import Foundation
@testable import KsApi
import ReactiveSwift
import XCTest

final class ErroredBackingsEnvelopeTests: XCTestCase {
  func testErroredBackingsEnvelope_Success() {
    let producer = ErroredBackingsEnvelope.producer(from: FetchUserBackingsQueryTemplate.valid.data)

    /** TODO: Ensure `ErroredBackingsEnvelope` conforms to `Decodable` before testing
     let envelope = MockGraphQLClient.shared.client.dataFromProducer(producer)
     */

    XCTAssertNotNil(producer)
  }
}
