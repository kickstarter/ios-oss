/// Return from user defaults if there is a value, otherwise return from Optimizely

public func featureCommentThreadingIsEnabled() -> Bool {
  return AppEnvironment.current.userDefaults
    .optimizelyFeatureFlags[OptimizelyFeature.commentThreading.rawValue] ??
    (AppEnvironment.current.optimizelyClient?
      .isFeatureEnabled(featureKey: OptimizelyFeature.commentThreading.rawValue) ?? false)
}

public func featureCommentFlaggingIsEnabled() -> Bool {
  return AppEnvironment.current.userDefaults
    .optimizelyFeatureFlags[OptimizelyFeature.commentFlaggingEnabled.rawValue] ??
    (AppEnvironment.current.optimizelyClient?
      .isFeatureEnabled(featureKey: OptimizelyFeature.commentFlaggingEnabled.rawValue) ?? false)
}

public func featureCommentThreadingRepliesIsEnabled() -> Bool {
  return AppEnvironment.current.userDefaults
    .optimizelyFeatureFlags[OptimizelyFeature.commentThreadingRepliesEnabled.rawValue] ??
    (AppEnvironment.current.optimizelyClient?
      .isFeatureEnabled(featureKey: OptimizelyFeature.commentThreadingRepliesEnabled.rawValue) ?? false)
}
