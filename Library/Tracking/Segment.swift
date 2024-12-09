import BrazeKitCompat
import KsApi
import Segment
import SegmentBrazeUI

public extension Analytics {
  /**
   Returns an `Analytics` and `SEGAppboyIntegrationFactory` instance, with Segment, using an `AnalyticsConfiguration`.
   */
  static func configuredAnalytics(
    withWriteKey writeKey: String,
    brazeDestination: BrazeDestination
  )
    -> Segment.Analytics {
    let configuration = Configuration(writeKey: writeKey)
      .flushAt(3) // Recommended number by https://github.com/braze-inc/braze-segment-swift
      .trackApplicationLifecycleEvents(true)

    let analytics = Analytics(configuration: configuration)
    analytics.add(plugin: brazeDestination)

    let middleware = BrazeDebounceMiddlewarePlugin()
    analytics.add(plugin: middleware)

    return analytics
  }
}

/**
 The `TrackingClientType` and `IdentifyingTrackingClient` protocols
 allow us to create mocks to test these code paths.
 */
// extension Analytics: IdentifyingTrackingClient {}
// extension Analytics: TrackingClientType {}
