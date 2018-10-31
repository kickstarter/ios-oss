import Foundation

extension Project.Stats {
  internal static let template = Project.Stats(
    backersCount: 10,
    commentsCount: 10,
    currency: "USD",
    currentCurrency: nil,
    currentCurrencyRate: 1.5,
    goal: 2_000,
    pledged: 1_000,
    staticUsdRate: 1.0,
    updatesCount: 1
  )
}
