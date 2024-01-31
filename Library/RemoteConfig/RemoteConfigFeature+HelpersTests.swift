@testable import Library
import Prelude
import XCTest

final class RemoteConfigFeatureHelpersTests: TestCase {
  func assertFeatureIsFalse(_ featureFlag: Bool,
                            whenRemoteConfigFeatureIsFalse feature: RemoteConfigFeature) {
    let mockRemoteConfigClient = MockRemoteConfigClient()
      |> \.features .~ [feature.rawValue: false]

    withEnvironment(remoteConfigClient: mockRemoteConfigClient) {
      XCTAssertFalse(featureFlag)
    }
  }

  func assertFeatureIsTrue(_ featureFlag: Bool, whenRemoteConfigFeatureIsTrue feature: RemoteConfigFeature) {
    let mockRemoteConfigClient = MockRemoteConfigClient()
      |> \.features .~ [feature.rawValue: true]

    withEnvironment(remoteConfigClient: mockRemoteConfigClient) {
      XCTAssertFalse(featureFlag)
    }
  }

  func testBlockUsers_RemoteConfig_FeatureFlag_False() {
    self.assertFeatureIsFalse(featureBlockUsersEnabled(), whenRemoteConfigFeatureIsFalse: .blockUsersEnabled)
  }

  func testBlockUsers_RemoteConfig_FeatureFlag_True() {
    self.assertFeatureIsTrue(featureBlockUsersEnabled(), whenRemoteConfigFeatureIsTrue: .blockUsersEnabled)
  }

  func testConsentManagementDialog_RemoteConfig_FeatureFlag_False() {
    self
      .assertFeatureIsFalse(
        featureConsentManagementDialogEnabled(),
        whenRemoteConfigFeatureIsFalse: .consentManagementDialogEnabled
      )
  }

  func testConsentManagementDialog_RemoteConfig_FeatureFlag_True() {
    self
      .assertFeatureIsTrue(
        featureConsentManagementDialogEnabled(),
        whenRemoteConfigFeatureIsTrue: .consentManagementDialogEnabled
      )
  }

  func testDarkMode_RemoteConfig_FeatureFlag_False() {
    self.assertFeatureIsFalse(featureDarkModeEnabled(), whenRemoteConfigFeatureIsFalse: .darkModeEnabled)
  }

  func testDarkMode_RemoteConfig_FeatureFlag_True() {
    self.assertFeatureIsTrue(featureDarkModeEnabled(), whenRemoteConfigFeatureIsTrue: .darkModeEnabled)
  }

  func testFacebookDeprecation_RemoteConfig_FeatureFlag_True() {
    self
      .assertFeatureIsTrue(
        featureFacebookLoginInterstitialEnabled(),
        whenRemoteConfigFeatureIsTrue: .facebookLoginInterstitialEnabled
      )
  }

  func testFacebookDeprecation_RemoteConfig_FeatureFlag_False() {
    self
      .assertFeatureIsFalse(
        featureFacebookLoginInterstitialEnabled(),
        whenRemoteConfigFeatureIsFalse: .facebookLoginInterstitialEnabled
      )
  }

  func testPostCampaignPledge_RemoteConfig_FeatureFlag_True() {
    self
      .assertFeatureIsTrue(
        featurePostCampaignPledgeEnabled(),
        whenRemoteConfigFeatureIsTrue: .postCampaignPledgeEnabled
      )
  }

  func testPostCampaignPledge_RemoteConfig_FeatureFlag_False() {
    self
      .assertFeatureIsFalse(
        featurePostCampaignPledgeEnabled(),
        whenRemoteConfigFeatureIsFalse: .postCampaignPledgeEnabled
      )
  }

  func testReportThisProject_RemoteConfig_FeatureFlag_True() {
    self
      .assertFeatureIsTrue(
        featureReportThisProjectEnabled(),
        whenRemoteConfigFeatureIsTrue: .reportThisProjectEnabled
      )
  }

  func testReportThisProject_RemoteConfig_FeatureFlag_False() {
    self
      .assertFeatureIsFalse(
        featureReportThisProjectEnabled(),
        whenRemoteConfigFeatureIsFalse: .reportThisProjectEnabled
      )
  }
}
