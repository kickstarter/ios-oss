/// Return remote config values either a value from the cloud, if it found one, or a default value based on the provided key
private func featureEnabled(feature: RemoteConfigFeature, defaultValue: Bool = false) -> Bool {
  if let valueFromDefaults = AppEnvironment.current.userDefaults
    .remoteConfigFeatureFlags[feature.rawValue] {
    return valueFromDefaults
  }

  if let valueFromRemoteConfig = AppEnvironment.current.remoteConfigClient?
    .isFeatureEnabled(featureKey: feature) {
    return valueFromRemoteConfig
  }

  return defaultValue
}

public func featureBlockUsersEnabled() -> Bool {
  return featureEnabled(feature: .blockUsersEnabled)
}

public func featureConsentManagementDialogEnabled() -> Bool {
  return featureEnabled(feature: .consentManagementDialogEnabled)
}

public func featureDarkModeEnabled() -> Bool {
  return featureEnabled(feature: .darkModeEnabled)
}

public func featureFacebookLoginInterstitialEnabled() -> Bool {
  return featureEnabled(feature: .facebookLoginInterstitialEnabled)
}

public func featurePostCampaignPledgeEnabled() -> Bool {
  featureEnabled(feature: .postCampaignPledgeEnabled)
}

public func featureReportThisProjectEnabled() -> Bool {
  featureEnabled(feature: .reportThisProjectEnabled)
}

public func featureLoginWithOAuthEnabled() -> Bool {
  featureEnabled(feature: .loginWithOAuthEnabled, defaultValue: true)
}

public func featureUseKeychainForOAuthTokenEnabled() -> Bool {
  featureEnabled(feature: .useKeychainForOAuthToken)
}
