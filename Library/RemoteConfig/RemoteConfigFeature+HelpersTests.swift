@testable import Library
import Prelude
import XCTest

final class RemoteConfigFeatureHelpersTests: TestCase {
  func assert(
    featureFlagIsFalse checkFeatureFlag: () -> Bool,
    whenRemoteConfigFeatureIsFalse feature: RemoteConfigFeature
  ) {
    let mockRemoteConfigClient = MockRemoteConfigClient()
      |> \.features .~ [feature.rawValue: false]

    withEnvironment(remoteConfigClient: mockRemoteConfigClient) {
      XCTAssertFalse(checkFeatureFlag())
    }
  }

  func assert(
    featureFlagIsTrue checkFeatureFlag: () -> Bool,
    whenRemoteConfigFeatureIsTrue feature: RemoteConfigFeature
  ) {
    let mockRemoteConfigClient = MockRemoteConfigClient()
      |> \.features .~ [feature.rawValue: true]

    withEnvironment(remoteConfigClient: mockRemoteConfigClient) {
      XCTAssertTrue(checkFeatureFlag())
    }
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

  func testLoginWithOAuth_RemoteConfig_FeatureFlag_True() {
    self
      .assert(
        featureFlagIsTrue: featureLoginWithOAuthEnabled,
        whenRemoteConfigFeatureIsTrue: .loginWithOAuthEnabled
      )
  }

  func testUseKeychainForOAuthTokenEnabled_RemoteConfig_FeatureFlag_False() {
    self
      .assert(
        featureFlagIsFalse: featureUseKeychainForOAuthTokenEnabled,
        whenRemoteConfigFeatureIsFalse: .useKeychainForOAuthToken
      )
  }

  func testUseKeychainForOAuthTokenEnabled_RemoteConfig_FeatureFlag_True() {
    self
      .assert(
        featureFlagIsTrue: featureUseKeychainForOAuthTokenEnabled,
        whenRemoteConfigFeatureIsTrue: .useKeychainForOAuthToken
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
