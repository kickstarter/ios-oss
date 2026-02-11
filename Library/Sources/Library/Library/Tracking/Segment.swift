import KsApi
import Segment

public extension Analytics {
  /**
   Returns an `Analytics` instance.
   */
  static func configuredClient(withWriteKey writeKey: String) -> Analytics {
    let configuration = Configuration(writeKey: writeKey)
      // flushAt and flushInterval numbers from https://segment.com/docs/connections/sources/catalog/libraries/mobile/apple/migration/#1b-modify-your-initialized-instance
      .flushAt(3)
      .flushInterval(10)
      // TODO(MBL-2742): Revisit if we want to include more lifecycle events.
      .setTrackedApplicationLifecycleEvents([
        .applicationInstalled,
        .applicationUpdated,
        .applicationOpened,
        .applicationBackgrounded
      ])
    return Analytics(configuration: configuration)
  }
}

/**
 The `TrackingClientType` and `IdentifyingTrackingClient` protocols
 allow us to create mocks to test these code paths.
 */
extension Analytics: IdentifyingTrackingClient {}
extension Analytics: TrackingClientType {}
