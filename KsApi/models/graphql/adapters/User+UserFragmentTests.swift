import Foundation
@testable import KsApi
import XCTest

final class User_UserFragmentTests: XCTestCase {
  func testUserCreation_FromFragment_Success() {
    let userFragment = GraphAPI.UserFragment(unsafeResultMap: UserFragmentTemplate.valid.data)

    let user = User.user(from: userFragment)

    XCTAssertEqual(user?.id, 47)
    XCTAssertEqual(user?.avatar.large, "http://www.kickstarter.com/image.jpg")
    XCTAssertEqual(user?.avatar.medium, "http://www.kickstarter.com/image.jpg")
    XCTAssertEqual(user?.avatar.small, "http://www.kickstarter.com/image.jpg")
    XCTAssertEqual(user?.isCreator, false)
    XCTAssertEqual(user?.name, "Billy Bob")
    XCTAssertEqual(user?.erroredBackingsCount, 1)
    XCTAssertTrue(user!.facebookConnected!)
    XCTAssertTrue(user!.isFriend!)
    XCTAssertFalse(user!.isAdmin!)
    XCTAssertEqual(user!.location?.country, "US")
    XCTAssertEqual(user!.location?.displayableName, "Las Vegas, NV")
    XCTAssertEqual(user!.location?.name, "Las Vegas")
    XCTAssertEqual(user!.location?.id, decompose(id: "TG9jYXRpb24tMjQzNjcwNA=="))
    XCTAssertTrue(user!.needsFreshFacebookToken!)
  }
}
