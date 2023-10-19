import Combine
import Foundation
import ReactiveSwift

extension Signal where Error == Never {
  var combinePublisher: AnyPublisher<Value, Never> {
    let subject = PassthroughSubject<Value, Never>()
    self.observeValues { value in
      subject.send(value)
    }

    return subject.eraseToAnyPublisher()
  }

  public func assign(toCombine published: inout Published<Value>.Publisher) {
    self.combinePublisher.assign(to: &published)
  }
}
