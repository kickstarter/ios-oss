import Prelude

extension User.NewsletterSubscriptions {
  public enum lens {
    public static let games = Lens<User.NewsletterSubscriptions, Bool?>(
      view: { $0.games },
      set: { User.NewsletterSubscriptions(games: $0, happening: $1.happening, promo: $1.promo,
        weekly: $1.weekly) }
    )

    public static let happening = Lens<User.NewsletterSubscriptions, Bool?>(
      view: { $0.happening },
      set: { User.NewsletterSubscriptions(games: $1.games, happening: $0, promo: $1.promo,
        weekly: $1.weekly) }
    )

    public static let promo = Lens<User.NewsletterSubscriptions, Bool?>(
      view: { $0.promo },
      set: { User.NewsletterSubscriptions(games: $1.games, happening: $1.happening, promo: $0,
        weekly: $1.weekly) }
    )

    public static let weekly = Lens<User.NewsletterSubscriptions, Bool?>(
      view: { $0.weekly },
      set: { User.NewsletterSubscriptions(games: $1.games, happening: $1.happening, promo: $1.promo,
        weekly: $0) }
    )
  }
}
