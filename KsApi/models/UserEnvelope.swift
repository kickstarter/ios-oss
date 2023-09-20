import Combine
import Foundation
import ReactiveSwift

public struct UserEnvelope<T: Decodable>: Decodable {
  public let me: T
}

// MARK: - GraphQL Adapters

extension UserEnvelope {
  static func envelopePublisher(from data: GraphAPI.FetchUserQuery.Data)
    -> AnyPublisher<UserEnvelope<GraphUser>, ErrorEnvelope> {
    // FIXME: This should not be a `.template` on `init`, but it always gets updated by either an error or the real user values.
    let userSubject: CurrentValueSubject<UserEnvelope<GraphUser>, ErrorEnvelope> = .init(.init(me: .template))
    var userPublisher: AnyPublisher<UserEnvelope<GraphUser>, ErrorEnvelope> {
      userSubject.eraseToAnyPublisher()
    }

    guard let envelope = UserEnvelope.userEnvelope(from: data) else {
      return userSubject
        .mapError { _ in ErrorEnvelope.graphError("Unavailable") }
        .eraseToAnyPublisher()
    }

    userSubject.send(envelope)

    return userPublisher.eraseToAnyPublisher()
  }

  static func envelopeProducer(from data: GraphAPI.FetchUserQuery.Data)
    -> SignalProducer<UserEnvelope<GraphUser>, ErrorEnvelope> {
    guard let envelope = UserEnvelope.userEnvelope(from: data) else {
      return .empty
    }
    return SignalProducer(value: envelope)
  }

  static func envelopeProducer(from data: GraphAPI.FetchUserEmailQuery.Data)
    -> SignalProducer<UserEnvelope<GraphUserEmail>, ErrorEnvelope> {
    guard let envelope = UserEnvelope.userEnvelope(from: data) else {
      return .empty
    }
    return SignalProducer(value: envelope)
  }

  static func envelopeProducer(from data: GraphAPI.FetchUserQuery.Data)
    -> SignalProducer<UserEnvelope<User>, ErrorEnvelope> {
    guard let envelope = UserEnvelope.user(from: data) else {
      return .empty
    }
    return SignalProducer(value: envelope)
  }
}
