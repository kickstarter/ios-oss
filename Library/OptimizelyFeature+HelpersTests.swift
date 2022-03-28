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

  func testProjectPageStoryEnabled_Optimizely_FeatureFlag_True() {
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.features .~ [OptimizelyFeature.projectPageStoryTabEnabled.rawValue: true]

    withEnvironment(optimizelyClient: mockOptimizelyClient) {
      XCTAssertTrue(featureProjectPageStoryTabEnabled())
    }
  }

  func testProjectPageStoryEnabled_Optimizely_FeatureFlag_False() {
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.features .~ [OptimizelyFeature.projectPageStoryTabEnabled.rawValue: false]

    withEnvironment(optimizelyClient: mockOptimizelyClient) {
      XCTAssertFalse(featureProjectPageStoryTabEnabled())
    }
  }
}
