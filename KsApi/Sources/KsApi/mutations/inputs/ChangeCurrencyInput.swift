import Foundation

public struct ChangeCurrencyInput: GraphMutationInput {
  let chosenCurrency: String

  public init(chosenCurrency: String) {
    self.chosenCurrency = chosenCurrency
  }

  public func toInputDictionary() -> [String: Any] {
    return ["chosenCurrency": self.chosenCurrency]
  }
}
