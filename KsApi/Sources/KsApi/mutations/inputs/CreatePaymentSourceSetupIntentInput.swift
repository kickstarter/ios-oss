public struct CreatePaymentSourceSetupIntentInput: GraphMutationInput {
  let intentClientSecret: String
  let reuseable: Bool

  public init(intentClientSecret: String, reuseable: Bool) {
    self.intentClientSecret = intentClientSecret
    self.reuseable = reuseable
  }

  public func toInputDictionary() -> [String: Any] {
    return [
      "intentClientSecret": self.intentClientSecret,
      "reusable": self.reuseable
    ]
  }
}
