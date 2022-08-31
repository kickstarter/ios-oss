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

  func testRewardLocalPickupEnabled_Optimizely_FeatureFlag_True() {
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.features .~ [OptimizelyFeature.rewardLocalPickupEnabled.rawValue: true]

    withEnvironment(optimizelyClient: mockOptimizelyClient) {
      XCTAssertTrue(featureRewardLocalPickupEnabled())
    }
  }

  func testRewardLocalPickupEnabled_Optimizely_FeatureFlag_False() {
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.features .~ [OptimizelyFeature.rewardLocalPickupEnabled.rawValue: false]

    withEnvironment(optimizelyClient: mockOptimizelyClient) {
      XCTAssertFalse(featureRewardLocalPickupEnabled())
    }
  }

  func testPaymentSheet_Optimizely_FeatureFlag_True() {
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.features .~ [OptimizelyFeature.paymentSheetEnabled.rawValue: true]

    withEnvironment(optimizelyClient: mockOptimizelyClient) {
      XCTAssertTrue(featurePaymentSheetEnabled())
    }
  }

  func testPaymentSheet_Optimizely_FeatureFlag_False() {
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.features .~ [OptimizelyFeature.paymentSheetEnabled.rawValue: false]

    withEnvironment(optimizelyClient: mockOptimizelyClient) {
      XCTAssertFalse(featurePaymentSheetEnabled())
    }
  }

  func testSettingsPaymentSheet_Optimizely_FeatureFlag_False() {
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.features .~ [OptimizelyFeature.settingsPaymentSheetEnabled.rawValue: false]

    withEnvironment(optimizelyClient: mockOptimizelyClient) {
      XCTAssertFalse(featureSettingsPaymentSheetEnabled())
    }
  }

  func testFacebookDeprecation_Optimizely_FeatureFlag_False() {
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.features .~ [OptimizelyFeature.facebookLoginDeprecationEnabled.rawValue: false]

    withEnvironment(optimizelyClient: mockOptimizelyClient) {
      XCTAssertFalse(featureFacebookLoginDeprecationEnabled())
    }
  }
}
