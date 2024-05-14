import Foundation
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class RemoteConfigFlagToolsViewModelTests: TestCase {
  private let vm: RemoteConfigFeatureFlagToolsViewModelType = RemoteConfigFeatureFlagToolsViewModel()

  private let reloadWithData = TestObserver<RemoteConfigFeatures, Never>()
  private let updateUserDefaultsWithFeatures = TestObserver<RemoteConfigFeatures, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.reloadWithData.observe(self.reloadWithData.observer)
    self.vm.outputs.updateUserDefaultsWithFeatures.observe(self.updateUserDefaultsWithFeatures.observer)
  }

  func testReloadWithData_AllFeaturesEnabled() {
    let mockRemoteConfigClient = MockRemoteConfigClient()

    for feature in RemoteConfigFeature.allCases {
      mockRemoteConfigClient.features[feature.rawValue] = true
    }

    withEnvironment(remoteConfigClient: mockRemoteConfigClient) {
      self.vm.inputs.viewDidLoad()

      self.reloadWithData.values.forEach { featureTuples in
        featureTuples.forEach { feature, isEnabled in
          let isEnabledOnClient = mockRemoteConfigClient.features[feature.rawValue]

          XCTAssertEqual(isEnabled, isEnabledOnClient)
        }
      }
    }
  }

  func testReloadWithData_FeaturesEnabledAndDisabled() {
    let mockRemoteConfigClient = MockRemoteConfigClient()

    for feature in RemoteConfigFeature.allCases {
      let trueOrFalse = feature.rawValue.hashValue % 2 == 1
      mockRemoteConfigClient.features[feature.rawValue] = trueOrFalse
    }

    withEnvironment(remoteConfigClient: mockRemoteConfigClient) {
      self.vm.inputs.viewDidLoad()

      self.reloadWithData.values.forEach { featureTuples in
        featureTuples.forEach { feature, isEnabled in
          let isEnabledOnClient = mockRemoteConfigClient.features[feature.rawValue]

          XCTAssertEqual(isEnabled, isEnabledOnClient)
        }
      }
    }
  }

  func testUpdateUserDefaultsWithFeature_FeatureIsEnabled() {
    let mockRemoteConfigClient = MockRemoteConfigClient()
      |> \.features .~ [
        RemoteConfigFeature.consentManagementDialogEnabled.rawValue: false
      ]

    withEnvironment(remoteConfigClient: mockRemoteConfigClient) {
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.updateUserDefaultsWithFeatures.assertDidNotEmitValue()

      self.vm.inputs.setFeatureAtIndexEnabled(index: 0, isEnabled: true)

      self.scheduler.advance()

      let (_, isEnabled1) = self.updateUserDefaultsWithFeatures.values[0][0]

      XCTAssertTrue(isEnabled1)
    }
  }

  func testUpdateUserDefaultsWithFeatures_ReloadWithData_UserDefaultsIsUpdated() {
    let mockRemoteConfigClient = MockRemoteConfigClient()
      |> \.features .~ [
        RemoteConfigFeature.consentManagementDialogEnabled.rawValue: false
      ]

    withEnvironment(remoteConfigClient: mockRemoteConfigClient, userDefaults: userDefaults) {
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      XCTAssertEqual(
        userDefaults
          .dictionary(forKey: "com.kickstarter.KeyValueStoreType.remoteConfigFeatureFlags") as? [String: Bool],
        nil
      )

      self.vm.inputs.setFeatureAtIndexEnabled(index: 0, isEnabled: true)

      self.scheduler.advance()

      self.vm.inputs.didUpdateUserDefaults()

      self.scheduler.advance()

      XCTAssertEqual(
        userDefaults
          .dictionary(forKey: "com.kickstarter.KeyValueStoreType.remoteConfigFeatureFlags") as? [String: Bool],
        [
          RemoteConfigFeature.consentManagementDialogEnabled.rawValue: true
        ]
      )
    }

    /// The value from the remote config client is never mutated
    self.reloadWithData.values[0].forEach { _, isEnabled in
      XCTAssertFalse(isEnabled)
    }
  }
}
