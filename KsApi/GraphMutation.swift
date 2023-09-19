import Foundation
import Combine

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
    -> AnyPublisher<EmptyResponseEnvelope, Never> {
      var userSubject: PassthroughSubject<EmptyResponseEnvelope, Never> = .init()
      var userPublisher: AnyPublisher<EmptyResponseEnvelope, Never> {
        userSubject.eraseToAnyPublisher()
      }

      userSubject.send(EmptyResponseEnvelope())
      
      return userPublisher
  }
}
