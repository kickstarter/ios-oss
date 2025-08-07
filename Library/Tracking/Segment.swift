import BrazeKitCompat
import SegmentBraze
import Segment
import KsApi

public extension Analytics {
  /**
   Returns an `Analytics` and `SEGAppboyIntegrationFactory` instance, with Segment, using an `AnalyticsConfiguration`.
   */
  static func configuredClient(withWriteKey writeKey: String) -> Analytics {
    let configuration = Configuration(writeKey: writeKey)
      .flushAt(3)
      .flushInterval(10)
      .setTrackedApplicationLifecycleEvents([
        .applicationInstalled,
        .applicationUpdated,
        .applicationOpened,
        .applicationBackgrounded,
    ])
//    configuration.sourceMiddleware = [BrazeDebounceMiddleware()]
    return Analytics(configuration: configuration)
  }
}

/**
 The `TrackingClientType` and `IdentifyingTrackingClient` protocols
 allow us to create mocks to test these code paths.
 */
extension Analytics: IdentifyingTrackingClient {}
extension Analytics: TrackingClientType {}

//extension Analytics {
//    (SegAnalytics)shared() {
//        return analytics; // or whatever variable name you're using
//    }
//}
