@testable import Library
import Prelude
import XCTest

final class RemoteConfigFeatureHelpersTests: TestCase {
  func testBlockUsers_RemoteConfig_FeatureFlag_False() {
    let mockRemoteConfigClient = MockRemoteConfigClient()
      |> \.features .~ [RemoteConfigFeature.blockUsersEnabled.rawValue: false]

    withEnvironment(remoteConfigClient: mockRemoteConfigClient) {
      XCTAssertFalse(featureBlockUsersEnabled())
    }
  }

  func testBlockUsers_RemoteConfig_FeatureFlag_True() {
    let mockRemoteConfigClient = MockRemoteConfigClient()
      |> \.features .~ [RemoteConfigFeature.blockUsersEnabled.rawValue: true]

    withEnvironment(remoteConfigClient: mockRemoteConfigClient) {
      XCTAssertTrue(featureBlockUsersEnabled())
    }
  }
  
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

  func testDarkMode_RemoteConfig_FeatureFlag_False() {
    let mockRemoteConfigClient = MockRemoteConfigClient()
      |> \.features .~ [RemoteConfigFeature.darkModeEnabled.rawValue: false]

    withEnvironment(remoteConfigClient: mockRemoteConfigClient) {
      XCTAssertFalse(featureDarkModeEnabled())
    }
  }

  func testDarkMode_RemoteConfig_FeatureFlag_True() {
    let mockRemoteConfigClient = MockRemoteConfigClient()
      |> \.features .~ [RemoteConfigFeature.darkModeEnabled.rawValue: true]

    withEnvironment(remoteConfigClient: mockRemoteConfigClient) {
      XCTAssertTrue(featureDarkModeEnabled())
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

  func testReportThisProject_RemoteConfig_FeatureFlag_True() {
    let mockRemoteConfigClient = MockRemoteConfigClient()
      |> \.features .~ [RemoteConfigFeature.reportThisProjectEnabled.rawValue: true]

    withEnvironment(remoteConfigClient: mockRemoteConfigClient) {
      XCTAssertTrue(featureReportThisProjectEnabled())
    }
  }

  func testReportThisProject_RemoteConfig_FeatureFlag_False() {
    let mockRemoteConfigClient = MockRemoteConfigClient()
      |> \.features .~ [RemoteConfigFeature.reportThisProjectEnabled.rawValue: false]

    withEnvironment(remoteConfigClient: mockRemoteConfigClient) {
      XCTAssertFalse(featureReportThisProjectEnabled())
    }
  }

  func testUseOfAIProjectTab_RemoteConfig_FeatureFlag_False() {
    let mockRemoteConfigClient = MockRemoteConfigClient()
      |> \.features .~ [RemoteConfigFeature.useOfAIProjectTab.rawValue: false]

    withEnvironment(remoteConfigClient: mockRemoteConfigClient) {
      XCTAssertFalse(featureUseOfAIProjectTabEnabled())
    }
  }

  func testUseOfAIProjectTab_RemoteConfig_FeatureFlag_True() {
    let mockRemoteConfigClient = MockRemoteConfigClient()
      |> \.features .~ [RemoteConfigFeature.useOfAIProjectTab.rawValue: true]

    withEnvironment(remoteConfigClient: mockRemoteConfigClient) {
      XCTAssertTrue(featureUseOfAIProjectTabEnabled())
    }
  }
}
