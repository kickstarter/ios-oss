import KsApi
import Segment

public extension Analytics {
  static func configuredClient() -> Analytics {
    let configuration = AnalyticsConfiguration(writeKey: Secrets.Segment.writeKey)
    configuration
      .trackApplicationLifecycleEvents = true // We should deprecate our own tracking for these events.
    configuration.recordScreenViews = true // Test that this does not interfere with our own swizzling.
    Analytics.setup(with: configuration)

    return Analytics.shared()
  }
}

extension Analytics: IdentifyingTrackingClient {
  /// Call the similarly named function on Segment's `Analytics` type.
  public func identify(userId: String?, traits: [String: Any]?) {
    guard AppEnvironment.current.environmentVariables.isTrackingEnabled else { return }

    self.identify(userId, traits: traits)
  }
}

extension Analytics: TrackingClientType {
  /// Call the similarly named function on Segment's `Analytics` type.
  public func track(event: String, properties: [String: Any]) {
    guard AppEnvironment.current.environmentVariables.isTrackingEnabled else { return }

    self.track(event, properties: properties)
  }
}
