import Appboy_iOS_SDK
import KsApi
import Segment
import Segment_Appboy

public extension Analytics {
  /**
   Returns an `Analytics` instance, with Segment, using an `AnalyticsConfiguration`.
   */
  static func configuredClient(withWriteKey writeKey: String) -> Analytics {
    let configuration = AnalyticsConfiguration(writeKey: writeKey)
    configuration
      .trackApplicationLifecycleEvents = true

    // Braze is always configured but feature-flagged elsewhere.
    // Data sent to Braze is feature-flagged by the enabling/disabling Segment.
    configuration.use(SEGAppboyIntegrationFactory.instance())

    Analytics.setup(with: configuration)

    // Disabled when initialized and enabled by our feature-flag configuration.
    Analytics.shared().disable()

    return Analytics.shared()
  }
}

/**
 The `TrackingClientType` and `IdentifyingTrackingClient` protocols
 allow us to create mocks to test these code paths. The protocol exposes functions that are named similarly
 but differently so that we can perform the check to see that tracking is enabled before calling any of the
 functions on the library itself so as to not unintentionally contribute to tracking data during debugging.
 */

extension Analytics: IdentifyingTrackingClient {
  public func identify(userId: String?, traits: [String: Any]?) {
    guard AppEnvironment.current.environmentVariables.isTrackingEnabled,
      featureSegmentIsEnabled() else { return }

    self.identify(userId, traits: traits)
  }

  public func resetIdentity() {
    guard AppEnvironment.current.environmentVariables.isTrackingEnabled,
      featureSegmentIsEnabled() else { return }

    self.reset()
  }
}

extension Analytics: TrackingClientType {
  public func track(event: String, properties: [String: Any]) {
    guard AppEnvironment.current.environmentVariables.isTrackingEnabled,
      featureSegmentIsEnabled() else { return }

    self.track(event, properties: properties)
  }
}
