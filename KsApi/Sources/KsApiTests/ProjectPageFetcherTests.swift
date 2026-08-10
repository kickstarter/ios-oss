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
}
