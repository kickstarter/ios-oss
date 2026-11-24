import ApolloTestSupport
import GraphAPI
import GraphAPITestMocks
@testable import KsApi
import KsApiTestHelpers
import XCTest

public final class ProjectPageFetcherTests: XCTestCase {
  func test_newProjectFetch_returnsAllData() {
    let mockService = MockService(
      fetchGraphQLResponses: [
        (
          GraphAPI.FastFetchProjectPageBaseQuery.self,
          GraphAPI.FastFetchProjectPageBaseQuery.Data.template
        ),
        (
          GraphAPI.FastFetchProjectPageExtendedPropertiesQuery.self,
          GraphAPI.FastFetchProjectPageExtendedPropertiesQuery.Data.template
        )
      ]
    )

    let fetcher = ProjectPageFetcher(withService: mockService)

    let producer = fetcher.fastFetchProjectPage(projectParam: .id(0), includeStoryRichText: false)
    guard let project = producer.allValues().first else {
      XCTFail("Fetcher should have produced a project")
      return
    }

    XCTAssertEqual(project.id, 987)
    XCTAssertEqual(project.name, "The project")

    XCTAssertEqual(project.personalization.isBacking, true)
    XCTAssertNotNil(project.personalization.backing)

    XCTAssertEqual(project.rewards.count, 2)
    XCTAssertEqual(project.rewards.first, Reward.noReward)
    XCTAssertEqual(project.rewards[1].id, 1)

    XCTAssertNotNil(project.video)
    XCTAssertEqual(project.video?.high, "high.mp4")
    XCTAssertNotNil(project.extendedProjectProperties)
    XCTAssertEqual(project.extendedProjectProperties?.risks, "This project has risks.")
    XCTAssertEqual(project.flagging, true)
  }

  func test_newProjectFetch_returnsErrorIfFirstFetchHasErrors() {
    let mockService = MockService(
      fetchGraphQLResponses: [
        // Intentionally missing the first mock to trigger an error
        (
          GraphAPI.FastFetchProjectPageExtendedPropertiesQuery.self,
          GraphAPI.FastFetchProjectPageExtendedPropertiesQuery.Data.template
        )
      ]
    )

    let fetcher = ProjectPageFetcher(withService: mockService)
    let producer = fetcher.fastFetchProjectPage(projectParam: .id(0), includeStoryRichText: false)

    XCTAssertEqual(producer.allValues().count, 0)
    guard let errorResult = producer.collect().last(),
          case let .failure(errorEnvelope) = errorResult else {
      XCTFail("Expected error")
      return
    }

    XCTAssertEqual(errorEnvelope.errorMessages, ["Unimplemented mock"])
  }

  func test_newProjectFetch_returnsErrorIfSecondFetchHasErrors() {
    let mockService = MockService(
      fetchGraphQLResponses: [
        (
          GraphAPI.FastFetchProjectPageBaseQuery.self,
          GraphAPI.FastFetchProjectPageBaseQuery.Data.template
        )
        // Intentionally missing the second mock to trigger an error
      ]
    )

    let fetcher = ProjectPageFetcher(withService: mockService)
    let producer = fetcher.fastFetchProjectPage(projectParam: .id(0), includeStoryRichText: false)

    XCTAssertEqual(producer.allValues().count, 0)
    guard let errorResult = producer.collect().last(),
          case let .failure(errorEnvelope) = errorResult else {
      XCTFail("Expected error")
      return
    }

    XCTAssertEqual(errorEnvelope.errorMessages, ["Unimplemented mock"])
  }

  func test_newProjectFetch_returnsErrorIfBaseParsingFails() {
    let mockService = MockService(
      fetchGraphQLResponses: [
        (
          GraphAPI.FastFetchProjectPageBaseQuery.self,
          // Data that won't parse
          GraphAPI.FastFetchProjectPageBaseQuery.Data.failed
        ),
        (
          GraphAPI.FastFetchProjectPageExtendedPropertiesQuery.self,
          GraphAPI.FastFetchProjectPageExtendedPropertiesQuery.Data.template
        )
      ]
    )

    let fetcher = ProjectPageFetcher(withService: mockService)
    let producer = fetcher.fastFetchProjectPage(projectParam: .id(0), includeStoryRichText: false)

    XCTAssertEqual(producer.allValues().count, 0)
    guard let errorResult = producer.collect().last(),
          case let .failure(errorEnvelope) = errorResult else {
      XCTFail("Expected error")
      return
    }

    XCTAssertEqual(errorEnvelope.ksrCode, .JSONParsingFailed)
  }

  func test_newProjectFetch_returnsErrorIfExtendedParsingFails() {
    let mockService = MockService(
      fetchGraphQLResponses: [
        (
          GraphAPI.FastFetchProjectPageBaseQuery.self,
          GraphAPI.FastFetchProjectPageBaseQuery.Data.template
        ),
        (
          GraphAPI.FastFetchProjectPageExtendedPropertiesQuery.self,
          // Data that won't parse
          GraphAPI.FastFetchProjectPageExtendedPropertiesQuery.Data.failed
        )
      ]
    )

    let fetcher = ProjectPageFetcher(withService: mockService)
    let producer = fetcher.fastFetchProjectPage(projectParam: .id(0), includeStoryRichText: false)

    XCTAssertEqual(producer.allValues().count, 0)
    guard let errorResult = producer.collect().last(),
          case let .failure(errorEnvelope) = errorResult else {
      XCTFail("Expected error")
      return
    }

    XCTAssertEqual(errorEnvelope.ksrCode, .JSONParsingFailed)
  }
}

private extension GraphAPI.FastFetchProjectPageExtendedPropertiesQuery.Data {
  static var template: GraphAPI.FastFetchProjectPageExtendedPropertiesQuery.Data {
    let mockExtraProperties = Mock<GraphAPITestMocks.Project>()
    mockExtraProperties.risks = "This project has risks."
    mockExtraProperties.story = "Project story"
    mockExtraProperties.minPledge = 27
    mockExtraProperties.flagging = Mock<GraphAPITestMocks.Flagging>()
    mockExtraProperties.flagging?.id = "fake_id"
    mockExtraProperties.flagging?.kind = .some(.case(.charity))
    mockExtraProperties.video = Mock<GraphAPITestMocks.Video>()
    mockExtraProperties.video?.id = "VmlkZW8tMQ=="
    mockExtraProperties.video?.videoSources = Mock<GraphAPITestMocks.VideoSources>()
    mockExtraProperties.video?.videoSources?.high = Mock<GraphAPITestMocks.VideoSourceInfo>()
    mockExtraProperties.video?.videoSources?.high?.src = "high.mp4"

    let header = Mock<GraphAPITestMocks.RichTextHeader>()
    header.text = "Hello, world"
    mockExtraProperties.storyRichText = Mock<GraphAPITestMocks.RichTextComponent>()
    mockExtraProperties.storyRichText?.items = [
      header
    ]
    mockExtraProperties.isLaunched = true
    mockExtraProperties.prelaunchStoryRichText = Mock<GraphAPITestMocks.RichTextComponent>()
    mockExtraProperties.prelaunchStoryRichText?.items = [
      header
    ]

    return GraphAPI.FastFetchProjectPageExtendedPropertiesQuery.Data(
      project: FastFetchProjectPageExtendedPropertiesQuery.Data.Project.from(mockExtraProperties)
    )
  }

  static var failed: GraphAPI.FastFetchProjectPageExtendedPropertiesQuery.Data {
    return GraphAPI.FastFetchProjectPageExtendedPropertiesQuery.Data(
      project: nil
    )
  }
}

private extension GraphAPI.FastFetchProjectPageBaseQuery.Data {
  static var template: GraphAPI.FastFetchProjectPageBaseQuery.Data {
    let mockProject = GraphAPITestMocks.Project.mock
    mockProject.posts = Mock<GraphAPITestMocks.PostConnection>()
    mockProject.posts?.totalCount = 2

    let mockBacking = GraphAPITestMocks.Backing.mock
    mockProject.backing = mockBacking

    let mockReward = GraphAPITestMocks.Reward.mock
    mockProject.rewards = Mock<GraphAPITestMocks.ProjectRewardConnection>()
    mockProject.rewards?.nodes = [mockReward]

    return GraphAPI.FastFetchProjectPageBaseQuery.Data(
      project: FastFetchProjectPageBaseQuery.Data.Project.from(mockProject)
    )
  }

  static var failed: GraphAPI.FastFetchProjectPageBaseQuery.Data {
    return GraphAPI.FastFetchProjectPageBaseQuery.Data(
      project: nil
    )
  }
}
