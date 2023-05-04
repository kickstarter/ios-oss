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

  func testFacebookDeprecation_RemoteConfig_FeatureFlag_False() {
    let mockRemoteConfigClient = MockRemoteConfigClient()
      |> \.features .~ [RemoteConfigFeature.facebookLoginInterstitialEnabled.rawValue: false]

    withEnvironment(remoteConfigClient: mockRemoteConfigClient) {
      XCTAssertFalse(featureFacebookLoginInterstitialEnabled())
    }
  }
}
