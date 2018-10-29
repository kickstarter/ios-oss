import Prelude

extension Project.Stats {
  public enum lens {
    public static let fundingProgress = Lens<Project.Stats, Float>(
      view: { $0.fundingProgress },
      set: { .init(backersCount: $1.backersCount,
                   commentsCount: $1.commentsCount,
                   currency: $1.currency,
                   currentCurrency: $1.currentCurrency,
                   currentCurrencyRate: $1.currentCurrencyRate,
                   goal: $1.goal,
                   pledged: Int($0 * Float($1.goal)),
                   staticUsdRate: $1.staticUsdRate,
                   updatesCount: $1.updatesCount) }
    )
  }
}
