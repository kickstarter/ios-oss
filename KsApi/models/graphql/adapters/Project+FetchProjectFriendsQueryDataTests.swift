import Apollo
import ApolloTestSupport
import GraphAPI
import GraphAPITestMocks
@testable import KsApi
import XCTest

final class Project_FetchProjectFriendsQueryDataTests: XCTestCase {
  /// `FetchProjectFriendsQueryBySlug` returns identical data.
  func testFetchProjectFriendsQueryData_Success() {
    let mock = Mock<GraphAPITestMocks.Query>()
    mock.project = Mock<GraphAPITestMocks.Project>()
    mock.project?.friends = Mock<GraphAPITestMocks.ProjectBackerFriendsConnection>()
    // TODO: This needs to fully qualify a user based on a UserFragment, annoyingly.
    mock.project?.friends?.nodes = [
      Mock<GraphAPITestMocks.User>(
        id: "VXNlci0xNzA1MzA0MDA2",
        imageUrl: "https://i.kickstarter.com/assets/033/090/101/8667751e512228a62d426c77f6eb8a0b_original.jpg?anim=false&fit=crop&height=1024&origin=ugc-qa&q=92&width=1024&sig=rx0xtkeNd0nbjmCk7YUFmX6r9wC1ygRS%2BX8OkjVWg%2Bw%3D"
      ),
      Mock<GraphAPITestMocks.User>(
        id: "another id",
        imageUrl: "anotherImage"
      )
    ]

    let data = GraphAPI.FetchProjectFriendsByIdQuery.Data.from(mock)

    let producer = Project.projectFriendsProducer(from: data)
    guard let projectFriendsById = MockGraphQLClient.shared.client.data(from: producer) else {
      XCTFail()

      return
    }

    self.testProjectFriendsProperties_Success(projectFriends: projectFriendsById)
  }

  private func testProjectFriendsProperties_Success(projectFriends: [KsApi.User]) {
    XCTAssertEqual(projectFriends.count, 2)
    XCTAssertEqual(projectFriends[0].id, decompose(id: "VXNlci0xNzA1MzA0MDA2"))
    XCTAssertEqual(
      projectFriends[0].avatar.large,
      "https://i.kickstarter.com/assets/033/090/101/8667751e512228a62d426c77f6eb8a0b_original.jpg?anim=false&fit=crop&height=1024&origin=ugc-qa&q=92&width=1024&sig=rx0xtkeNd0nbjmCk7YUFmX6r9wC1ygRS%2BX8OkjVWg%2Bw%3D"
    )
  }
}
