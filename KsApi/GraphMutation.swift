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
