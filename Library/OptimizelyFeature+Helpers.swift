/// Return from user defaults if there is a value, otherwise return from Optimizely

public func featureCommentFlaggingIsEnabled() -> Bool {
  return AppEnvironment.current.userDefaults
    .optimizelyFeatureFlags[OptimizelyFeature.commentFlaggingEnabled.rawValue] ??
    (AppEnvironment.current.optimizelyClient?
      .isFeatureEnabled(featureKey: OptimizelyFeature.commentFlaggingEnabled.rawValue) ?? false)
}

public func featureProjectPageStoryTabEnabled() -> Bool {
  return AppEnvironment.current.userDefaults
    .optimizelyFeatureFlags[OptimizelyFeature.projectPageStoryTabEnabled.rawValue] ??
    (AppEnvironment.current.optimizelyClient?
      .isFeatureEnabled(featureKey: OptimizelyFeature.projectPageStoryTabEnabled.rawValue) ?? false)
}
