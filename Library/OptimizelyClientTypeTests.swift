@testable import KsApi
@testable import Library
import Prelude
import XCTest

final class OptimizelyClientTypeTests: TestCase {
  func testAllExperiments() {
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.experiments .~
      [
        OptimizelyExperiment.Key.nativeOnboarding.rawValue: OptimizelyExperiment.Variant.variant1.rawValue,
        OptimizelyExperiment.Key.onboardingCategoryPersonalizationFlow.rawValue: OptimizelyExperiment.Variant
          .variant1.rawValue,
        OptimizelyExperiment.Key.nativeProjectCards.rawValue: OptimizelyExperiment.Variant.variant1.rawValue,
        OptimizelyExperiment.Key.nativeRiskMessaging.rawValue: OptimizelyExperiment.Variant.variant1.rawValue
      ]

    XCTAssert(mockOptimizelyClient.experiments.count == 4)
  }

  func testAllFeatures() {
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.features .~ [
        OptimizelyFeature.commentFlaggingEnabled.rawValue: true
      ]

    XCTAssert(mockOptimizelyClient.allFeatures().count == 6)
  }

  func testVariantForExperiment_NoError() {
    let mockClient = MockOptimizelyClient()
      |> \.experiments .~
      [OptimizelyExperiment.Key.nativeProjectCards.rawValue: OptimizelyExperiment.Variant.variant1.rawValue]

    XCTAssertEqual(
      OptimizelyExperiment.Variant.variant1,
      mockClient.variant(for: .nativeProjectCards),
      "Returns the correction variation"
    )
    XCTAssertTrue(mockClient.activatePathCalled)
    XCTAssertFalse(mockClient.getVariantPathCalled)
  }

  func testVariantForExperiment_ThrowsError() {
    let mockClient = MockOptimizelyClient()
      |> \.experiments .~
      [OptimizelyExperiment.Key.nativeProjectCards.rawValue: OptimizelyExperiment.Variant.variant1.rawValue]
      |> \.error .~ MockOptimizelyError.generic

    XCTAssertEqual(
      OptimizelyExperiment.Variant.control,
      mockClient.variant(for: .nativeProjectCards),
      "Returns the control variant if error is thrown"
    )
    XCTAssertTrue(mockClient.activatePathCalled)
    XCTAssertFalse(mockClient.getVariantPathCalled)
  }

  func testVariantForExperiment_ExperimentNotFound() {
    let mockClient = MockOptimizelyClient()

    XCTAssertEqual(
      OptimizelyExperiment.Variant.control,
      mockClient.variant(for: .nativeProjectCards),
      "Returns the control variant if experiment key is not found"
    )
    XCTAssertTrue(mockClient.activatePathCalled)
    XCTAssertFalse(mockClient.getVariantPathCalled)
  }

  func testVariantForExperiment_UnknownVariant() {
    let mockClient = MockOptimizelyClient()
      |> \.experiments .~
      [OptimizelyExperiment.Key.nativeProjectCards.rawValue: "other_variant"]

    XCTAssertEqual(
      OptimizelyExperiment.Variant.control,
      mockClient.variant(for: .nativeProjectCards),
      "Returns the control variant if the variant is not recognized"
    )
    XCTAssertTrue(mockClient.activatePathCalled)
    XCTAssertFalse(mockClient.getVariantPathCalled)
  }

  func testVariantForExperiment_NoError_LoggedIn_IsAdmin() {
    let mockClient = MockOptimizelyClient()
      |> \.experiments .~
      [OptimizelyExperiment.Key.nativeProjectCards.rawValue: OptimizelyExperiment.Variant.variant1.rawValue]

    let user = User.template |> User.lens.isAdmin .~ true

    withEnvironment(currentUser: user) {
      XCTAssertEqual(
        OptimizelyExperiment.Variant.variant1,
        mockClient.variant(for: .nativeProjectCards),
        "Returns the correction variation"
      )
      XCTAssertFalse(mockClient.activatePathCalled)
      XCTAssertTrue(mockClient.getVariantPathCalled)
    }
  }

  func testGetVariation() {
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.experiments .~
      ["fake_experiment": OptimizelyExperiment.Variant.variant1.rawValue]

    withEnvironment(currentUser: User.template, optimizelyClient: mockOptimizelyClient) {
      let variation = mockOptimizelyClient.getVariation(for: "fake_experiment")
      let userAttributes = mockOptimizelyClient.userAttributes

      XCTAssertEqual(.variant1, variation)
      XCTAssertTrue(mockOptimizelyClient.getVariantPathCalled)

      assertUserAttributes(userAttributes)
    }
  }

  func testGetVariation_Error() {
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.experiments .~
      ["fake_experiment": OptimizelyExperiment.Variant.variant1.rawValue]

    withEnvironment(currentUser: User.template, optimizelyClient: mockOptimizelyClient) {
      let variation = mockOptimizelyClient.getVariation(for: "other_experiment")
      let userAttributes = mockOptimizelyClient.userAttributes

      XCTAssertEqual(.control, variation, "Defaults to control when error is thrown")
      XCTAssertTrue(mockOptimizelyClient.getVariantPathCalled)

      assertUserAttributes(userAttributes)
    }
  }

  func testOptimizelyProperties() {
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.experiments .~ [
        "fake_experiment_1":
          OptimizelyExperiment.Variant.control.rawValue,
        "fake_experiment_2":
          OptimizelyExperiment.Variant.variant1.rawValue,
        "fake_experiment_3":
          OptimizelyExperiment.Variant.variant2.rawValue
      ]
      |> \.allKnownExperiments .~ [
        "fake_experiment_1",
        "fake_experiment_2",
        "fake_experiment_3",
        "fake_experiment_4"
      ]
    let mockService = MockService(serverConfig: ServerConfig.staging)

    withEnvironment(apiService: mockService, optimizelyClient: mockOptimizelyClient) {
      let properties = optimizelyProperties()

      XCTAssertEqual("Staging", properties?["optimizely_environment"] as? String)
      XCTAssertEqual(Secrets.OptimizelySDKKey.staging, properties?["optimizely_api_key"] as? String)
    }
  }

  private func assertUserAttributes(_ userAttributes: [String: Any?]?) {
    XCTAssertEqual("us", userAttributes?["user_country"] as? String)
    XCTAssertEqual("en", userAttributes?["user_display_language"] as? String)
    XCTAssertEqual("MockSystemVersion", userAttributes?["session_os_version"] as? String)
    XCTAssertEqual("1.2.3.4.5.6.7.8.9.0", userAttributes?["session_app_release_version"] as? String)
    XCTAssertEqual(true, userAttributes?["session_apple_pay_device"] as? Bool)
    XCTAssertEqual("phone", userAttributes?["session_device_type"] as? String)
    XCTAssertEqual(true, userAttributes?["session_user_is_logged_in"] as? Bool)

    XCTAssertNil(userAttributes?["user_facebook_account"] as? Bool)
    XCTAssertNil(userAttributes?["user_backed_projects_count"] as? Int)
    XCTAssertNil(userAttributes?["user_launched_projects_count"] as? Int)
    XCTAssertNil(userAttributes?["user_distinct_id"] as? String)
    XCTAssertNil(userAttributes?["session_referrer_credit"] as? String)
    XCTAssertNil(userAttributes?["session_ref_tag"] as? String)
  }

  func testIsFeatureEnabled() {
    let mockClient = MockOptimizelyClient()
      |> \.features .~ [
        "my_enabled_feature": true,
        "my_disabled_feature": false
      ]

    XCTAssertTrue(mockClient.isFeatureEnabled(featureKey: "my_enabled_feature", userId: "1", attributes: [:]))
    XCTAssertFalse(
      mockClient.isFeatureEnabled(featureKey: "my_disabled_feature", userId: "1", attributes: [:])
    )
    XCTAssertFalse(
      mockClient.isFeatureEnabled(featureKey: "my_missing_feature", userId: "1", attributes: [:])
    )
  }
}
