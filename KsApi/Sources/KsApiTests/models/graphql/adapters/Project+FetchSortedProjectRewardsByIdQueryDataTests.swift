import Apollo
import GraphAPI
@testable import KsApi
@testable import KsApiTestHelpers
import ReactiveSwift
import XCTest

final class Project_FetchSortedProjectRewardsByIdQueryDataTests: XCTestCase {
  func testFetch_parsesRewards_andAddsNoRewardReward() {
    let dataUrl = Bundle.module.url(forResource: "FetchSortedProjectRewardsById", withExtension: "json")!
    let data: GraphAPI.FetchSortedProjectRewardsByIdQuery.Data =
      try! testGraphObject(fromResource: dataUrl, variables: [
        "projectId": 1_480_998_200,
        "location": "DE",
        "includeShippingRules": true,
        "includeLocalPickup": true
      ])
    XCTAssertNotNil(data)

    let rewards = Project.projectRewards(from: data)

    XCTAssertEqual(rewards.count, 2)

    guard let firstReward = rewards.first else {
      XCTFail("Expected there to be two rewards")
      return
    }

    // Unlike the other rewards fetch, this one automatically adds no-reward.
    XCTAssertTrue(firstReward.isNoReward, "Query should have inserted no-reward reward")
    XCTAssertEqual(firstReward.convertedMinimum, 0.780313)

    // The rewards and shipping rules code goes through the same pathway as
    // FetchProjectRewardsByIdQuery, and is largely exercised by those tests.
    let secondReward = rewards[1]
    XCTAssertEqual(secondReward.title, "Germany reward (not featured)")
    XCTAssertEqual(
      secondReward.shippingRulesExpanded?.count,
      1,
      "Should have parsed the expanded shipping rules"
    )
  }
}
