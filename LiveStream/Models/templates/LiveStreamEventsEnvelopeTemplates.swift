import Foundation

extension LiveStreamEventsEnvelope {
  internal static let template = LiveStreamEventsEnvelope(
    numberOfLiveStreams: 1,
    liveStreamEvents: [.template]
  )
}
