import Prelude

extension Project.Stats {
  public enum lens {
    public static let fundingProgress = Lens<Project.Stats, Float>(
      view: { $0.fundingProgress },
      set: { .init(
        backersCount: $1.backersCount,
        commentsCount: $1.commentsCount,
        convertedPledgedAmount: $1.convertedPledgedAmount,
        projectCurrency: $1.projectCurrency,
        userCurrency: $1.userCurrency,
        userCurrencyRate: $1.userCurrencyRate,
        goal: $1.goal,
        pledged: Int($0 * Float($1.goal)),
        staticUsdRate: $1.staticUsdRate,
        updatesCount: $1.updatesCount,
        usdExchangeRate: $1.usdExchangeRate
      ) }
    )
  }
}
