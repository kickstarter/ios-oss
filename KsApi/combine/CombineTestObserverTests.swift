import Combine
import XCTest

final class ConcreteError: Error {
  var message: String

  init(message: String) {
    self.message = message
  }
}

final class CombineTestObserverTests: XCTestCase {
  var publisher = PassthroughSubject<Bool, ConcreteError>()
  var observer = CombineTestObserver<Bool, ConcreteError>()

  override func setUp() {
    self.publisher = PassthroughSubject<Bool, ConcreteError>()
    self.observer = CombineTestObserver<Bool, ConcreteError>()

    self.observer.observe(self.publisher)
  }

  func testValues() {
    self.publisher.send(true)
    self.observer.assertValue(true)

    self.publisher.send(false)
    self.observer.assertLastValue(false)

    self.observer.assertValues([true, false])

    self.observer.assertDidNotFail()
    self.observer.assertDidNotComplete()
  }

  func testFailure() {
    self.publisher.send(true)
    self.observer.assertValue(true)

    let msg = "failure :("
    let error = ConcreteError(message: msg)

    publisher.send(completion: Subscribers.Completion.failure(error))

    self.observer.assertDidFail()
    XCTAssertEqual(self.observer.failedError?.message, msg)

    // n.B. in Combine, a publisher also finishes and cannot continue
    // after an error occurs.
    self.observer.assertDidComplete()
  }

  func testCompletion() {
    self.publisher.send(false)
    self.observer.assertValue(false)

    self.publisher.send(completion: Subscribers.Completion.finished)
    self.observer.assertDidComplete()
    self.observer.assertDidNotFail()
  }
}
