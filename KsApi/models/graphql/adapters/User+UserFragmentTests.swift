import Foundation
@testable import KsApi
import XCTest

final class User_UserFragmentTests: XCTestCase {
  func test() {
    let userFragment = GraphAPI.UserFragment(
      id: "Q2F0ZWdvcnktNDc=",
      imageUrl: "http://www.kickstarter.com/image.jpg",
      isCreator: false,
      name: "Billy Bob",
      uid: "47"
    )

    let user = User.user(from: userFragment)

    XCTAssertEqual(user?.id, 47)
    XCTAssertEqual(user?.avatar.large, "http://www.kickstarter.com/image.jpg")
    XCTAssertEqual(user?.avatar.medium, "http://www.kickstarter.com/image.jpg")
    XCTAssertEqual(user?.avatar.small, "http://www.kickstarter.com/image.jpg")
    XCTAssertEqual(user?.isCreator, false)
    XCTAssertEqual(user?.name, "Billy Bob")
  }
}
