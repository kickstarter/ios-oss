import ReactiveSwift

public enum LiveApiError: Error {
  case genericFailure
  case invalidEventId
  case invalidJson
}

public protocol LiveStreamServiceProtocol {
  init()
  func fetchEvent(eventId: Int, uid: Int?) -> SignalProducer<LiveStreamEvent, LiveApiError>
  func subscribeTo(eventId: Int, uid: Int, isSubscribed: Bool) -> SignalProducer<Bool, LiveApiError>
}
