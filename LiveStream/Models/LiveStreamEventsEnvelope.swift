import Argo
import Curry
import Prelude
import Runes

public struct LiveStreamEventsEnvelope {
  public fileprivate(set) var numberOfLiveStreams: Int
  public fileprivate(set) var liveStreamEvents: [LiveStreamEvent]
}

extension LiveStreamEventsEnvelope: Decodable {
  static public func decode(_ json: JSON) -> Decoded<LiveStreamEventsEnvelope> {
    return curry(LiveStreamEventsEnvelope.init)
      <^> json <| "number_live_streams"
      <*> json <|| "live_streams"
  }
}

extension LiveStreamEventsEnvelope {
  public enum lens {
    public static let numberOfLiveStreams = Lens<LiveStreamEventsEnvelope, Int>(
      view: { $0.numberOfLiveStreams },
      set: { var new = $1; new.numberOfLiveStreams = $0; return new }
    )
    public static let liveStreamEvents = Lens<LiveStreamEventsEnvelope, [LiveStreamEvent]>(
      view: { $0.liveStreamEvents },
      set: { var new = $1; new.liveStreamEvents = $0; return new }
    )
  }
}
