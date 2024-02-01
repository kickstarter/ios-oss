@testable import Library
import Prelude
import XCTest

final class RemoteConfigFeatureHelpersTests: TestCase {
  func assertFeatureIsFalse(
    whenRemoteConfigFeatureIsFalse feature: RemoteConfigFeature,
    checkFeatureFlag: () -> Bool
  ) {
    let mockRemoteConfigClient = MockRemoteConfigClient()
      |> \.features .~ [feature.rawValue: false]

    withEnvironment(remoteConfigClient: mockRemoteConfigClient) {
      XCTAssertFalse(checkFeatureFlag())
    }
  }

  func assertFeatureIsTrue(
    whenRemoteConfigFeatureIsTrue feature: RemoteConfigFeature,
    checkFeatureFlag: () -> Bool
  ) {
    let mockRemoteConfigClient = MockRemoteConfigClient()
      |> \.features .~ [feature.rawValue: true]

    withEnvironment(remoteConfigClient: mockRemoteConfigClient) {
      XCTAssertTrue(checkFeatureFlag())
    }
  }

  func testBlockUsers_RemoteConfig_FeatureFlag_False() {
    self.assertFeatureIsFalse(whenRemoteConfigFeatureIsFalse: .blockUsersEnabled) {
      featureBlockUsersEnabled()
    }
  }

  func testBlockUsers_RemoteConfig_FeatureFlag_True() {
    self.assertFeatureIsTrue(whenRemoteConfigFeatureIsTrue: .blockUsersEnabled) {
      featureBlockUsersEnabled()
    }
  }

  func testConsentManagementDialog_RemoteConfig_FeatureFlag_False() {
    self
      .assertFeatureIsFalse(
        whenRemoteConfigFeatureIsFalse: .consentManagementDialogEnabled
      ) {
        featureConsentManagementDialogEnabled()
      }
  }

  func testConsentManagementDialog_RemoteConfig_FeatureFlag_True() {
    self
      .assertFeatureIsTrue(
        whenRemoteConfigFeatureIsTrue: .consentManagementDialogEnabled
      ) {
        featureConsentManagementDialogEnabled()
      }
  }

  func testDarkMode_RemoteConfig_FeatureFlag_False() {
    self.assertFeatureIsFalse(whenRemoteConfigFeatureIsFalse: .darkModeEnabled) {
      featureDarkModeEnabled()
    }
  }

  func testDarkMode_RemoteConfig_FeatureFlag_True() {
    self.assertFeatureIsTrue(whenRemoteConfigFeatureIsTrue: .darkModeEnabled) {
      featureDarkModeEnabled()
    }
  }

  func testFacebookDeprecation_RemoteConfig_FeatureFlag_True() {
    self
      .assertFeatureIsTrue(whenRemoteConfigFeatureIsTrue: .facebookLoginInterstitialEnabled
      ) {
        featureFacebookLoginInterstitialEnabled()
      }
  }

  func testFacebookDeprecation_RemoteConfig_FeatureFlag_False() {
    self
      .assertFeatureIsFalse(whenRemoteConfigFeatureIsFalse: .facebookLoginInterstitialEnabled
      ) {
        featureFacebookLoginInterstitialEnabled()
      }
  }

  func testPostCampaignPledge_RemoteConfig_FeatureFlag_True() {
    self
      .assertFeatureIsTrue(whenRemoteConfigFeatureIsTrue: .postCampaignPledgeEnabled
      ) {
        featurePostCampaignPledgeEnabled()
      }
  }

  func testPostCampaignPledge_RemoteConfig_FeatureFlag_False() {
    self
      .assertFeatureIsFalse(
        whenRemoteConfigFeatureIsFalse: .postCampaignPledgeEnabled
      ) {
        featurePostCampaignPledgeEnabled()
      }
  }

  func testReportThisProject_RemoteConfig_FeatureFlag_True() {
    self
      .assertFeatureIsTrue(
        whenRemoteConfigFeatureIsTrue: .reportThisProjectEnabled
      ) { featureReportThisProjectEnabled() }
  }

  func testReportThisProject_RemoteConfig_FeatureFlag_False() {
    self
      .assertFeatureIsFalse(
        whenRemoteConfigFeatureIsFalse: .reportThisProjectEnabled
      ) {
        featureReportThisProjectEnabled()
      }
  }
}
