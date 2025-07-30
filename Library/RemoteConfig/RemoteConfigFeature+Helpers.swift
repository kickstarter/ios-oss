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

public func featureEditPledgeOverTimeEnabled() -> Bool {
  return featureEnabled(feature: .editPledgeOverTimeEnabled)
}

public func featurePostCampaignPledgeEnabled() -> Bool {
  featureEnabled(feature: .postCampaignPledgeEnabled)
}

public func featureUseKeychainForOAuthTokenEnabled() -> Bool {
  featureEnabled(feature: .useKeychainForOAuthToken)
}

public func featureOnboardingFlowEnabled() -> Bool {
  featureEnabled(feature: .onboardingFlow)
}

public func featurePledgedProjectsOverviewV2Enabled() -> Bool {
  featureEnabled(feature: .pledgedProjectsOverviewV2Enabled)
}

public func featurePledgeOverTimeEnabled() -> Bool {
  featureEnabled(feature: .pledgeOverTime)
}

public func featureNetNewBackersWebViewEnabled() -> Bool {
  featureEnabled(feature: .netNewBackersWebView)
}

public func featureNewDesignSystemEnabled() -> Bool {
  featureEnabled(feature: .newDesignSystem)
}

public func featureRewardShipmentTrackingEnabled() -> Bool {
  featureEnabled(feature: .rewardShipmentTracking)
}

public func featureSimilarProjectsCarouselEnabled() -> Bool {
  featureEnabled(feature: .similarProjectsCarousel)
}

public func featureSecretRewardsEnabled() -> Bool {
  featureEnabled(feature: .secretRewards)
}

public func featureSearchFilterByLocation() -> Bool {
  featureEnabled(feature: .searchFilterByLocation)
}

public func featureNetNewBackersGoToPMEnabled() -> Bool {
  featureEnabled(feature: .netNewBackersGoToPM)
}

public func featureSearchFilterByAmountRaised() -> Bool {
  featureEnabled(feature: .searchFilterByAmountRaised)
}

public func featureSearchFilterByShowOnlyToggles() -> Bool {
  featureEnabled(feature: .searchFilterByShowOnlyToggles)
}

public func featureSearchFilterByGoal() -> Bool {
  featureEnabled(feature: .searchFilterByGoal)
}

public func featureSearchNewEmptyState() -> Bool {
  featureEnabled(feature: .searchNewEmptyState)
}
