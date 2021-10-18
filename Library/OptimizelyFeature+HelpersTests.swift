@testable import Library
import Prelude
import XCTest

final class OptimizelyFeatureHelpersTests: TestCase {
  func testCommentFlaggingEnabled_Optimizely_FeatureFlag_True() {
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.features .~ [OptimizelyFeature.commentFlaggingEnabled.rawValue: true]

    withEnvironment(optimizelyClient: mockOptimizelyClient) {
      XCTAssertTrue(featureCommentFlaggingIsEnabled())
    }
  }

  func testCommentFlaggingEnabled_Optimizely_FeatureFlag_False() {
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.features .~ [OptimizelyFeature.commentFlaggingEnabled.rawValue: false]

    withEnvironment(optimizelyClient: mockOptimizelyClient) {
      XCTAssertFalse(featureCommentFlaggingIsEnabled())
    }
  }

  func testNavigationSelectorProjectPageEnabled_Optimizely_FeatureFlag_True() {
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.features .~ [OptimizelyFeature.navigationSelectorProjectPageEnabled.rawValue: true]

    withEnvironment(optimizelyClient: mockOptimizelyClient) {
      XCTAssertTrue(featureNavigationSelectorProjectPageIsEnabled())
    }
  }

  func testNavigationSelectorProjectPageEnabled_Optimizely_FeatureFlag_False() {
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.features .~ [OptimizelyFeature.navigationSelectorProjectPageEnabled.rawValue: false]

    withEnvironment(optimizelyClient: mockOptimizelyClient) {
      XCTAssertFalse(featureNavigationSelectorProjectPageIsEnabled())
    }
  }
}
