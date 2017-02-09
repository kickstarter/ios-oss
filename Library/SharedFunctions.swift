import KsApi
import LiveStream
import Prelude
import ReactiveSwift
import Result

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
internal func minAndMaxPledgeAmount(forProject project: Project, reward: Reward?) -> (min: Int, max: Int) {

  // The country on the project cannot be trusted to have the min/max values, so first try looking
  // up the country in our launched countries array that we get back from the server config.
  let country = AppEnvironment.current.launchedCountries.countries
    .filter { $0 == project.country }
    .first
    .coalesceWith(project.country)

  switch reward {
  case .none, .some(Reward.noReward):
    return (country.minPledge ?? 1, country.maxPledge ?? 10_000)
  case let .some(reward):
    return (reward.minimum, country.maxPledge ?? 10_000)
  }
}

/**
 Computes the minimum amount needed to pledge to a reward. For the "no reward" reward,
 this looks up values in the table of launched countries, since the values depend on the currency.

 - parameter project: A project.
 - parameter reward:  A reward.

 - returns: The minimum amount needed to pledge to the reward.
 */
internal func minPledgeAmount(forProject project: Project, reward: Reward?) -> Int {

  return minAndMaxPledgeAmount(forProject: project, reward: reward).min
}

/**
 Returns the full currency symbol for a country. Special logic is added around prefixing currency symbols
 with country/currency codes based on a variety of factors.

 - parameter country: The country.

 - returns: The currency symbol that can be used for currency display.
 */
public func currencySymbol(forCountry country: Project.Country) -> String {

  guard AppEnvironment.current.launchedCountries.currencyNeedsCode(country.currencySymbol) else {
    // Currencies that dont have ambigious currencies can just use their symbol.
    return country.currencySymbol
  }

  if country == .US && AppEnvironment.current.countryCode == "US" {
    // US people looking at US projects just get the currency symbol
    return country.currencySymbol
  } else if country == .SG {
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
  -> SignalProducer<(day: String, hour: String, minute: String, second: String), NoError> {

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
    let everySecond = SignalProducer<(), NoError>(value: ())
      .ksr_delay(.milliseconds(Int(timeUntilNextRoundSecond * 1000)), on: AppEnvironment.current.scheduler)
      .flatMap { timer(interval: .seconds(1), on: AppEnvironment.current.scheduler) }

    return SignalProducer.merge(
      SignalProducer<Date, NoError>(value: now),
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
