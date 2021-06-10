import KsApi

public func featureCommentThreadingIsEnabled() -> Bool {
  AppEnvironment.current.optimizelyClient?
    .isFeatureEnabled(featureKey: OptimizelyFeature.Key.commentThreading.rawValue) ?? false
}
