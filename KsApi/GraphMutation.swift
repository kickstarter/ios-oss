import Foundation

public protocol GraphMutationInput {
  func toInputDictionary() -> [String: Any]
}

protocol GraphMutation: CustomStringConvertible {
  associatedtype Input: GraphMutationInput

  var input: Input { get }
}

public struct GraphMutationEmptyResponseEnvelope: Decodable {}
