import ApolloTestSupport
import GraphAPI
import GraphAPITestMocks
@testable import KsApi
import KsApiTestHelpers
import XCTest

public final class ProjectPageFetcherTests: XCTestCase {
  func test_oldProjectFetch_fetchesProjectBackingAndRewards() {
    let projectResponseURL = Bundle.module.url(
      forResource: "FetchProjectByIdQuery",
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

    let fetchProjectResponse: GraphAPI.FetchProjectByIdQuery
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
    let projectResult = Project.projectProducer(from: fetchProjectResponse, configCurrency: nil).first()
    let backingResult = ProjectAndBackingEnvelope.envelopeProducer(from: fetchBackingResponse).first()
    let rewardsResult = Project.projectRewardsProducer(from: fetchRewardsResponse).first()

    let mockService = MockService(
      fetchProjectAndBackingResult: backingResult,
      fetchProjectPamphletResult: projectResult,
      fetchProjectRewardsResult: rewardsResult
    )

    let fetcher = ProjectPageFetcher(withService: mockService)

    let producer = fetcher.fetchProjectPage(projectParam: .id(0), configCurrency: nil)
    let project = producer.allValues().first

    XCTAssertNotNil(project)
    XCTAssertEqual(project?.personalization.isBacking, true)
    XCTAssertNotNil(project?.personalization.backing)
    XCTAssertEqual(project?.personalization.backing?.amount, 111.0)
    XCTAssertEqual(project?.extendedProjectProperties?.aiDisclosure?.involvesAi, false)
    XCTAssertEqual(project?.stats.userCurrency, "EUR")
    XCTAssertEqual(project?.rewardsCount, 4)
    XCTAssertEqual(project?.rewards.count, 4)
    XCTAssertNotNil(project?.rewards.first?.shippingRules)
    XCTAssertNotNil(project?.rewards.first?.shippingRulesExpanded)
    XCTAssertEqual(project?.rewards.first?.shippingRulesExpanded?.count, 246)
    XCTAssertEqual(project?.rewards[1].shippingRulesExpanded?.count, 1)
  }
}
