@testable import Library
import Prelude
import XCTest

final class RemoteConfigFeatureHelpersTests: TestCase {
  func assert(featureFlagIsFalse checkFeatureFlag: () -> Bool,
              whenRemoteConfigFeatureIsFalse feature: RemoteConfigFeature) {
    let mockRemoteConfigClient = MockRemoteConfigClient()
      |> \.features .~ [feature.rawValue: false]

    withEnvironment(remoteConfigClient: mockRemoteConfigClient) {
      XCTAssertFalse(checkFeatureFlag())
    }
  }

  func assert(featureFlagIsTrue checkFeatureFlag: () -> Bool,
              whenRemoteConfigFeatureIsTrue feature: RemoteConfigFeature) {
    let mockRemoteConfigClient = MockRemoteConfigClient()
      |> \.features .~ [feature.rawValue: true]

    withEnvironment(remoteConfigClient: mockRemoteConfigClient) {
      XCTAssertTrue(checkFeatureFlag())
    }
  }

  func testBlockUsers_RemoteConfig_FeatureFlag_False() {
    self
      .assert(
        featureFlagIsFalse: featureBlockUsersEnabled,
        whenRemoteConfigFeatureIsFalse: .blockUsersEnabled
      )
  }

  func testBlockUsers_RemoteConfig_FeatureFlag_True() {
    self
      .assert(
        featureFlagIsTrue: featureBlockUsersEnabled,
        whenRemoteConfigFeatureIsTrue: .blockUsersEnabled
      )
  }

  func testConsentManagementDialog_RemoteConfig_FeatureFlag_False() {
    self
      .assert(
        featureFlagIsFalse: featureConsentManagementDialogEnabled,
        whenRemoteConfigFeatureIsFalse: .consentManagementDialogEnabled
      )
  }

  func testConsentManagementDialog_RemoteConfig_FeatureFlag_True() {
    self
      .assert(
        featureFlagIsTrue: featureConsentManagementDialogEnabled,
        whenRemoteConfigFeatureIsTrue: .consentManagementDialogEnabled
      )
  }

  func testDarkMode_RemoteConfig_FeatureFlag_False() {
    self
      .assert(
        featureFlagIsFalse: featureDarkModeEnabled,
        whenRemoteConfigFeatureIsFalse: .darkModeEnabled
      )
  }

  func testDarkMode_RemoteConfig_FeatureFlag_True() {
    self
      .assert(
        featureFlagIsTrue: featureDarkModeEnabled,
        whenRemoteConfigFeatureIsTrue: .darkModeEnabled
      )
  }

  func testFacebookDeprecation_RemoteConfig_FeatureFlag_True() {
    self
      .assert(
        featureFlagIsTrue: featureFacebookLoginInterstitialEnabled,
        whenRemoteConfigFeatureIsTrue: .facebookLoginInterstitialEnabled
      )
  }

  func testFacebookDeprecation_RemoteConfig_FeatureFlag_False() {
    self
      .assert(
        featureFlagIsFalse: featureFacebookLoginInterstitialEnabled,
        whenRemoteConfigFeatureIsFalse: .facebookLoginInterstitialEnabled
      )
  }

  func testPostCampaignPledge_RemoteConfig_FeatureFlag_True() {
    self
      .assert(
        featureFlagIsTrue: featurePostCampaignPledgeEnabled,
        whenRemoteConfigFeatureIsTrue: .postCampaignPledgeEnabled
      )
  }

  func testPostCampaignPledge_RemoteConfig_FeatureFlag_False() {
    self
      .assert(
        featureFlagIsFalse: featurePostCampaignPledgeEnabled,
        whenRemoteConfigFeatureIsFalse: .postCampaignPledgeEnabled
      )
  }

  func testReportThisProject_RemoteConfig_FeatureFlag_True() {
    self
      .assert(
        featureFlagIsTrue: featureReportThisProjectEnabled,
        whenRemoteConfigFeatureIsTrue: .reportThisProjectEnabled
      )
  }

  func testReportThisProject_RemoteConfig_FeatureFlag_False() {
    self
      .assert(
        featureFlagIsFalse: featureReportThisProjectEnabled,
        whenRemoteConfigFeatureIsFalse: .reportThisProjectEnabled
      )
  }

  func testLoginWithOAuth_RemoteConfig_FeatureFlag_True() {
    self
      .assert(
        featureFlagIsTrue: featureLoginWithOAuthEnabled,
        whenRemoteConfigFeatureIsTrue: .loginWithOAuthEnabled
      )
  }

  func testLoginWithOAuth_RemoteConfig_FeatureFlag_False() {
    self
      .assert(
        featureFlagIsFalse: featureLoginWithOAuthEnabled,
        whenRemoteConfigFeatureIsFalse: .loginWithOAuthEnabled
      )
  }
}
