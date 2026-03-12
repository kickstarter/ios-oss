import KsApi

/// Return statsig values either a value from the cloud, if it found one, or an override value from user defaults.
private func featureEnabled(feature: StatsigFeature) -> Bool {
  if let valueFromDefaults = AppEnvironment.current.userDefaults
    .remoteConfigFeatureFlags[feature.rawValue] {
    return valueFromDefaults
  }

  if let valueFromStatsig = AppEnvironment.current.statsigClient?
    .isFeatureEnabled(featureKey: feature) {
    return valueFromStatsig
  }

  return false
}

/// Returns whether the video feed feature is enabled for the current user.
public func featureVideoFeedEnabled() -> Bool {
  featureEnabled(feature: .videoFeed)
}
