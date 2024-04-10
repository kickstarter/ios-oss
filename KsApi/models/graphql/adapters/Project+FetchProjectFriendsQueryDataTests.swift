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
      "https://i.kickstarter.com/assets/033/090/101/8667751e512228a62d426c77f6eb8a0b_original.jpg?anim=false&fit=crop&height=1024&origin=ugc-qa&q=92&width=1024&sig=rx0xtkeNd0nbjmCk7YUFmX6r9wC1ygRS%2BX8OkjVWg%2Bw%3D"
    )
  }
}
