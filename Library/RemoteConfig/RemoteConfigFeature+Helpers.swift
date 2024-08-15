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

public func featureDarkModeEnabled() -> Bool {
  return featureEnabled(feature: .darkModeEnabled)
}

public func featureNoShippingAtCheckout() -> Bool {
  true
}

public func featurePostCampaignPledgeEnabled() -> Bool {
  featureEnabled(feature: .postCampaignPledgeEnabled)
}

public func featureUseKeychainForOAuthTokenEnabled() -> Bool {
  featureEnabled(feature: .useKeychainForOAuthToken)
}

public func featurePledgedProjectsOverviewEnabled() -> Bool {
  featureEnabled(feature: .pledgedProjectsOverviewEnabled)
}
