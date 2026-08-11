import ApolloTestSupport
import GraphAPI
import GraphAPITestMocks
@testable import KsApi
import KsApiTestHelpers
import XCTest

public final class ProjectPageFetcherTests: XCTestCase {
  func test_oldProjectFetch_fetchesProjectBackingAndRewards() {
    let projectResponseURL = Bundle.module.url(
      forResource: "FetchProjectByParamQuery_Backing",
      withExtension: "json"
    )!

    let backingResponseURL = Bundle.module.url(
      forResource: "FetchBackingQuery",
      withExtension: "json"
    )!

    let rewardsResponseURL = Bundle.module.url(
      forResource: "FetchProjectRewardsByIdQuery",
      withExtension: "json"
    )!

    let fetchProjectResponse: GraphAPI.FetchProjectByParamQuery
      .Data = try! testGraphObject(fromResource: projectResponseURL)
    let fetchBackingResponse: GraphAPI.FetchBackingQuery
      .Data = try! testGraphObject(fromResource: backingResponseURL)
    let fetchRewardsResponse: GraphAPI.FetchProjectRewardsByIdQuery
      .Data = try! testGraphObject(
        fromResource: rewardsResponseURL,
        variables: ["includeShippingRules": true, "includeLocalPickup": true]
      )

    // This mimicks what Service does internally to map the GraphAPI objects to V1 model objects.
    // MockService requires V1 objects, so this is a best effort
    // to duplicate the actual GraphQL mapping behavior.
    let projectResult = Project.projectProducer(from: fetchProjectResponse).first()
    let backingResult = ProjectAndBackingEnvelope.envelopeProducer(from: fetchBackingResponse).first()
    let rewardsResult = Project.projectRewardsProducer(from: fetchRewardsResponse).first()

    let mockService = MockService(
      fetchProjectAndBackingResult: backingResult,
      fetchProjectPamphletResult: projectResult,
      fetchProjectRewardsResult: rewardsResult
    )

    let fetcher = ProjectPageFetcher(withService: mockService)

    let producer = fetcher.fetchProjectPage(projectParam: .id(0))
    let project = producer.allValues().first

    XCTAssertNotNil(project)
    XCTAssertEqual(project?.personalization.isBacking, true)
    XCTAssertNotNil(project?.personalization.backing)
    XCTAssertEqual(project?.personalization.backing?.amount, 111.0)
    XCTAssertEqual(project?.stats.userCurrency, "EUR")
    XCTAssertEqual(project?.rewardsCount, 4)
    XCTAssertEqual(project?.rewards.count, 5)
    XCTAssertEqual(project?.rewards.first, Reward.noReward)
    XCTAssertNotNil(project?.rewards[1].shippingRulesExpanded)
    XCTAssertEqual(project?.rewards[1].shippingRulesExpanded?.count, 246)
    XCTAssertEqual(project?.rewards[2].shippingRulesExpanded?.count, 1)

    // These properties are only fetched by FetchProjectByParamQuery, but should be passed through.
    XCTAssertEqual(project?.extendedProjectProperties?.aiDisclosure?.involvesAi, false)
    XCTAssertEqual(project?.extendedProjectProperties?.risks, "May not deliver")
    XCTAssertEqual(project?.video?.id, 1_267_784)
    XCTAssertEqual(project?.flagging, true)
  }

  func test_oldProjectFetch_fetchesProjectAndRewards() {
    let projectResponseURL = Bundle.module.url(
      forResource: "FetchProjectByParamQuery_NoBacking",
      withExtension: "json"
    )!

    let rewardsResponseURL = Bundle.module.url(
      forResource: "FetchProjectRewardsByIdQuery",
      withExtension: "json"
    )!

    let fetchProjectResponse: GraphAPI.FetchProjectByParamQuery
      .Data = try! testGraphObject(fromResource: projectResponseURL)
    let fetchRewardsResponse: GraphAPI.FetchProjectRewardsByIdQuery
      .Data = try! testGraphObject(
        fromResource: rewardsResponseURL,
        variables: ["includeShippingRules": true, "includeLocalPickup": true]
      )

    // This mimicks what Service does internally to map the GraphAPI objects to V1 model objects.
    // MockService requires V1 objects, so this is a best effort
    // to duplicate the actual GraphQL mapping behavior.
    let projectResult = Project.projectProducer(from: fetchProjectResponse).first()
    let rewardsResult = Project.projectRewardsProducer(from: fetchRewardsResponse).first()

    let mockService = MockService(
      fetchProjectPamphletResult: projectResult,
      fetchProjectRewardsResult: rewardsResult
    )

    let fetcher = ProjectPageFetcher(withService: mockService)

    let producer = fetcher.fetchProjectPage(projectParam: .id(0))
    let project = producer.allValues().first

    XCTAssertNotNil(project)
    XCTAssertEqual(project?.personalization.isBacking, false)
    XCTAssertNil(project?.personalization.backing)
    XCTAssertEqual(project?.stats.userCurrency, "EUR")
    XCTAssertEqual(project?.rewardsCount, 4)
    XCTAssertEqual(project?.rewards.count, 5)
    XCTAssertEqual(project?.rewards.first, Reward.noReward)
    XCTAssertNotNil(project?.rewards[1].shippingRulesExpanded)
    XCTAssertEqual(project?.rewards[1].shippingRulesExpanded?.count, 246)
    XCTAssertEqual(project?.rewards[2].shippingRulesExpanded?.count, 1)

    // These properties are only fetched by FetchProjectByParamQuery, but should be passed through to the final project result.
    XCTAssertEqual(project?.extendedProjectProperties?.aiDisclosure?.involvesAi, false)
    XCTAssertEqual(project?.extendedProjectProperties?.risks, "May not deliver")
    XCTAssertEqual(project?.video?.id, 1_267_784)
    XCTAssertEqual(project?.flagging, true)
  }

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

    let producer = fetcher.fastFetchProjectPage(projectParam: .id(0))
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
    XCTAssertEqual(project.extendedProjectProperties?.story.richText?.items.count, 1)
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
    let producer = fetcher.fastFetchProjectPage(projectParam: .id(0))

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
    let producer = fetcher.fastFetchProjectPage(projectParam: .id(0))

    XCTAssertEqual(producer.allValues().count, 0)
    guard let errorResult = producer.collect().last(),
          case let .failure(errorEnvelope) = errorResult else {
      XCTFail("Expected error")
      return
    }

    XCTAssertEqual(errorEnvelope.errorMessages, ["Unimplemented mock"])
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

    return GraphAPI.FastFetchProjectPageExtendedPropertiesQuery.Data(
      project: FastFetchProjectPageExtendedPropertiesQuery.Data.Project.from(mockExtraProperties)
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
}
