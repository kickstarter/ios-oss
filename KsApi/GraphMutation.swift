import Combine
import Foundation

public protocol GraphMutationInput {
  func toInputDictionary() -> [String: Any]
}

protocol GraphMutation: CustomStringConvertible {
  associatedtype Input: GraphMutationInput

  var input: Input { get }
}

public struct EmptyResponseEnvelope: Decodable {}

extension GraphMutationInput where Self: Encodable {
  public func toInputDictionary() -> [String: Any] {
    return self.dictionaryRepresentation ?? [:]
  }
}

extension EmptyResponseEnvelope {
  static func envelopePublisher()
    -> AnyPublisher<EmptyResponseEnvelope, ErrorEnvelope> {
      var userSubject: CurrentValueSubject<EmptyResponseEnvelope, ErrorEnvelope> = .init(EmptyResponseEnvelope())
    var userPublisher: AnyPublisher<EmptyResponseEnvelope, ErrorEnvelope> {
      userSubject.eraseToAnyPublisher()
    }

    userSubject.send(EmptyResponseEnvelope())

    return userPublisher
  }
}
