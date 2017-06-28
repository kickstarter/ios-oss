import Prelude

extension Reward.Shipping {
  public enum lens {
    public static let enabled = Lens<Reward.Shipping, Bool>(
      view: { $0.enabled },
      set: { .init(enabled: $0, preference: $1.preference, summary: $1.summary) }
    )

    public static let preference = Lens<Reward.Shipping, Reward.Shipping.Preference?>(
      view: { $0.preference },
      set: { .init(enabled: $1.enabled, preference: $0, summary: $1.summary) }
    )

    public static let summary = Lens<Reward.Shipping, String?>(
      view: { $0.summary },
      set: { .init(enabled: $1.enabled, preference: $1.preference, summary: $0) }
    )
  }
}
