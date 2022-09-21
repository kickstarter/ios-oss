import AppboySegment
import KsApi

public extension Analytics {
  /**
   Returns an `Analytics` instance, with Segment, using an `AnalyticsConfiguration`.
   */
  static func configuredClient(withWriteKey writeKey: String) -> AnalyticsConfiguration {
    let configuration = AnalyticsConfiguration(writeKey: writeKey)
    configuration
      .trackApplicationLifecycleEvents = true

    // Braze is always configured but feature-flagged elsewhere.
    // Data sent to Braze is feature-flagged by the enabling/disabling Segment.
    configuration.use(SEGAppboyIntegrationFactory.instance())

    configuration.sourceMiddleware = [BrazeDebounceMiddleware()]

    return configuration
  }
}

/**
 The `TrackingClientType` and `IdentifyingTrackingClient` protocols
 allow us to create mocks to test these code paths.
 */
extension Analytics: IdentifyingTrackingClient {}
extension Analytics: TrackingClientType {}
