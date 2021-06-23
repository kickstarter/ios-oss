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
        OptimizelyFeature.commentThreading.rawValue: true,
        OptimizelyFeature.commentThreadingRepliesEnabled.rawValue: true
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
        OptimizelyFeature.commentThreading.rawValue: true,
        OptimizelyFeature.commentThreadingRepliesEnabled.rawValue: false
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
        OptimizelyFeature.commentFlaggingEnabled.rawValue: false,
        OptimizelyFeature.commentThreading.rawValue: false,
        OptimizelyFeature.commentThreadingRepliesEnabled.rawValue: false
      ]

    withEnvironment(optimizelyClient: mockOptimizelyClient) {
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.vm.inputs.setFeatureAtIndexEnabled(index: 0, isEnabled: true)

      self.scheduler.advance()

      let (_, isEnabled0) = self.updateUserDefaultsWithFeatures.values[0][0]
      let (_, isEnabled1) = self.updateUserDefaultsWithFeatures.values[0][1]
      let (_, isEnabled2) = self.updateUserDefaultsWithFeatures.values[0][2]

      XCTAssertTrue(isEnabled0)
      XCTAssertFalse(isEnabled1)
      XCTAssertFalse(isEnabled2)
    }
  }

  func testUpdateUserDefaultsWithFeatures_ReloadWithData_UserDefaultsIsUpdated() {
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.features .~ [
        OptimizelyFeature.commentFlaggingEnabled.rawValue: false,
        OptimizelyFeature.commentThreading.rawValue: false,
        OptimizelyFeature.commentThreadingRepliesEnabled.rawValue: false
      ]

    withEnvironment(optimizelyClient: mockOptimizelyClient, userDefaults: userDefaults) {
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.vm.inputs.setFeatureAtIndexEnabled(index: 0, isEnabled: true)
      self.vm.inputs.setFeatureAtIndexEnabled(index: 1, isEnabled: true)
      self.vm.inputs.setFeatureAtIndexEnabled(index: 2, isEnabled: true)

      self.scheduler.advance()

      self.vm.inputs.didUpdateUserDefaults()

      self.scheduler.advance()

      XCTAssertEqual(
        userDefaults
          .dictionary(forKey: "com.kickstarter.KeyValueStoreType.optimizelyFeatureFlags") as? [String: Bool],
        [
          OptimizelyFeature.commentFlaggingEnabled.rawValue: true,
          OptimizelyFeature.commentThreading.rawValue: true,
          OptimizelyFeature.commentThreadingRepliesEnabled.rawValue: true
        ]
      )
    }

    /// The value from the optimizely client is never mutated
    self.reloadWithData.values[0].forEach { _, isEnabled in
      XCTAssertFalse(isEnabled)
    }
  }
}
