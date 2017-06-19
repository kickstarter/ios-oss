import Prelude

extension CheckoutEnvelope {
  public enum lens {
    public static let state = Lens<CheckoutEnvelope, State>(
      view: { $0.state },
      set: { CheckoutEnvelope(state: $0, stateReason: $1.stateReason) }
    )
    public static let stateReason = Lens<CheckoutEnvelope, String>(
      view: { $0.stateReason },
      set: { CheckoutEnvelope(state: $1.state, stateReason: $0) }
    )
  }
}
