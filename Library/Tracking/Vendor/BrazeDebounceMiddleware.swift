import Foundation
import Segment

// TODO: Revisit this to decide if it's doing the right thing

private let __brazeIntegrationName = "Appboy"

/// Ref: https://github.com/segmentio/segment-braze-mobile-middleware for the middleware
/// In the new integration, all middlewares must be rewritten as plugins.
/// https://github.com/segmentio/analytics-react-native/blob/master/packages/plugins/plugin-braze-middleware/src/BrazeMiddlewarePlugin.tsx
/// for a plugin example
public class BrazeDebounceMiddlewarePlugin: EventPlugin {
  public weak var analytics: Segment.Analytics?
  
  public let type = PluginType.before
  private var previousIdentifyEvent: IdentifyEvent?
  
  public init(analytics: Segment.Analytics? = nil, previousIdentifyEvent: IdentifyEvent? = nil) {
    self.analytics = analytics
    self.previousIdentifyEvent = previousIdentifyEvent
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
