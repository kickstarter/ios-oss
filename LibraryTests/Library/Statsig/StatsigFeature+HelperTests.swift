@testable import Library
@testable import LibraryTestHelpers
import XCTest

final class StatsigFeatureHelpersTests: TestCase {
  func testFeatureIsFalse_whenStatsigFeatureOff() {
    let mockStatsigClient = MockStatsigClient()
    mockStatsigClient.features[StatsigFeature.videoFeed.rawValue] = false

    withEnvironment(statsigClient: mockStatsigClient) {
      XCTAssertFalse(featureVideoFeedEnabled())
    }
  }

  func testFeatureIsTrue_whenStatsigFeatureOn() {
    let mockStatsigClient = MockStatsigClient()
    mockStatsigClient.features[StatsigFeature.videoFeed.rawValue] = true

    withEnvironment(statsigClient: mockStatsigClient) {
      XCTAssertTrue(featureVideoFeedEnabled())
    }
  }
}
