import Prelude

extension CreatePledgeEnvelope {
  public enum lens {
    public static let checkoutUrl = Lens<CreatePledgeEnvelope, String?>(
      view: { $0.checkoutUrl },
      set: { .init(checkoutUrl: $0, newCheckoutUrl: $1.newCheckoutUrl, status: $1.status) }
    )

    public static let newCheckoutUrl = Lens<CreatePledgeEnvelope, String?>(
      view: { $0.checkoutUrl },
      set: { .init(checkoutUrl: $1.checkoutUrl, newCheckoutUrl: $0, status: $1.status) }
    )

    public static let status = Lens<CreatePledgeEnvelope, Int>(
      view: { $0.status },
      set: { .init(checkoutUrl: $1.checkoutUrl, newCheckoutUrl: $1.newCheckoutUrl, status: $0) }
    )
  }
}
