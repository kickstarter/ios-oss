import ReactiveCocoa

public enum LiveApiError: ErrorType {
  case genericFailure
  case invalidEventId
  case invalidJson
}

public protocol LiveStreamServiceProtocol {
  init()
  func fetchEvent(eventId eventId: String, uid: Int?) -> SignalProducer<LiveStreamEvent, LiveApiError>
  func subscribeTo(eventId eventId: String, uid: Int, isSubscribed: Bool)
    -> SignalProducer<Bool, LiveApiError>
}
