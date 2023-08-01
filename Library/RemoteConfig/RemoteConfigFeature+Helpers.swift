/// Return remote config values either a value from the cloud, if it found one, or a default value based on the provided key

public func featureConsentManagementDialogEnabled() -> Bool {
  return AppEnvironment.current.userDefaults
    .remoteConfigFeatureFlags[RemoteConfigFeature.consentManagementDialogEnabled.rawValue] ??
    (AppEnvironment.current.remoteConfigClient?
      .isFeatureEnabled(featureKey: RemoteConfigFeature.consentManagementDialogEnabled) ?? false)
}

public func featureCreatorDashboardEnabled() -> Bool {
  return AppEnvironment.current.userDefaults
    .remoteConfigFeatureFlags[RemoteConfigFeature.creatorDashboardEnabled.rawValue] ??
    (AppEnvironment.current.remoteConfigClient?
      .isFeatureEnabled(featureKey: RemoteConfigFeature.creatorDashboardEnabled) ?? false)
}

public func featureFacebookLoginInterstitialEnabled() -> Bool {
  return AppEnvironment.current.userDefaults
    .remoteConfigFeatureFlags[RemoteConfigFeature.facebookLoginInterstitialEnabled.rawValue] ??
    (AppEnvironment.current.remoteConfigClient?
      .isFeatureEnabled(featureKey: RemoteConfigFeature.facebookLoginInterstitialEnabled) ?? false)
}

public func featureUseOfAIProjectTabEnabled() -> Bool {
  return AppEnvironment.current.userDefaults
    .remoteConfigFeatureFlags[RemoteConfigFeature.useOfAIProjectTab.rawValue] ??
    (AppEnvironment.current.remoteConfigClient?
      .isFeatureEnabled(featureKey: RemoteConfigFeature.useOfAIProjectTab) ?? false)
}
