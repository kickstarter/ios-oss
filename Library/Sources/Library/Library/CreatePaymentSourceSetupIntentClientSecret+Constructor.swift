import KsApi

extension CreatePaymentSourceSetupIntentInput {
  internal static func input(
    fromIntentClientSecret token: String,
    reuseable: Bool
  ) -> CreatePaymentSourceSetupIntentInput {
    return CreatePaymentSourceSetupIntentInput(intentClientSecret: token, reuseable: reuseable)
  }
}
