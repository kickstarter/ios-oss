extension CheckoutEnvelope {
  internal static let template = CheckoutEnvelope(
    state: .authorizing,
    stateReason: ""
  )

  internal static let authorizing = template

  internal static let failed = CheckoutEnvelope(
    state: .failed,
    stateReason: "Sorry, something went wrong."
  )

  internal static let successful = CheckoutEnvelope(
    state: .successful,
    stateReason: ""
  )

  internal static let verifying = CheckoutEnvelope(
    state: .verifying,
    stateReason: "Blob, your payment method change is being processed."
  )
}
