import Foundation

public protocol GraphMutationInput {
  func toInputDictionary() -> [String: Any]
}

protocol GraphMutation: CustomStringConvertible {
  var input: GraphMutationInput { get set }
}

public struct GraphMutationEmptyResponseEnvelope: Decodable {}
