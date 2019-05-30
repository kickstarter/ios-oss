import Foundation

public struct EmptyInput: GraphMutationInput {
  public init() {}

  public func toInputDictionary() -> [String: Any] {
    return [:]
  }
}
