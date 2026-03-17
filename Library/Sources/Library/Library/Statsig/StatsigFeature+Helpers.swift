import KsApi

/// Returns the value for a given Statsig feature flag. User defaults are checked first and,
/// if a value is found, it is returned immediately as an "override" (e.g. via beta tools) without.
/// Otherwise, the value from the Statsig client is used, falling back to
/// `false` if neither place has a value.
private func featureEnabled(feature: StatsigFeature) -> Bool {
  if let valueFromDefaults = AppEnvironment.current.userDefaults
    .statsigFeatureFlags[feature.rawValue] {
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
