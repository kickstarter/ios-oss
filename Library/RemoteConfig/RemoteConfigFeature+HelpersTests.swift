@testable import Library
import Prelude
import XCTest

final class RemoteConfigFeatureHelpersTests: TestCase {
  func testConsentManagementDialog_RemoteConfig_FeatureFlag_False() {
    let mockRemoteConfigClient = MockRemoteConfigClient()
      |> \.features .~ [RemoteConfigFeature.consentManagementDialogEnabled.rawValue: false]

    withEnvironment(remoteConfigClient: mockRemoteConfigClient) {
      XCTAssertFalse(featureConsentManagementDialogEnabled())
    }
  }

  /** FIXME: RemoteConfigValue is not initializing because its' OBJC intiliazer is not available
   func testConsentManagementDialog_RemoteConfig_FeatureFlag_True() {
     let mockRemoteConfigClient = MockRemoteConfigClient()
       |> \.features .~ [RemoteConfigFeature.consentManagementDialogEnabled.rawValue: true]

     withEnvironment(remoteConfigClient: mockRemoteConfigClient) {
       XCTAssertTrue(featureConsentManagementDialogEnabled())
     }
   }

   func testFacebookDeprecation_RemoteConfig_FeatureFlag_True() {
     let mockRemoteConfigClient = MockRemoteConfigClient()
       |> \.features .~ [RemoteConfigFeature.facebookLoginInterstitialEnabled.rawValue: true]

     withEnvironment(remoteConfigClient: mockRemoteConfigClient) {
       XCTAssertTrue(featureFacebookLoginInterstitialEnabled())
     }
   }
   */

  func testFacebookDeprecation_RemoteConfig_FeatureFlag_False() {
    let mockRemoteConfigClient = MockRemoteConfigClient()
      |> \.features .~ [RemoteConfigFeature.facebookLoginInterstitialEnabled.rawValue: false]

    withEnvironment(remoteConfigClient: mockRemoteConfigClient) {
      XCTAssertFalse(featureFacebookLoginInterstitialEnabled())
    }
  }

  func testCreatorDashboardHidden_RemoteConfig_FeatureFlag_False() {
    let mockRemoteConfigClient = MockRemoteConfigClient()
      |> \.features .~ [RemoteConfigFeature.creatorDashboardHiddenEnabled.rawValue: false]

    withEnvironment(remoteConfigClient: mockRemoteConfigClient) {
      XCTAssertFalse(featureCreatorDashboardHiddenEnabled())
    }
  }
}
