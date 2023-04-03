import Foundation
@testable import KsApi
import XCTest

final class GraphUserMemberStatusTests: XCTestCase {
  func testDecoding_NoNilValues() {
    let dictionary: [String: Any] =
      [
        "creatorProjectsTotalCount": 12,
        "memberProjectsTotalCount": 20
      ]

    guard let data = try? JSONSerialization.data(withJSONObject: dictionary, options: []) else {
      XCTFail("JSON should be convertible to data")

      return
    }

    do {
      let userMemberStatus = try JSONDecoder().decode(GraphUserMemberStatus.self, from: data)

      XCTAssertEqual(userMemberStatus.creatorProjectsTotalCount, 12)
      XCTAssertEqual(userMemberStatus.memberProjectsTotalCount, 20)
    } catch {
      XCTFail("Failed to decode \(error)")
    }
  }
}
