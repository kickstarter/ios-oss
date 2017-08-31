import Prelude

extension Project.Stats {
  public enum lens {
    public static let backersCount = Lens<Project.Stats, Int>(
      view: { $0.backersCount },
      set: { .init(backersCount: $0, commentsCount: $1.commentsCount, currentCurrency: $1.currentCurrency,
                   currentCurrencyRate: $1.currentCurrencyRate, goal: $1.goal, pledged: $1.pledged,
                   staticUsdRate: $1.staticUsdRate, updatesCount: $1.updatesCount) }
    )

    public static let commentsCount = Lens<Project.Stats, Int?>(
      view: { $0.commentsCount },
      set: { .init(backersCount: $1.backersCount, commentsCount: $0, currentCurrency: $1.currentCurrency,
                   currentCurrencyRate: $1.currentCurrencyRate, goal: $1.goal, pledged: $1.pledged,
                   staticUsdRate: $1.staticUsdRate, updatesCount: $1.updatesCount) }
    )

    public static let currentCurrency = Lens<Project.Stats, String?>(
      view: { $0.currentCurrency },
      set: { .init(backersCount: $1.backersCount, commentsCount: $1.commentsCount, currentCurrency: $0,
                   currentCurrencyRate: $1.currentCurrencyRate, goal: $1.goal, pledged: $1.pledged,
                   staticUsdRate: $1.staticUsdRate, updatesCount: $1.updatesCount) }
    )

    public static let currentCurrencyRate = Lens<Project.Stats, Float?>(
      view: { $0.currentCurrencyRate },
      set: { .init(backersCount: $1.backersCount, commentsCount: $1.commentsCount,
                   currentCurrency: $1.currentCurrency, currentCurrencyRate: $0, goal: $1.goal,
                   pledged: $1.pledged, staticUsdRate: $1.staticUsdRate, updatesCount: $1.updatesCount) }
    )

    public static let goal = Lens<Project.Stats, Int>(
      view: { $0.goal },
      set: { .init(backersCount: $1.backersCount, commentsCount: $1.commentsCount,
                   currentCurrency:$1.currentCurrency, currentCurrencyRate: $1.currentCurrencyRate, goal: $0,
                   pledged: $1.pledged, staticUsdRate: $1.staticUsdRate, updatesCount: $1.updatesCount) }
    )

    public static let pledged = Lens<Project.Stats, Int>(
      view: { $0.pledged },
      set: { .init(backersCount: $1.backersCount, commentsCount: $1.commentsCount,
                   currentCurrency: $1.currentCurrency, currentCurrencyRate: $1.currentCurrencyRate,
                   goal: $1.goal, pledged: $0, staticUsdRate: $1.staticUsdRate,
                   updatesCount: $1.updatesCount) }
    )

    public static let staticUsdRate = Lens<Project.Stats, Float>(
      view: { $0.staticUsdRate },
      set: { .init(backersCount: $1.backersCount, commentsCount: $1.commentsCount,
                   currentCurrency: $1.currentCurrency, currentCurrencyRate: $1.currentCurrencyRate,
                   goal: $1.goal, pledged: $1.pledged, staticUsdRate: $0, updatesCount: $1.updatesCount) }
    )

    public static let updatesCount = Lens<Project.Stats, Int?>(
      view: { $0.updatesCount },
      set: { .init(backersCount: $1.backersCount, commentsCount: $1.commentsCount,
                   currentCurrency: $1.currentCurrency, currentCurrencyRate: $1.currentCurrencyRate,
                   goal: $1.goal, pledged: $1.pledged, staticUsdRate: $1.staticUsdRate, updatesCount: $0) }
    )

    public static let fundingProgress = Lens<Project.Stats, Float>(
      view: { $0.fundingProgress },
      set: { .init(backersCount: $1.backersCount, commentsCount: $1.commentsCount,
                   currentCurrency: $1.currentCurrency, currentCurrencyRate: $1.currentCurrencyRate,
                   goal: $1.goal, pledged: Int($0 * Float($1.goal)), staticUsdRate: $1.staticUsdRate,
                   updatesCount: $1.updatesCount) }
    )
  }
}
