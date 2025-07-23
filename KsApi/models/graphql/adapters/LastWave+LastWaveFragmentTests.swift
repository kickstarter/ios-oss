import GraphAPI
@testable import KsApi
import XCTest

final class LastWave_LastWaveFragmentTests: XCTestCase {
  func test() {
    let lastWaveFragment: GraphAPI.LastWaveFragment = try! testGraphObject(
      jsonString:
      """
        {
            "__typename": "CheckoutWave",
            "id": "Q2hlY2tvdXRXYXZlLTI1OQ==",
            "active": true
        }
      """
    )

    let lastWave = LastWave(fromFragment: lastWaveFragment)
    XCTAssertNotNil(lastWave)
    XCTAssertEqual(lastWave.id, 259)
    XCTAssertTrue(lastWave.active)
  }
}
