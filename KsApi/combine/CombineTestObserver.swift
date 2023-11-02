import Combine
import Foundation

public final class CombineTestObserver<Value, Error: Swift.Error> {
  public private(set) var events: [Value] = []
  private var subscriptions = Set<AnyCancellable>()

  public func observe(_ publisher: any Publisher<Value, Error>) {
    publisher.sink { _ in
      // TODO(MBL-1017) implement this as part of writing a new test observer for Combine
      fatalError("Errors haven't been handled here yet.")
    } receiveValue: { [weak self] value in
      self?.events.append(value)
    }
    .store(in: &self.subscriptions)
  }
}
