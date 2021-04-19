import Appboy_iOS_SDK
import KsApi
import Segment
import Segment_Appboy

public extension Analytics {
  /**
   Returns an `Analytics` instance, with Segment, using an `AnalyticsConfiguration`.
   */
  static func configuredClient() -> Analytics {
    // Due to this being constructed at the same time as the environment we're not able to refer to the
    // mainBundle on the environment here. We probably should if we want to test this.
    let writeKey = Bundle.main.isRelease
      ? Secrets.Segment.production
      : Secrets.Segment.staging

    let configuration = AnalyticsConfiguration(writeKey: writeKey)
    configuration
      .trackApplicationLifecycleEvents = true

    // Braze is always configured but feature-flagged elsewhere.
    configuration.use(SEGAppboyIntegrationFactory.instance())

    Analytics.setup(with: configuration)

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
