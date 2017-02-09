// swiftlint:disable type_name
import Argo
import Curry
import Prelude
import Runes

public struct LiveStreamSubscribeEnvelope {
  public fileprivate(set) var success: Bool
  public fileprivate(set) var reason: String?
}

extension LiveStreamSubscribeEnvelope: Decodable {
  static public func decode(_ json: JSON) -> Decoded<LiveStreamSubscribeEnvelope> {
    return curry(LiveStreamSubscribeEnvelope.init)
      <^> json <| "success"
      <*> json <|? "reason"
  }
}

extension LiveStreamSubscribeEnvelope {
  public enum lens {
    public static let success = Lens<LiveStreamSubscribeEnvelope, Bool>(
      view: { $0.success },
      set: { var new = $1; new.success = $0; return new }
    )
    public static let reason = Lens<LiveStreamSubscribeEnvelope, String?>(
      view: { $0.reason },
      set: { var new = $1; new.reason = $0; return new }
    )
  }
}
