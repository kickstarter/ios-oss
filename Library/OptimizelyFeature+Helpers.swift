/// Return from user defaults if there is a value, otherwise return from Optimizely

public func featureCommentThreadingIsEnabled() -> Bool {
  return AppEnvironment.current.userDefaults.commentThreadingEnabled ??
    (AppEnvironment.current.optimizelyClient?
      .isFeatureEnabled(featureKey: OptimizelyFeature.commentThreading.rawValue) ?? false)
}

public func featureCommentFlaggingIsEnabled() -> Bool {
  return AppEnvironment.current.userDefaults.commentFlaggingEnabled ??
    (AppEnvironment.current.optimizelyClient?
      .isFeatureEnabled(featureKey: OptimizelyFeature.commentFlaggingEnabled.rawValue) ?? true)
}

public func featureCommentThreadingRepliesIsEnabled() -> Bool {
  return AppEnvironment.current.userDefaults.commentThreadingRepliesEnabled ??
    AppEnvironment.current.optimizelyClient?
    .isFeatureEnabled(featureKey: OptimizelyFeature.commentThreadingRepliesEnabled.rawValue) ?? true
}
