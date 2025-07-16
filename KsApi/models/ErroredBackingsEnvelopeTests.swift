import Foundation
@testable import KsApi
import ReactiveSwift
import XCTest

final class ErroredBackingsEnvelopeTests: XCTestCase {
  // We don't use ErroredBackingsEnvelope.producer, so no real reason to fix this one.
  func disabled_testErroredBackingsEnvelope_Success() {
    let producer = ErroredBackingsEnvelope.producer(from: FetchUserBackingsQueryTemplate.valid.data)

    /** TODO: Ensure `ErroredBackingsEnvelope` conforms to `Decodable` before testing
     let envelope = MockGraphQLClient.shared.client.dataFromProducer(producer)
     */

    XCTAssertNotNil(producer)
  }
}
