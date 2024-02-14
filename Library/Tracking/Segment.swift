import AppboyKit
import AppboySegment
import KsApi

public extension Analytics {
  /**
   Returns an `Analytics` and `SEGAppboyIntegrationFactory` instance, with Segment, using an `AnalyticsConfiguration`.
   */
  static func configuredClient(withWriteKey writeKey: String) -> AnalyticsConfiguration {
    let configuration = AnalyticsConfiguration(writeKey: writeKey)
    configuration.trackApplicationLifecycleEvents = true
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
