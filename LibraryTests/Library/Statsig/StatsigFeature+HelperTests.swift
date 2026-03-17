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

  func testVideoFeed_isFalse_whenStatsigFeatureOff() {
    self.assert(
      featureFlagIsFalse: { featureVideoFeedEnabled() },
      whenStatsigFeatureIsFalse: .videoFeed
    )
  }

  func testVideoFeed_isTrue_whenStatsigFeatureOn() {
    self.assert(
      featureFlagIsTrue: { featureVideoFeedEnabled() },
      whenStatsigFeatureIsTrue: .videoFeed
    )
  }
}
