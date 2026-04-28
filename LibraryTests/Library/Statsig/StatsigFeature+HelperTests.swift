import Experimentation
@testable import Library
@testable import LibraryTestHelpers
import XCTest

final class StatsigFeatureHelpersTests: TestCase {
  func testFeatureIsFalse_whenStatsigFeatureOff() {
    let mockStatsigClient = MockStatsigClient()
    mockStatsigClient.features[.videoFeed] = false

    withEnvironment(statsigClient: mockStatsigClient) {
      XCTAssertFalse(featureVideoFeedEnabled())
    }
  }

  func testFeatureIsTrue_whenStatsigFeatureOn() {
    let mockStatsigClient = MockStatsigClient()
    mockStatsigClient.features[.videoFeed] = true

    withEnvironment(statsigClient: mockStatsigClient) {
      XCTAssertTrue(featureVideoFeedEnabled())
    }
  }
}
