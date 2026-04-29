import GraphAPI
@testable import Kickstarter_Framework
@testable import KsApi
@testable import KsApiTestHelpers
@testable import Library
@testable import LibraryTestHelpers
import XCTest

final class VideoFeedViewModelTests: TestCase {
  private let vm = VideoFeedViewModel()

  func testViewDidLoad_Success_PopulatesItems() async {
    let mockData = Self.mockVideoFeedQueryData(nodeCount: 3)

    await withEnvironment(apiService: MockService(fetchGraphQLResponses: [(VideoFeedQuery.self, mockData)])) {
      await self.vm.fetchVideoFeed()
    }

    XCTAssertEqual(self.vm.items.count, 3)
    XCTAssertFalse(self.vm.isLoading)
    XCTAssertNil(self.vm.errorMessage)
  }

  func testViewDidLoad_Failure_SetsErrorMessage() async {
    await withEnvironment(apiService: MockService(fetchGraphQLResponses: [])) {
      await self.vm.fetchVideoFeed()
    }

    XCTAssertTrue(self.vm.items.isEmpty)
    XCTAssertFalse(self.vm.isLoading)
    XCTAssertNotNil(self.vm.errorMessage)
  }

  // MARK: - Helpers

  private static func mockVideoFeedQueryData(nodeCount: Int) -> VideoFeedQuery.Data {
    let nodes: [VideoFeedQuery.Data.VideoFeed.Node] = (0..<nodeCount).map { i in
      let pledged = VideoFeedQuery.Data.VideoFeed.Node.Project.Pledged(amount: "1000")

      let creator = VideoFeedQuery.Data.VideoFeed.Node.Project.Creator(
        name: "Creator \(i)",
        imageUrl: "https://test.com/avatar\(i).jpg"
      )

      let category = VideoFeedQuery.Data.VideoFeed.Node.Project.Category(name: "Design")

      let project = VideoFeedQuery.Data.VideoFeed.Node.Project(
        id: "project-\(i)",
        pid: i,
        name: "Project \(i)",
        slug: "project-\(i)",
        percentFunded: 75,
        backersCount: 100,
        pledged: pledged,
        creator: creator,
        category: category
      )

      return VideoFeedQuery.Data.VideoFeed.Node(badges: [], project: project)
    }

    let pageInfo = VideoFeedQuery.Data.VideoFeed.PageInfo(
      hasNextPage: false,
      hasPreviousPage: false
    )

    let feed = VideoFeedQuery.Data.VideoFeed(pageInfo: pageInfo, nodes: nodes)

    return VideoFeedQuery.Data(videoFeed: feed)
  }
}
