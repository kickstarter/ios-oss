import Foundation
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class OptimizelyFlagToolsViewModelTests: TestCase {
  private let vm: OptimizelyFeatureFlagToolsViewModelType = OptimizelyFeatureFlagToolsViewModel()

  private let reloadWithData = TestObserver<OptimizelyFeatures, Never>()
  private let updateUserDefaultsWithFeatures = TestObserver<OptimizelyFeatures, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.reloadWithData.observe(self.reloadWithData.observer)
    self.vm.outputs.updateUserDefaultsWithFeatures.observe(self.updateUserDefaultsWithFeatures.observer)
  }

  func testReloadWithData_AllFeaturesEnabled() {
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.features .~ [
        OptimizelyFeature.commentFlaggingEnabled.rawValue: true,
        OptimizelyFeature.projectPageStoryTabEnabled.rawValue: true,
        OptimizelyFeature.rewardLocalPickupEnabled.rawValue: true,
        OptimizelyFeature.paymentSheetEnabled.rawValue: true,
        OptimizelyFeature.settingsPaymentSheetEnabled.rawValue: true,
        OptimizelyFeature.facebookLoginDeprecationEnabled.rawValue: true
      ]

    withEnvironment(optimizelyClient: mockOptimizelyClient) {
      self.vm.inputs.viewDidLoad()

      self.reloadWithData.values.forEach { featureTuples in
        featureTuples.forEach { feature, isEnabled in
          let isEnabledOnClient = mockOptimizelyClient.features[feature.rawValue]

          XCTAssertEqual(isEnabled, isEnabledOnClient)
        }
      }
    }
  }

  func testReloadWithData_FeaturesEnabledAndDisabled() {
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.features .~ [
        OptimizelyFeature.commentFlaggingEnabled.rawValue: false,
        OptimizelyFeature.projectPageStoryTabEnabled.rawValue: false,
        OptimizelyFeature.rewardLocalPickupEnabled.rawValue: false,
        OptimizelyFeature.paymentSheetEnabled.rawValue: false,
        OptimizelyFeature.settingsPaymentSheetEnabled.rawValue: false,
        OptimizelyFeature.facebookLoginDeprecationEnabled.rawValue: false
      ]

    withEnvironment(optimizelyClient: mockOptimizelyClient) {
      self.vm.inputs.viewDidLoad()

      self.reloadWithData.values.forEach { featureTuples in
        featureTuples.forEach { feature, isEnabled in
          let isEnabledOnClient = mockOptimizelyClient.features[feature.rawValue]

          XCTAssertEqual(isEnabled, isEnabledOnClient)
        }
      }
    }
  }

  func testUpdateUserDefaultsWithFeatures_FeaturesAreEnabled() {
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.features .~ [
        OptimizelyFeature.commentFlaggingEnabled.rawValue: false
      ]

    withEnvironment(optimizelyClient: mockOptimizelyClient) {
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.vm.inputs.setFeatureAtIndexEnabled(index: 0, isEnabled: true)

      self.scheduler.advance()

      let (_, isEnabled0) = self.updateUserDefaultsWithFeatures.values[0][0]

      XCTAssertTrue(isEnabled0)
    }
  }

  func testUpdateUserDefaultsWithFeatures_ReloadWithData_UserDefaultsIsUpdated() {
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.features .~ [
        OptimizelyFeature.commentFlaggingEnabled.rawValue: false
      ]

    withEnvironment(optimizelyClient: mockOptimizelyClient, userDefaults: userDefaults) {
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.vm.inputs.setFeatureAtIndexEnabled(index: 0, isEnabled: true)

      self.scheduler.advance()

      self.vm.inputs.didUpdateUserDefaults()

      self.scheduler.advance()

      XCTAssertEqual(
        userDefaults
          .dictionary(forKey: "com.kickstarter.KeyValueStoreType.optimizelyFeatureFlags") as? [String: Bool],
        [
          OptimizelyFeature.commentFlaggingEnabled.rawValue: true
        ]
      )
    }

    /// The value from the optimizely client is never mutated
    self.reloadWithData.values[0].forEach { _, isEnabled in
      XCTAssertFalse(isEnabled)
    }
  }
}
