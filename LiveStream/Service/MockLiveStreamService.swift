import Prelude
import ReactiveCocoa

internal struct MockLiveStreamService: LiveStreamServiceProtocol {

  private let fetchEventError: LiveApiError?
  private let fetchEventResponse: LiveStreamEvent?
  private let subscribeToError: LiveApiError?
  private let subscribeToResponse: Bool?

  internal init() {
    self.init(fetchEventError: nil)
  }

  internal init(fetchEventError: LiveApiError? = nil,
                fetchEventResponse: LiveStreamEvent? = nil,
                subscribeToError: LiveApiError? = nil,
                subscribeToResponse: Bool? = nil) {
    self.fetchEventError = fetchEventError
    self.fetchEventResponse = fetchEventResponse
    self.subscribeToError = subscribeToError
    self.subscribeToResponse = subscribeToResponse
  }

  internal func fetchEvent(eventId eventId: String, uid: Int?) -> SignalProducer<LiveStreamEvent, LiveApiError> {
    if let error = self.fetchEventError {
      return SignalProducer(error: error)
    }

    return SignalProducer(value:
      self.fetchEventResponse
        // FIXME: get rid of force unwrap
        ?? .template |> LiveStreamEvent.lens.id .~ Int(eventId)!
    )
  }

  internal func subscribeTo(eventId eventId: String, uid: Int, isSubscribe: Bool)
    -> SignalProducer<Bool, LiveApiError> {

      if let error = self.subscribeToError {
        return SignalProducer(error: error)
      }

      return SignalProducer(value: self.subscribeToResponse ?? (!isSubscribe))
  }
}
