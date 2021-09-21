import Apollo
@testable import KsApi
import XCTest

final class Project_FetchProjectFriendsQueryDataTests: XCTestCase {
  /// `FetchProjectFriendsQueryBySlug` returns identical data.
  func testFetchProjectFriendsQueryData_Success() {
    let producer = Project.projectFriendsProducer(from: FetchProjectFriendsQueryTemplate.valid.data)
    guard let projectFriendsById = MockGraphQLClient.shared.client.data(from: producer) else {
      XCTFail()

      return
    }

    self.testProjectFriendsProperties_Success(projectFriends: projectFriendsById)
  }

  private func testProjectFriendsProperties_Success(projectFriends: [User]) {
    XCTAssertEqual(projectFriends.count, 2)
    XCTAssertEqual(projectFriends[0].id, decompose(id: "VXNlci0xNzA1MzA0MDA2"))
    XCTAssertEqual(
      projectFriends[0].avatar.large,
      "https://ksr-qa-ugc.imgix.net/assets/033/090/101/8667751e512228a62d426c77f6eb8a0b_original.jpg?ixlib=rb-4.0.2&blur=false&w=1024&h=1024&fit=crop&v=1618227451&auto=format&frame=1&q=92&s=36de925b6797139e096d7b6219f743d0"
    )
  }
}
