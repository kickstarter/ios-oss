import Foundation
import Segment

private let __brazeIntegrationName = "Appboy"

/// Ref: https://github.com/segmentio/segment-braze-mobile-middleware for the middleware
/// In the new integration, all middlewares must be rewritten as plugins.
/// https://github.com/segmentio/analytics-react-native/blob/master/packages/plugins/plugin-braze-middleware/src/BrazeMiddlewarePlugin.tsx
/// for a plugin example
class BrazeDebounceMiddlewarePlugin: EventPlugin {
  weak var analytics: Segment.Analytics?
  
  let type = PluginType.before
  private var previousIdentifyEvent: IdentifyEvent?
  
  public func track(event: TrackEvent) -> TrackEvent? {
    if event.event == "Application Foregrounded" {
      return nil
    }
    return event
  }
  
  public func identify(event: IdentifyEvent) -> IdentifyEvent? {
    var mutableEvent = event
  
    if !self.shouldSendToBraze(event) {
      let integrations = try? event.integrations?.add(value: false, forKey: __brazeIntegrationName)
      mutableEvent.integrations = integrations
    }
    
    self.previousIdentifyEvent = event
    return mutableEvent
  }

  func shouldSendToBraze(_ event: IdentifyEvent) -> Bool {
    // if userID has changed, send it to braze.
    if event.userId != self.previousIdentifyEvent?.userId {
      return true
    }

    // if anonymousID has changed, send it to braze.
    if event.anonymousId != self.previousIdentifyEvent?.anonymousId {
      return true
    }

    // if the traits haven't changed, don't send it to braze.
    if event.traits != self.previousIdentifyEvent?.traits {
      return true
    }

    return false
  }
}
