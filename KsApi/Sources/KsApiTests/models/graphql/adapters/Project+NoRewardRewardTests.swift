import GraphAPI
import KsApi
import XCTest

final class Project_NoRewardRewardTests: XCTestCase {
  func test_noFxRate_returnsMinimumPledge() {
    let fragment = GraphAPI.NoRewardRewardFragment(minPledge: 1, fxRate: 1.0)
    let reward = Reward.noRewardReward(from: fragment)

    XCTAssertTrue(reward.isNoReward)
    XCTAssertTrue(reward.hasNoShippingPreference)

    XCTAssertEqual(reward.minimum, 1.0)
    XCTAssertEqual(reward.convertedMinimum, 1.0)
  }

  func test_fxRate_returnsConvertedMinimum() {
    let fragment = GraphAPI.NoRewardRewardFragment(minPledge: 5, fxRate: 1.493454)
    let reward = Reward.noRewardReward(from: fragment)

    XCTAssertTrue(reward.isNoReward)
    XCTAssertTrue(reward.hasNoShippingPreference)

    XCTAssertEqual(reward.minimum, 5.0)
    XCTAssertEqual(reward.convertedMinimum, 7.46727)
  }
}
