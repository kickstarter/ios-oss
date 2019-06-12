@testable import KsApi
import XCTest

final class UserAvatarTests: XCTestCase {
  func testJsonEncoding() {
    let json: [String: Any] = [
      "medium": "http://www.kickstarter.com/medium.jpg",
      "small": "http://www.kickstarter.com/small.jpg"
    ]
    let avatar = User.Avatar.decodeJSONDictionary(json)

    XCTAssertEqual(avatar.value?.medium, json["medium"] as? String)
    XCTAssertEqual(avatar.value?.small, json["small"] as? String)
  }
}
