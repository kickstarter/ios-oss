import XCTest
import ReactiveCocoa

internal extension Event {
  internal var isNext: Bool {
    if case .Next = self {
      return true
    }
    return false
  }

  internal var isCompleted: Bool {
    if case .Completed = self {
      return true
    }
    return false
  }

  internal var isFailed: Bool {
    if case .Failed = self {
      return true
    }
    return false
  }

  internal var isInterrupted: Bool {
    if case .Interrupted = self {
      return true
    }
    return false
  }
}

/**
 A `TestObserver` is a wrapper around an `Observer` that saves all events to an internal array so that
 assertions can be made on a signal's behavior. To use, just create an instance of `TestObserver` that
 matches the type of signal/producer you are testing, and observer/start your signal by feeding it the
 wrapped observer. For example,

 ```
 let test = TestObserver<Int, NoError>()
 mySignal.observer(test.observer)

 // ... later ...

 XCTAssertEqual(test.nextValues, [1, 2, 3])
 ```
 */
public final class TestObserver <Value, Error: ErrorType> {

  public private(set) var events: [Event<Value, Error>] = []
  public private(set) var observer: Observer<Value, Error>!

  public init() {
    self.observer = Observer<Value, Error>(action)
  }

  private func action(event: Event<Value, Error>) -> () {
    self.events.append(event)
  }

  /// Get all of the next values emitted by the signal.
  public var nextValues: [Value] {
    return self.events.filter { $0.isNext }.map { $0.value! }
  }

  /// Get the last value emitted by the signal.
  public var lastValue: Value? {
    return self.nextValues.last
  }

  /// Determines if a next value has been emitted.
  public var didEmitValue: Bool {
    return self.nextValues.count > 0
  }

  /// Get the error from the signal if it has failed.
  public var failedError: Error? {
    return self.events.filter { $0.isFailed }.map { $0.error! }.first
  }

  /// Determines if the signal has failed.
  public var didFail: Bool {
    return self.failedError != nil
  }

  /// Determines if the signal has completed.
  public var didComplete: Bool {
    return self.events.filter { $0.isCompleted }.count > 0
  }

  /// Determines if the signal has interrupted.
  public var didInterrupt: Bool {
    return self.events.filter { $0.isInterrupted }.count > 0
  }
}
