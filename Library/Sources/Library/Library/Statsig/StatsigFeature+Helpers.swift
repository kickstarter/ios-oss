import KsApi

/// Returns whether the video feed feature is enabled for the current user.
public func featureVideoFeedEnabled() -> Bool {
  AppEnvironment.current.statsigClient?.checkGate(for: .videoFeed) ?? false
}
