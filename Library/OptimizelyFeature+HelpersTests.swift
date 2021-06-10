@testable import KsApi
@testable import Library
import Prelude
import XCTest

final class OptimizelyFeatureHelpersTests: TestCase {
  func testCommentsThreading_Optimizely_FeatureFlag_True() {
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.features .~ [OptimizelyFeature.Key.commentThreading.rawValue: true]

    withEnvironment(optimizelyClient: mockOptimizelyClient) {
      XCTAssertTrue(featureCommentThreadingIsEnabled())
    }
  }

  func testCommentsThreading_Optimizely_FeatureFlag_False() {
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.features .~ [OptimizelyFeature.Key.commentThreading.rawValue: true]

    withEnvironment(optimizelyClient: mockOptimizelyClient) {
      XCTAssertFalse(featureCommentThreadingIsEnabled())
    }
  }
}
