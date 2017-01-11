import Prelude
import ReactiveSwift
import Result

extension Result {
  private var value: T? {
    switch self {
    case let .success(value): return value
    case .failure:            return nil
    }
  }
}

internal struct MockLiveStreamService: LiveStreamServiceProtocol {
  private let fetchEventResult: Result<LiveStreamEvent, LiveApiError>?
  private let subscribeToResult: Result<Bool, LiveApiError>?

  internal init() {
    self.init(fetchEventResult: nil)
  }

  internal init(fetchEventResult: Result<LiveStreamEvent, LiveApiError>? = nil,
                subscribeToResult: Result<Bool, LiveApiError>? = nil) {
    self.fetchEventResult = fetchEventResult
    self.subscribeToResult = subscribeToResult
  }

  internal func fetchEvent(eventId: Int, uid: Int?) -> SignalProducer<LiveStreamEvent, LiveApiError> {
    if let error = self.fetchEventResult?.error {
      return SignalProducer(error: error)
    }

    return SignalProducer(value:
      self.fetchEventResult?.value
        ?? .template |> LiveStreamEvent.lens.id .~ eventId
    )
  }

  internal func subscribeTo(eventId: Int, uid: Int, isSubscribed: Bool)
    -> SignalProducer<Bool, LiveApiError> {

      if let error = self.subscribeToResult?.error {
        return SignalProducer(error: error)
      }

      return SignalProducer(value: self.subscribeToResult?.value ?? !isSubscribed)
  }
}
