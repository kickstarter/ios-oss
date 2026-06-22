import GraphAPI
@testable import Kickstarter_Framework
@testable import KsApi
@testable import KsApiTestHelpers
@testable import Library
@testable import LibraryTestHelpers
import SwiftUI
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
    XCTAssertEqual(self.vm.errorMessage, Strings.Something_went_wrong_please_try_again())
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

    XCTAssertTrue(self.vm.items.first?.isSaved == true)
    XCTAssertEqual(self.vm.items.first?.watchesCount, 4)
  }

  func testToggleSaved_Unwatch_UpdatesIsSaved() async {
    let mockData = Self.mockVideoFeedQueryData(itemCount: 1, isWatched: true)

    await withEnvironment(apiService: MockService(fetchGraphQLResponses: [(VideoFeedQuery.self, mockData)])) {
      await self.vm.fetchVideoFeed()
    }

    let item = try! XCTUnwrap(self.vm.items.first)

    XCTAssertTrue(item.isSaved)

    self.vm.toggleSaved(for: item)

    XCTAssertTrue(self.vm.items.first?.isSaved == false)
    XCTAssertEqual(self.vm.items.first?.watchesCount, 2)
  }

  func testToggleSaved_WatchesCountIncrementsOptimistically() async {
    let mockData = Self.mockVideoFeedQueryData(itemCount: 1, isWatched: false)

    await withEnvironment(apiService: MockService(fetchGraphQLResponses: [(VideoFeedQuery.self, mockData)])) {
      await self.vm.fetchVideoFeed()
    }

    let item = try! XCTUnwrap(self.vm.items.first)
    let originalCount = item.watchesCount

    self.vm.toggleSaved(for: item)
    XCTAssertEqual(self.vm.items.first?.watchesCount, originalCount + 1, "Count should increment on save.")
  }

  func testToggleSaved_WatchesCountDecrementsOptimistically() async {
    let mockData = Self.mockVideoFeedQueryData(itemCount: 1, isWatched: true)

    await withEnvironment(apiService: MockService(fetchGraphQLResponses: [(VideoFeedQuery.self, mockData)])) {
      await self.vm.fetchVideoFeed()
    }

    let item = try! XCTUnwrap(self.vm.items.first)
    let originalCount = item.watchesCount

    self.vm.toggleSaved(for: item)
    XCTAssertEqual(self.vm.items.first?.watchesCount, originalCount - 1, "Count should decrement on unsave.")
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

  func testViewWillAppear_UpdateSave_WhenLoggedIn() async {
    let mockData = Self.mockVideoFeedQueryData(itemCount: 1, isWatched: false)

    await withEnvironment(apiService: MockService(fetchGraphQLResponses: [(VideoFeedQuery.self, mockData)])) {
      await self.vm.fetchVideoFeed()
    }

    let item = try! XCTUnwrap(self.vm.items.first)

    /// Simulate logged-out save tap
    withEnvironment(currentUser: nil) {
      let binding = self.vm.isSaved(projectId: item.id)
      binding.wrappedValue = true
    }

    XCTAssertEqual(self.vm.items.first?.isSaved, false, "Should not have saved yet. user was logged out.")

    /// Simulate login and return to feed.
    withEnvironment(currentUser: .template) {
      self.vm.userSessionStarted()
    }

    XCTAssertTrue(self.vm.items.first?.isSaved == true, "Should have saved after logging in.")
    XCTAssertEqual(self.vm.items.first?.watchesCount, 4, "Count should increment after deferred save fires.")

    /// Same flow but staying logged out.
    let vm2 = VideoFeedViewModel()

    await withEnvironment(apiService: MockService(fetchGraphQLResponses: [(VideoFeedQuery.self, mockData)])) {
      await vm2.fetchVideoFeed()
    }

    let item2 = try! XCTUnwrap(vm2.items.first)

    withEnvironment(currentUser: nil) {
      let binding = vm2.isSaved(projectId: item2.id)
      binding.wrappedValue = true

      vm2.userSessionStarted()
    }

    XCTAssertEqual(vm2.items.first?.isSaved, false, "Should not save if user is still logged out.")
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
        url: "https://test.com",
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
