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

/**
 The `TrackingClientType` and `IdentifyingTrackingClient` protocols allow us to create mocks
 to test these code paths. The protocol exposes functions that are named similarly but differently
 so that we can perform the check to see that tracking is enabled before calling any of the functions on
 the library itself so as to not unintentionally contribute to tracking data during debugging.
 */

extension Analytics: IdentifyingTrackingClient {
  public func identify(userId: String?, traits: [String: Any]?) {
    guard AppEnvironment.current.environmentVariables.isTrackingEnabled else { return }

    self.identify(userId, traits: traits)
  }

  public func resetIdentity() {
    guard AppEnvironment.current.environmentVariables.isTrackingEnabled else { return }

    self.reset()
  }
}

extension Analytics: TrackingClientType {
  public func track(event: String, properties: [String: Any]) {
    guard AppEnvironment.current.environmentVariables.isTrackingEnabled else { return }

    self.track(event, properties: properties)
  }
}
