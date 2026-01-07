import KsApi

/// Return remote config values either a value from the cloud, if it found one, or an override value from user defaults.
func featureEnabled(feature: RemoteConfigFeature) -> Bool {
  if let valueFromDefaults = AppEnvironment.current.userDefaults
    .remoteConfigFeatureFlags[feature.rawValue] {
    return valueFromDefaults
  }

  if let valueFromRemoteConfig = AppEnvironment.current.remoteConfigClient?
    .isFeatureEnabled(featureKey: feature) {
    return valueFromRemoteConfig
  }

  return false
}

public func featureBypassPledgeManagerDecisionPolicyEnabled() -> Bool {
  return featureEnabled(feature: .bypassPledgeManagerDecisionPolicy)
}

public func featureEditPledgeOverTimeEnabled() -> Bool {
  return featureEnabled(feature: .editPledgeOverTimeEnabled)
}

public func featureUseKeychainForOAuthTokenEnabled() -> Bool {
  featureEnabled(feature: .useKeychainForOAuthToken)
}

public func featurePillViewTabBarEnabled() -> Bool {
  featureEnabled(feature: .pillTabBar)
}

public func featurePledgedProjectsOverviewV2Enabled() -> Bool {
  featureEnabled(feature: .pledgedProjectsOverviewV2Enabled)
}

public func featurePledgeOverTimeEnabled() -> Bool {
  featureEnabled(feature: .pledgeOverTime)
}

public func featureRewardShipmentTrackingEnabled() -> Bool {
  featureEnabled(feature: .rewardShipmentTracking)
}

public func featureSimilarProjectsCarouselEnabled() -> Bool {
  featureEnabled(feature: .similarProjectsCarousel)
}
