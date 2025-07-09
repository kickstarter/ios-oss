@testable import KsApi
import XCTest

final class PledgeManager_PledgeManagerFragmentTests: XCTestCase {
  func test() {
    let pmFragment: GraphAPI.PledgeManagerFragment = testGraphObject(
      data: [
        "id": "UGxlZGdlTWFuYWdlci05MQ==",
        "acceptsNewBackers": true
      ]
    )

    let pledgeManager = PledgeManager(fromFragment: pmFragment)
    XCTAssertNotNil(pledgeManager)
    XCTAssertEqual(pledgeManager.id, 91)
    XCTAssertTrue(pledgeManager.acceptsNewBackers)
  }
}
