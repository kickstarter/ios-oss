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
    let mockData = Self.mockVideoFeedQueryData(itemCount: 3)

    await withEnvironment(apiService: MockService(fetchGraphQLResponses: [(VideoFeedQuery.self, mockData)])) {
      await self.vm.fetchVideoFeed()
    }

    XCTAssertEqual(self.vm.items.count, 3)
    XCTAssertFalse(self.vm.isLoading)
    XCTAssertNil(self.vm.errorMessage)
  }

  func testViewDidLoad_Success() async {
    let mockData = Self.mockVideoFeedQueryData(itemCount: 3)

    await withEnvironment(apiService: MockService(fetchGraphQLResponses: [(VideoFeedQuery.self, mockData)])) {
      await self.vm.fetchVideoFeed()
    }

    XCTAssertEqual(self.vm.items.map(\.id), ["project-0", "project-1", "project-2"])
  }

  func testViewDidLoad_Success_MapsVerticalVideoToVideoURL() async {
    let hlsURL = "https://test.com/video.mp4"
    let previewURL = "https://test.com/preview.jpg"
    let mockData = Self.mockVideoFeedQueryData(
      itemCount: 1,
      hlsSrc: hlsURL,
      previewImageUrl: previewURL
    )

    await withEnvironment(apiService: MockService(fetchGraphQLResponses: [(VideoFeedQuery.self, mockData)])) {
      await self.vm.fetchVideoFeed()
    }

    XCTAssertEqual(self.vm.items.first?.videoURL?.absoluteString, hlsURL)
    XCTAssertEqual(self.vm.items.first?.videoPreviewImageURL?.absoluteString, previewURL)
  }

  func testViewDidLoad_Success_EmptyResponse() async {
    let mockData = Self.mockVideoFeedQueryData(itemCount: 0)

    await withEnvironment(apiService: MockService(fetchGraphQLResponses: [(VideoFeedQuery.self, mockData)])) {
      await self.vm.fetchVideoFeed()
    }

    XCTAssertTrue(self.vm.items.isEmpty)
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

  func testToggleSaved_Watch_UpdatesIsSaved() async {
    let mockData = Self.mockVideoFeedQueryData(itemCount: 1, isWatched: false)

    await withEnvironment(apiService: MockService(fetchGraphQLResponses: [(VideoFeedQuery.self, mockData)])) {
      await self.vm.fetchVideoFeed()
    }

    let item = try! XCTUnwrap(self.vm.items.first)

    XCTAssertFalse(item.isSaved)

    self.vm.toggleSaved(for: item)

    XCTAssert(self.vm.items.first?.isSaved == true)
  }

  func testToggleSaved_Unwatch_UpdatesIsSaved() async {
    let mockData = Self.mockVideoFeedQueryData(itemCount: 1, isWatched: true)

    await withEnvironment(apiService: MockService(fetchGraphQLResponses: [(VideoFeedQuery.self, mockData)])) {
      await self.vm.fetchVideoFeed()
    }

    let item = try! XCTUnwrap(self.vm.items.first)

    XCTAssertTrue(item.isSaved)

    self.vm.toggleSaved(for: item)

    XCTAssert(self.vm.items.first?.isSaved == false)
  }

  func testToggleSaved_OnlyAffectsSelectItems() async {
    let mockData = Self.mockVideoFeedQueryData(itemCount: 3, isWatched: false)

    await withEnvironment(apiService: MockService(fetchGraphQLResponses: [(VideoFeedQuery.self, mockData)])) {
      await self.vm.fetchVideoFeed()
    }

    let secondItem = try! XCTUnwrap(self.vm.items[1])

    self.vm.toggleSaved(for: secondItem)

    XCTAssertFalse(self.vm.items[0].isSaved, "First item should be unaffected.")
    XCTAssertTrue(self.vm.items[1].isSaved, "Second item should be toggled.")
    XCTAssertFalse(self.vm.items[2].isSaved, "Third item should be unaffected.")
  }

  func testFetchVideoFeed_SetsIsWatched() async {
    let mockData = Self.mockVideoFeedQueryData(itemCount: 3, isWatched: true)

    await withEnvironment(apiService: MockService(fetchGraphQLResponses: [(VideoFeedQuery.self, mockData)])) {
      await self.vm.fetchVideoFeed()
    }

    XCTAssertTrue(self.vm.items.allSatisfy { $0.isSaved })
  }

  // MARK: - Helpers

  private static func mockVideoFeedQueryData(
    itemCount: Int,
    hlsSrc: String? = nil,
    previewImageUrl: String? = nil,
    isWatched: Bool = false
  ) -> VideoFeedQuery.Data {
    let nodes: [VideoFeedQuery.Data.VideoFeed.Node] = (0..<itemCount).map { i in
      let pledged = VideoFeedQuery.Data.VideoFeed.Node.Project.Pledged(amount: "1000")

      let creator = VideoFeedQuery.Data.VideoFeed.Node.Project.Creator(
        name: "Creator \(i)",
        imageUrl: "https://test.com/avatar\(i).jpg"
      )

      let category = VideoFeedQuery.Data.VideoFeed.Node.Project.Category(name: "Design")

      let verticalVideo: VideoFeedQuery.Data.VideoFeed.Node.Project.VerticalVideo? = hlsSrc.map { src in
        let hls = ProjectVideoFeedFragment.VerticalVideo.VideoSources.Hls(src: src)
        let videoSources = ProjectVideoFeedFragment.VerticalVideo.VideoSources(hls: hls)

        return ProjectVideoFeedFragment.VerticalVideo(
          id: "id-\(i)",
          previewImageUrl: previewImageUrl,
          videoSources: videoSources
        )
      }

      let project = VideoFeedQuery.Data.VideoFeed.Node.Project(
        id: "project-\(i)",
        pid: i,
        name: "Project \(i)",
        slug: "project-\(i)",
        percentFunded: 75,
        backersCount: 100,
        isWatched: isWatched,
        pledged: pledged,
        creator: creator,
        category: category,
        verticalVideo: verticalVideo,
        sharesCount: 2,
        watchesCount: 3
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
