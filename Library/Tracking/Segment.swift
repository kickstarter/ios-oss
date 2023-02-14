import AppboyKit
import AppboySegment
import KsApi

public extension Analytics {
  /**
   Returns an `Analytics` and `SEGAppboyIntegrationFactory` instance, with Segment, using an `AnalyticsConfiguration`.
   */
  static func configuredClient(withWriteKey writeKey: String)
    -> (AnalyticsConfiguration, SEGAppboyIntegrationFactory?) {
    let configuration = AnalyticsConfiguration(writeKey: writeKey)
    configuration
      .trackApplicationLifecycleEvents = true

    configuration.sourceMiddleware = [BrazeDebounceMiddleware()]
    // Braze is always configured but feature-flagged elsewhere.
    // Data sent to Braze is feature-flagged by the enabling/disabling Segment.
    // FIXME: For some reason this instance of SEGAppyboyIntegrationFactory is not the same as one passed in. It's supposed to be the same singleton.
    guard let factoryInstance = SEGAppboyIntegrationFactory.instance() else {
      return (configuration, nil)
    }

    configuration.use(factoryInstance)

    return (configuration, factoryInstance)
  }
}

/**
 The `TrackingClientType` and `IdentifyingTrackingClient` protocols
 allow us to create mocks to test these code paths.
 */
extension Analytics: IdentifyingTrackingClient {}
extension Analytics: TrackingClientType {}
