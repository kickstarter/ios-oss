import Prelude

extension User.NewsletterSubscriptions {
  public enum lens {
    public static let arts = Lens<User.NewsletterSubscriptions, Bool?>(
      view: { $0.arts },
      set: { User.NewsletterSubscriptions(arts: $0, games: $1.games, happening: $1.happening, invent: $1.invent, promo: $1.promo,
                                          weekly: $1.weekly) }
    )

    public static let games = Lens<User.NewsletterSubscriptions, Bool?>(
      view: { $0.games },
      set: { User.NewsletterSubscriptions(arts: $1.arts, games: $0, happening: $1.happening, invent: $1.invent, promo: $1.promo,
        weekly: $1.weekly) }
    )

    public static let happening = Lens<User.NewsletterSubscriptions, Bool?>(
      view: { $0.happening },
      set: { User.NewsletterSubscriptions(arts: $1.arts, games: $1.games, happening: $0, invent: $1.invent, promo: $1.promo,
        weekly: $1.weekly) }
    )

    public static let invent = Lens<User.NewsletterSubscriptions, Bool?>(
      view: { $0.invent },
      set: { User.NewsletterSubscriptions(arts: $1.arts, games: $1.games, happening: $1.happening, invent: $0, promo: $1.promo,
                                          weekly: $1.weekly) }
    )

    public static let promo = Lens<User.NewsletterSubscriptions, Bool?>(
      view: { $0.promo },
      set: { User.NewsletterSubscriptions(arts: $1.arts, games: $1.games, happening: $1.happening, invent: $1.invent, promo: $0,
        weekly: $1.weekly) }
    )

    public static let weekly = Lens<User.NewsletterSubscriptions, Bool?>(
      view: { $0.weekly },
      set: { User.NewsletterSubscriptions(arts: $1.arts, games: $1.games, happening: $1.happening, invent: $1.invent, promo: $1.promo,
        weekly: $0) }
    )
  }
}
