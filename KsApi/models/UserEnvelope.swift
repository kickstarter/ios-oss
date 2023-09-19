import Foundation
import ReactiveSwift
import Combine

public struct UserEnvelope<T: Decodable>: Decodable {
  public let me: T
}

// MARK: - GraphQL Adapters

extension UserEnvelope {
  static func envelopePublisher(from data: GraphAPI.FetchUserQuery.Data)
    -> AnyPublisher<UserEnvelope<GraphUser>, ErrorEnvelope> {
      var userSubject: PassthroughSubject<UserEnvelope<GraphUser>, ErrorEnvelope> = .init()
      var userPublisher: AnyPublisher<UserEnvelope<GraphUser>, ErrorEnvelope> {
        userSubject.eraseToAnyPublisher()
      }
      
      guard let envelope = UserEnvelope.userEnvelope(from: data) else {
        return userSubject
          .mapError { _ in ErrorEnvelope.graphError("could not parse graph data.") }
          .eraseToAnyPublisher()
      }
    
      userSubject.send(envelope)
      
      return userPublisher
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
