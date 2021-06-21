public func featureCommentThreadingIsEnabled() -> Bool {
  guard let isEnabledFromUserDefaults = AppEnvironment.current.userDefaults.commentThreadingEnabled else {
    return AppEnvironment.current.optimizelyClient?
      .isFeatureEnabled(featureKey: OptimizelyFeature.commentThreading.rawValue) ?? false
  }
  return isEnabledFromUserDefaults
}

public func featureCommentFlaggingIsEnabled() -> Bool {
  guard let isEnabledFromUserDefaults = AppEnvironment.current.userDefaults.commentFlaggingEnabled else {
    return AppEnvironment.current.optimizelyClient?
      .isFeatureEnabled(featureKey: OptimizelyFeature.commentFlaggingEnabled.rawValue) ?? true
  }
  return isEnabledFromUserDefaults
}

public func featureCommentThreadingRepliesIsEnabled() -> Bool {
  guard let isEnabledFromUserDefaults = AppEnvironment.current.userDefaults.commentThreadingRepliesEnabled
  else {
    return AppEnvironment.current.optimizelyClient?
      .isFeatureEnabled(featureKey: OptimizelyFeature.commentThreadingRepliesEnabled.rawValue) ?? true
  }
  return isEnabledFromUserDefaults
}
