public func featureCommentThreadingIsEnabled() -> Bool {
  AppEnvironment.current.optimizelyClient?
    .isFeatureEnabled(featureKey: OptimizelyFeature.commentThreading.rawValue) ?? false
}
