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

  /** FIXME: RemoteConfigValue is not initializing because its' OBJC intiliazer is not available
   //  func testReloadWithData_AllFeaturesEnabled() {
   //    let mockRemoteConfigClient = MockRemoteConfigClient()
   //      |> \.features .~ [
   //        RemoteConfigFeature.consentManagementDialogEnabled.rawValue: true,
   //        RemoteConfigFeature.facebookLoginInterstitialEnabled.rawValue: true
   //      ]
   //
   //    withEnvironment(remoteConfigClient: mockRemoteConfigClient) {
   //      self.vm.inputs.viewDidLoad()
   //
   //      self.reloadWithData.values.forEach { featureTuples in
   //        featureTuples.forEach { feature, isEnabled in
   //          let isEnabledOnClient = mockRemoteConfigClient.features[feature.rawValue]
   //
   //          XCTAssertEqual(isEnabled, isEnabledOnClient)
   //        }
   //      }
   //    }
   //  }
   //
   //  func testReloadWithData_FeaturesEnabledAndDisabled() {
   //    let mockRemoteConfigClient = MockRemoteConfigClient()
   //      |> \.features .~ [
   //        RemoteConfigFeature.consentManagementDialogEnabled.rawValue: true,
   //        RemoteConfigFeature.facebookLoginInterstitialEnabled.rawValue: false
   //      ]
   //
   //    withEnvironment(remoteConfigClient: mockRemoteConfigClient) {
   //      self.vm.inputs.viewDidLoad()
   //
   //      self.reloadWithData.values.forEach { featureTuples in
   //        featureTuples.forEach { feature, isEnabled in
   //          let isEnabledOnClient = mockRemoteConfigClient.features[feature.rawValue]
   //
   //          XCTAssertEqual(isEnabled, isEnabledOnClient)
   //        }
   //      }
   //    }
   //  }
   */

  func testUpdateUserDefaultsWithFeatures_FeaturesAreEnabled() {
    let mockRemoteConfigClient = MockRemoteConfigClient()
      |> \.features .~ [
        RemoteConfigFeature.consentManagementDialogEnabled.rawValue: false
      ]

    withEnvironment(remoteConfigClient: mockRemoteConfigClient) {
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.vm.inputs.setFeatureAtIndexEnabled(index: 0, isEnabled: true)

      self.scheduler.advance()

      let (_, isEnabled0) = self.updateUserDefaultsWithFeatures.values[0][0]

      XCTAssertTrue(isEnabled0)
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

    /// The value from the optimizely client is never mutated
    self.reloadWithData.values[0].forEach { _, isEnabled in
      XCTAssertFalse(isEnabled)
    }
  }
}
