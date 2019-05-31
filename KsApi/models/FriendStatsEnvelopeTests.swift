import Argo
@testable import KsApi
import XCTest

final class FriendStatsEnvelopeTests: XCTestCase {
  func testJsonDecoding() {
    let json: [String: Any] = [
      "stats": [
        "remote_friends_count": 202,
        "friend_projects_count": 1_132
      ]
    ]

    let stats = FriendStatsEnvelope.decodeJSONDictionary(json)

    XCTAssertEqual(202, stats.value?.stats.remoteFriendsCount)
    XCTAssertEqual(1_132, stats.value?.stats.friendProjectsCount)
  }
}
