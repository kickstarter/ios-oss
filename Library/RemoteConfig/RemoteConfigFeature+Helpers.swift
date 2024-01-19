/// Return remote config values either a value from the cloud, if it found one, or a default value based on the provided key

public func featureBlockUsersEnabled() -> Bool {
  return AppEnvironment.current.userDefaults
    .remoteConfigFeatureFlags[RemoteConfigFeature.blockUsersEnabled.rawValue] ??
    (AppEnvironment.current.remoteConfigClient?
      .isFeatureEnabled(featureKey: RemoteConfigFeature.blockUsersEnabled) ?? false)
}

public func featureConsentManagementDialogEnabled() -> Bool {
  return AppEnvironment.current.userDefaults
    .remoteConfigFeatureFlags[RemoteConfigFeature.consentManagementDialogEnabled.rawValue] ??
    (AppEnvironment.current.remoteConfigClient?
      .isFeatureEnabled(featureKey: RemoteConfigFeature.consentManagementDialogEnabled) ?? false)
}

public func featureDarkModeEnabled() -> Bool {
  return AppEnvironment.current.userDefaults
    .remoteConfigFeatureFlags[RemoteConfigFeature.darkModeEnabled.rawValue] ??
    (AppEnvironment.current.remoteConfigClient?
      .isFeatureEnabled(featureKey: RemoteConfigFeature.darkModeEnabled) ?? false)
}

public func featureFacebookLoginInterstitialEnabled() -> Bool {
  return AppEnvironment.current.userDefaults
    .remoteConfigFeatureFlags[RemoteConfigFeature.facebookLoginInterstitialEnabled.rawValue] ??
    (AppEnvironment.current.remoteConfigClient?
      .isFeatureEnabled(featureKey: RemoteConfigFeature.facebookLoginInterstitialEnabled) ?? false)
}

public func featurePostCampaignPledgeEnabled() -> Bool {
  return AppEnvironment.current.userDefaults
    .remoteConfigFeatureFlags[RemoteConfigFeature.postCampaignPledgeEnabled.rawValue] ??
    (AppEnvironment.current.remoteConfigClient?
      .isFeatureEnabled(featureKey: RemoteConfigFeature.postCampaignPledgeEnabled) ?? false)
}

public func featureReportThisProjectEnabled() -> Bool {
  return AppEnvironment.current.userDefaults
    .remoteConfigFeatureFlags[RemoteConfigFeature.reportThisProjectEnabled.rawValue] ??
    (AppEnvironment.current.remoteConfigClient?
      .isFeatureEnabled(featureKey: RemoteConfigFeature.reportThisProjectEnabled) ?? false)
}

public func featureUseOfAIProjectTabEnabled() -> Bool {
  return AppEnvironment.current.userDefaults
    .remoteConfigFeatureFlags[RemoteConfigFeature.useOfAIProjectTab.rawValue] ??
    (AppEnvironment.current.remoteConfigClient?
      .isFeatureEnabled(featureKey: RemoteConfigFeature.useOfAIProjectTab) ?? false)
}
