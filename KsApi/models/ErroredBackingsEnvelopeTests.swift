import Foundation
@testable import KsApi
import ReactiveSwift
import XCTest

final class ErroredBackingsEnvelopeTests: XCTestCase {
  // TODO: This test can be removed once these API calls are cleaned up.
  // https://kickstarter.atlassian.net/browse/MBL-2255
  // It's currently broken because of the Apollo upgrade.
  func disabled_testErroredBackingsEnvelope_Success() {
    let producer = ErroredBackingsEnvelope.producer(from: FetchUserBackingsQueryTemplate.valid.data)

    /** TODO: Ensure `ErroredBackingsEnvelope` conforms to `Decodable` before testing
     let envelope = MockGraphQLClient.shared.client.dataFromProducer(producer)
     */

    XCTAssertNotNil(producer)
  }
}
