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

    configuration.sourceMiddleware = [BrazeDebounceMiddleware()]

    Analytics.setup(with: configuration)

    // Disabled when initialized and enabled by our feature-flag configuration.
    Analytics.shared().disable()

    return Analytics.shared()
  }
}

/**
 The `TrackingClientType` and `IdentifyingTrackingClient` protocols
 allow us to create mocks to test these code paths.
 */
extension Analytics: IdentifyingTrackingClient {}
extension Analytics: TrackingClientType {}
