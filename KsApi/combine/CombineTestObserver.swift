import Combine
import Foundation

public final class CombineTestObserver<Value, Error: Swift.Error> {
  public enum Event {
    case value(Value)
    case error(Error)
    case finished
  }

  public private(set) var events: [Event] = []

  private var subscriptions = Set<AnyCancellable>()

  public func observe(_ publisher: any Publisher<Value, Error>) {
    publisher.sink { [weak self] completion in

      switch completion {
      case let .failure(error):
        self?.events.append(.error(error))
      case .finished:
        self?.events.append(.finished)
      }

    } receiveValue: { [weak self] value in
      self?.events.append(.value(value))
    }
    .store(in: &self.subscriptions)
  }
}
