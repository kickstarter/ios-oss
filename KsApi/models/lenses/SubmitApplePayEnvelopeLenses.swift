import Prelude

extension SubmitApplePayEnvelope {
  public enum lens {
    public static let thankYouUrl = Lens<SubmitApplePayEnvelope, String>(
      view: { $0.thankYouUrl },
      set: { .init(thankYouUrl: $0, status: $1.status) }
    )

    public static let status = Lens<SubmitApplePayEnvelope, Int>(
      view: { $0.status },
      set: { .init(thankYouUrl: $1.thankYouUrl, status: $0) }
    )
  }
}
