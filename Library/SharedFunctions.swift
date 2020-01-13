import KsApi
import Prelude
import ReactiveSwift
import UserNotifications

/**
 Determines if the personalization data in the project implies that the current user is backing the
 reward passed in. Because of the many ways in which we can get this data we have multiple ways of
 determining this.

 - parameter reward:  A reward.
 - parameter project: A project.

 - returns: A boolean.
 */
internal func userIsBacking(reward: Reward, inProject project: Project) -> Bool {
  guard let backing = project.personalization.backing else { return false }

  return backing.reward?.id == reward.id
    || backing.rewardId == reward.id
    || (backing.reward == nil && backing.rewardId == nil && reward == Reward.noReward)
}

/**
 Determines if the current user is the creator for a given project.

 - parameter project: A project.

 - returns: A boolean.
 */
public func currentUserIsCreator(of project: Project) -> Bool {
  guard let user = AppEnvironment.current.currentUser else { return false }

  return project.creator.id == user.id
}

/**
 Returns a reward from a backing in a given project

 - parameter backing: A backing
 - parameter project: A project

 - returns: A reward
 */

internal func reward(from backing: Backing, inProject project: Project) -> Reward {
  let noRewardFromProject = project.rewards.filter { $0.id == Reward.noReward.id }.first

  return backing.reward
    ?? project.rewards.filter { $0.id == backing.rewardId }.first
    ?? noRewardFromProject
    ?? Reward.noReward
}

/**
 Computes the pledge context (i.e. new pledge, managing reward, changing reward) from a project and reward.

 - parameter project: A project.
 - parameter reward:  A reward.

 - returns: A pledge context.
 */
internal func pledgeContext(forProject project: Project, reward: Reward) -> Koala.PledgeContext {
  if project.personalization.isBacking == .some(true) {
    return userIsBacking(reward: reward, inProject: project) ? .manageReward : .changeReward
  }
  return .newPledge
}

/**
 Computes the minimum and maximum amounts that can be pledge to a reward. For the "no reward" reward,
 this looks up values in the table of launched countries, since the values depend on the currency.

 - parameter project: A project.
 - parameter reward:  A reward.

 - returns: A pair of the minimum and maximum amount that can be pledged to a reward.
 */
internal func minAndMaxPledgeAmount(forProject project: Project, reward: Reward?)
  -> (min: Double, max: Double) {
  // The country on the project cannot be trusted to have the min/max values, so first try looking
  // up the country in our launched countries array that we get back from the server config.
  let country = AppEnvironment.current.launchedCountries.countries
    .filter { $0 == project.country }
    .first
    .coalesceWith(project.country)

  switch reward {
  case .none, .some(Reward.noReward):
    return (Double(country.minPledge ?? 1), Double(country.maxPledge ?? 10_000))
  case let .some(reward):
    return (reward.minimum, Double(country.maxPledge ?? 10_000))
  }
}

/**
 Computes the minimum amount needed to pledge to a reward. For the "no reward" reward,
 this looks up values in the table of launched countries, since the values depend on the currency.

 - parameter project: A project.
 - parameter reward:  A reward.

 - returns: The minimum amount needed to pledge to the reward.
 */
internal func minPledgeAmount(forProject project: Project, reward: Reward?) -> Double {
  return minAndMaxPledgeAmount(forProject: project, reward: reward).min
}

/**
 Returns the full currency symbol for a country. Special logic is added around prefixing currency symbols
 with country/currency codes based on a variety of factors.

 - parameter country: The country.
 - parameter omitCurrencyCode: Safe to omit the US currencyCode
 - parameter env: Current Environment.

 - returns: The currency symbol that can be used for currency display.
 */
public func currencySymbol(
  forCountry country: Project.Country,
  omitCurrencyCode: Bool = true,
  env: Environment = AppEnvironment.current
) -> String {
  guard env.launchedCountries.currencyNeedsCode(country.currencySymbol) else {
    // Currencies that dont have ambigious currencies can just use their symbol.
    return country.currencySymbol
  }

  if country == .us && env.countryCode == Project.Country.us.countryCode && omitCurrencyCode {
    // US people looking at US projects just get the currency symbol
    return country.currencySymbol
  } else if country == .sg {
    // Singapore projects get a special currency prefix
    return "\(String.nbsp)S\(country.currencySymbol)\(String.nbsp)"
  } else if country.currencySymbol == "kr" || country.currencySymbol == "Fr" {
    // Kroner projects use the currency code prefix
    return "\(String.nbsp)\(country.currencyCode)\(String.nbsp)"
  } else {
    // Everything else uses the country code prefix.
    return "\(String.nbsp)\(country.countryCode)\(country.currencySymbol)\(String.nbsp)"
  }
}

/// Returns a signal producer that emits, every second, the number of days/hours/minutes/seconds until
/// a date is reached, at which point it completes.
///
/// - parameter untilDate: The date to countdown to.
///
/// - returns: A signal producer.
public func countdownProducer(to date: Date)
  -> SignalProducer<(day: String, hour: String, minute: String, second: String), Never> {
  func formattedComponents(dateComponents: DateComponents)
    -> (day: String, hour: String, minute: String, second: String) {
    return (
      day: String(format: "%02d", max(0, dateComponents.day ?? 0)),
      hour: String(format: "%02d", max(0, dateComponents.hour ?? 0)),
      minute: String(format: "%02d", max(0, dateComponents.minute ?? 0)),
      second: String(format: "%02d", max(0, dateComponents.second ?? 0))
    )
  }

  let now = AppEnvironment.current.scheduler.currentDate
  let timeUntilNextRoundSecond = ceil(now.timeIntervalSince1970) - now.timeIntervalSince1970

  // A timer that emits every second, but with a small delay so that it emits on a roundeded second.
  let everySecond = SignalProducer<(), Never>(value: ())
    .ksr_delay(.milliseconds(Int(timeUntilNextRoundSecond * 1_000)), on: AppEnvironment.current.scheduler)
    .flatMap { SignalProducer.timer(interval: .seconds(1), on: AppEnvironment.current.scheduler) }

  return SignalProducer.merge(
    SignalProducer<Date, Never>(value: now),
    everySecond
  )
  .map { currentDate in
    AppEnvironment.current.calendar.dateComponents(
      [.day, .hour, .minute, .second],
      from: currentDate,
      to: Date(timeIntervalSince1970: ceil(date.timeIntervalSince1970))
    )
  }
  .take(while: { ($0.second ?? 0) >= 0 })
  .map(formattedComponents(dateComponents:))
}

public func updatedUserWithClearedActivityCountProducer() -> SignalProducer<User, Never> {
  return AppEnvironment.current.apiService.clearUserUnseenActivity(input: .init())
    .filter { _ in AppEnvironment.current.currentUser != nil }
    .map { $0.activityIndicatorCount }
    .map { count in AppEnvironment.current.currentUser ?|> User.lens.unseenActivityCount .~ count }
    .skipNil()
    .demoteErrors()
}

public func defaultShippingRule(fromShippingRules shippingRules: [ShippingRule]) -> ShippingRule? {
  let shippingRuleFromCurrentLocation = shippingRules
    .filter { shippingRule in shippingRule.location.country == AppEnvironment.current.config?.countryCode }
    .first

  if let shippingRuleFromCurrentLocation = shippingRuleFromCurrentLocation {
    return shippingRuleFromCurrentLocation
  }

  let shippingRuleInUSA = shippingRules
    .filter { shippingRule in shippingRule.location.country == "US" }
    .first

  return shippingRuleInUSA ?? shippingRules.first
}

public func formattedAmountForRewardOrBacking(
  project: Project,
  rewardOrBacking: Either<Reward, Backing>
) -> String {
  switch rewardOrBacking {
  case let .left(reward):
    let min = minPledgeAmount(forProject: project, reward: reward)
    return Format.currency(
      min,
      country: project.country,
      omitCurrencyCode: project.stats.omitUSCurrencyCode
    )
  case let .right(backing):
    return Format.formattedCurrency(
      backing.amount,
      country: project.country,
      omitCurrencyCode: project.stats.omitUSCurrencyCode
    )
  }
}

internal func classNameWithoutModule(_ class: AnyClass) -> String {
  return `class`
    .description()
    .components(separatedBy: ".")
    .dropFirst()
    .joined(separator: ".")
}

internal func deviceIdentifier(uuid: UUIDType, env: Environment = AppEnvironment.current) -> String {
  guard let identifier = env.device.identifierForVendor else {
    return uuid.uuidString
  }

  return identifier.uuidString
}

typealias SanitizedPledgeParams = (pledgeTotal: String, rewardId: String, locationId: String?)

internal func sanitizedPledgeParameters(
  from reward: Reward,
  pledgeAmount: Double,
  shippingRule: ShippingRule?
) -> SanitizedPledgeParams {
  var pledgeTotal = pledgeAmount
  var shippingLocationId: String?

  if let shippingRule = shippingRule {
    pledgeTotal = pledgeAmount.addingCurrency(shippingRule.cost)
    shippingLocationId = String(shippingRule.location.id)
  }

  let formattedPledgeTotal = Format.decimalCurrency(for: pledgeTotal)
  let rewardId = reward.graphID

  return (formattedPledgeTotal, rewardId, shippingLocationId)
}
