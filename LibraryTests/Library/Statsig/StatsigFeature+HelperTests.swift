@testable import Library
@testable import LibraryTestHelpers
import XCTest

final class StatsigFeatureHelpersTests: TestCase {
  func assert(
    featureFlagIsFalse checkFeatureFlag: () -> Bool,
    whenStatsigFeatureIsFalse feature: StatsigFeature
  ) {
    let mockStatsigClient = MockStatsigClient()
    mockStatsigClient.features[feature.rawValue] = false

    withEnvironment(statsigClient: mockStatsigClient) {
      XCTAssertFalse(checkFeatureFlag())
    }
  }

  func assert(
    featureFlagIsTrue checkFeatureFlag: () -> Bool,
    whenStatsigFeatureIsTrue feature: StatsigFeature
  ) {
    let mockStatsigClient = MockStatsigClient()
    mockStatsigClient.features[feature.rawValue] = true

    withEnvironment(statsigClient: mockStatsigClient) {
      XCTAssertTrue(checkFeatureFlag())
    }
  }
}
