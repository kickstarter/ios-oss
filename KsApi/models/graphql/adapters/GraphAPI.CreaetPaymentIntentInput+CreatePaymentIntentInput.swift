extension GraphAPI.CreatePaymentIntentInput {
  static func from(_ input: CreatePaymentIntentInput) -> GraphAPI.CreatePaymentIntentInput {
    return GraphAPI.CreatePaymentIntentInput(
      projectId: input.projectId,
      amountDollars: input.amountDollars,
      digitalMarketingAttributed: input.digitalMarketingAttributed
    )
  }
}
