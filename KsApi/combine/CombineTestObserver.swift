import Combine
import Foundation
// TODO: do I need to move CombineTestObserver into another package, so this isn't imported into KsApi?
import XCTest

public final class CombineTestObserver<Value: Equatable, Error: Swift.Error> {
  public enum Event {
    case value(Value)
    case error(Error)
    case finished
  }

  public init() {}

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

  public var values: [Value] {
    let values: [Value?] = self.events.map { e in
      if case let .value(value) = e {
        return value
      } else {
        return nil
      }
    }

    return values.filter { $0 != nil } as! [Value]
  }

  public func assertValues(_ values: [Value], _ message: String = "",
                           file: StaticString = #file, line: UInt = #line) {
    XCTAssertEqual(values, self.values, message, file: file, line: line)
  }

  public func assertDidNotEmitValue(_ message: String = "Should not have emitted any values.",
                                    file: StaticString = #file, line: UInt = #line) {
    XCTAssertEqual(0, self.values.count, message, file: file, line: line)
  }

  public func assertDidNotFinish(_ message: String = "Should not have finished.",
                                 file: StaticString = #file, line: UInt = #line) {
    let isFinished = self.events.contains { e in
      if case .finished = e {
        return true
      } else {
        return false
      }
    }

    XCTAssertFalse(isFinished, message, file: file, line: line)
  }
}
