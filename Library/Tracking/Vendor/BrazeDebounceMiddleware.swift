import Foundation
import Segment

private let __brazeIntegrationName = "Appboy"

/// Ref: https://github.com/segmentio/segment-braze-mobile-middleware
class BrazeDebounceMiddleware: Middleware {
  var previousIdentifyPayload: IdentifyPayload?

  func context(_ context: Context, next: @escaping SEGMiddlewareNext) {
    var workingContext = context

    // only process identify payloads.
    guard let identify = workingContext.payload as? IdentifyPayload else {
      next(workingContext)
      return
    }

    if self.shouldSendToBraze(payload: identify) {
      // we don't need to do anything, it's different content.
    } else {
      // append to integrations such that this will not be sent to braze.
      var integrations = identify.integrations
      integrations[__brazeIntegrationName] = false
      // provide the list of integrations to a new copy of the payload to pass along.
      workingContext = workingContext.modify { ctx in
        ctx.payload = IdentifyPayload(
          userId: identify.userId,
          anonymousId: identify.anonymousId,
          traits: identify.traits,
          context: identify.context,
          integrations: integrations
        )
      }
    }

    self.previousIdentifyPayload = identify
    next(workingContext)
  }

  func shouldSendToBraze(payload: IdentifyPayload) -> Bool {
    // if userID has changed, send it to braze.
    if payload.userId != self.previousIdentifyPayload?.userId {
      return true
    }

    // if anonymousID has changed, send it to braze.
    if payload.anonymousId != self.previousIdentifyPayload?.anonymousId {
      return true
    }

    // if the traits haven't changed, don't send it to braze.
    if self.traitsEqual(lhs: payload.traits, rhs: self.previousIdentifyPayload?.traits) {
      return false
    }

    return true
  }

  func traitsEqual(lhs: [String: Any]?, rhs: [String: Any]?) -> Bool {
    var result = false

    if lhs == nil, rhs == nil {
      result = true
    }

    if let lhs = lhs, let rhs = rhs {
      result = NSDictionary(dictionary: lhs).isEqual(to: rhs)
    }

    return result
  }
}
