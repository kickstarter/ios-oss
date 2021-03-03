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
 Determines if the personalization data in the project implies that the current user is backing the
 project passed in.

 - parameter project: A project.

 - returns: A boolean.
 */
internal func userIsBackingProject(_ project: Project) -> Bool {
  return project.personalization.backing != nil || project.personalization.isBacking == .some(true)
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
  if let backingReward = backing.reward {
    return backingReward
  }

  guard let rewardId = backing.rewardId else { return Reward.noReward }

  return reward(withId: rewardId, inProject: project)
}

/**
 Returns a reward for a backing ID in a given project

 - parameter backing: A backing ID
 - parameter project: A project

 - returns: A reward
 */

internal func reward(withId rewardId: Int, inProject project: Project) -> Reward {
  let noRewardFromProject = project.rewards.first { $0.id == Reward.noReward.id }

  return project.rewards.first { $0.id == rewardId }
    ?? noRewardFromProject
    ?? Reward.noReward
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
    .first { $0 == project.country }
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
    .first { shippingRule in shippingRule.location.country == AppEnvironment.current.config?.countryCode }

  if let shippingRuleFromCurrentLocation = shippingRuleFromCurrentLocation {
    return shippingRuleFromCurrentLocation
  }

  let shippingRuleInUSA = shippingRules
    .first { shippingRule in shippingRule.location.country == "US" }

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

public func deviceIdentifier(uuid: UUIDType, env: Environment = AppEnvironment.current) -> String {
  guard let identifier = env.device.identifierForVendor else {
    return uuid.uuidString
  }

  return identifier.uuidString
}

typealias SanitizedPledgeParams = (pledgeTotal: String, rewardIds: [String], locationId: String?)

internal func sanitizedPledgeParameters(
  from rewards: [Reward],
  selectedQuantities: SelectedRewardQuantities,
  pledgeTotal: Double,
  shippingRule: ShippingRule?
) -> SanitizedPledgeParams {
  let shippingLocationId = (shippingRule?.location.id).flatMap(String.init)

  let formattedPledgeTotal = Format.decimalCurrency(for: pledgeTotal)
  let rewardIds = rewards.map { reward -> [String] in
    guard let selectedRewardQuantity = selectedQuantities[reward.id] else { return [] }
    return Array(0..<selectedRewardQuantity).map { _ in reward.graphID }
  }
  .flatMap { $0 }

  return (formattedPledgeTotal, rewardIds, shippingLocationId)
}

public func ksr_pledgeAmount(
  _ pledgeAmount: Double,
  subtractingShippingAmount shippingAmount: Double?
) -> Double {
  guard let shippingAmount = shippingAmount, shippingAmount > 0 else { return pledgeAmount }

  let pledgeAmount = Decimal(pledgeAmount) - Decimal(shippingAmount)

  return (pledgeAmount as NSDecimalNumber).doubleValue
}

public func discoveryPageBackgroundColor() -> UIColor {
  let variant = OptimizelyExperiment.nativeProjectCardsExperimentVariant()

  switch variant {
  case .variant1:
    return UIColor.ksr_support_100
  case .variant2, .control:
    return UIColor.ksr_white
  }
}

public func rewardIsAvailable(project: Project, reward: Reward) -> Bool {
  let isLimited = reward.isLimitedQuantity
  let isTimebased = reward.isLimitedTime

  guard isLimited || isTimebased else { return true }

  let remainingQty = rewardLimitRemainingForBacker(project: project, reward: reward)
  let isRemaining = remainingQty == nil || (remainingQty ?? 0) > 0

  let now = AppEnvironment.current.dateType.init().timeIntervalSince1970
  let endsAt = reward.endsAt.coalesceWith(now)
  let timeLimitNotReached = endsAt > now

  // Limited availability is valid if the reward is limited and remaining > 0 OR this reward is not limited.
  let limitedAvailabilityValid = (isLimited && isRemaining) || !isLimited

  // Timebased availability is valid if the reward is timebased and the time limit has not been reached
  // OR the reward is not timebased.
  let timebasedAvailabilityValid = (isTimebased && timeLimitNotReached) || !isTimebased

  // Both types of availability must be valid in order for this reward to be considered available.
  return limitedAvailabilityValid && timebasedAvailabilityValid
}

public func rewardLimitRemainingForBacker(project: Project, reward: Reward) -> Int? {
  guard let remaining = reward.remaining else {
    return nil
  }

  // If the reward is limited, determine the currently backed quantity.
  var backedQuantity: Int = 0
  if let backing = project.personalization.backing {
    let rewardQuantities = selectedRewardQuantities(in: backing)
    backedQuantity = rewardQuantities[reward.id] ?? 0
  }

  /**
   Remaining limit for the backer is the minimum of the total remaining quantity
   (including what has been backed).

   For example, let `remaining` be 1 and `backedQuantity` be 3:

   `remainingForBacker` will be 4 as the backer as already backed 3, 1 is available.
   */

  return remaining + backedQuantity
}

public func rewardLimitPerBackerRemainingForBacker(project: Project, reward: Reward) -> Int? {
  /// Be sure that there is a `limitPerBacker` set
  guard let limitPerBacker = reward.limitPerBacker else { return nil }

  /**
   If this is not a limited reward, the `limitPerBacker` is remaining when creating/editing a pledge.
   This amount will include any backed quantity as the user is able to edit their pledge.
   */
  guard let remaining = reward.remaining else {
    return limitPerBacker
  }

  // If the reward is limited, determine the currently backed quantity.
  var backedQuantity: Int = 0
  if let backing = project.personalization.backing {
    let rewardQuantities = selectedRewardQuantities(in: backing)
    backedQuantity = rewardQuantities[reward.id] ?? 0
  }

  /**
   Remaining for the backer is the minimum of the total remaining quantity
   (including what has been backed) or `limitPerBacker`.

   For example, let `remaining` be 1, `limitPerBacker` be 5 and `backedQuantity` be 3:

   `remainingForBacker` will be 4 as the backer as already backed 3, 1 is available and this amount is less
   than `limitPerBacker`.
   */

  let remainingPlusBacked = remaining + backedQuantity

  return min(remainingPlusBacked, limitPerBacker)
}

public func selectedRewardQuantities(in backing: Backing) -> SelectedRewardQuantities {
  var quantities: [SelectedRewardId: SelectedRewardQuantity] = [:]

  let rewards = [backing.reward].compact() + (backing.addOns ?? [])

  rewards.forEach { reward in
    quantities[reward.id] = (quantities[reward.id] ?? 0) + 1
  }

  return quantities
}

public func rewardsCarouselCanNavigateToReward(_ reward: Reward, in project: Project) -> Bool {
  guard !currentUserIsCreator(of: project) else { return false }

  let isBacking = userIsBacking(reward: reward, inProject: project)
  let isAvailableForNewBacker = rewardIsAvailable(project: project, reward: reward) && !isBacking
  let isAvailableForExistingBackerToEdit = (isBacking && reward.hasAddOns)

  return [
    project.state == .live,
    isAvailableForNewBacker || isAvailableForExistingBackerToEdit
  ]
  .allSatisfy(isTrue)
}

/**
 Determines if a start date from a given reward/add on predates the current date.

 - parameter reward:           The reward being evaluated

 - returns: A Bool representing whether the reward has a start date prior to the current date/time.
 */
public func isStartDateBeforeToday(for reward: Reward) -> Bool {
  return (reward.startsAt == nil || (reward.startsAt ?? 0) <= AppEnvironment.current.dateType.init()
    .timeIntervalSince1970)
}

/**
 Determines if an end date from a given reward/add on is after the current date.

 - parameter reward:           The reward being evaluated

 - returns: A Bool representing whether the reward has an end date after to the current date/time.
 */
public func isEndDateAfterToday(for reward: Reward) -> Bool {
  return (reward.endsAt == nil || (reward.endsAt ?? 0) >= AppEnvironment.current.dateType.init()
    .timeIntervalSince1970)
}

/*
 A helper that assists in rounding an amount to a given number of decimal places
 */
public func rounded(_ value: Double, places: Int) -> Double {
  let divisor = pow(10.0, Double(places))
  return (value * divisor).rounded() / divisor
}

/**
 Creates `CheckoutPropertiesData` to send with our event properties.

 - parameter from: The `Project` associated with the checkout.
 - parameter baseReward: The reward being evaluated
 - parameter addOnRewards: An array of `Reward` objects representing the available add-ons.
 - parameter selectedQuantities: A dictionary of reward id to quantitiy.
 - parameter additionalPledgeAmount: The bonus amount included in the pledge.
 - parameter pledgeTotal: The total amount of the pledge.
 - parameter shippingTotal: The shipping cost for the pledge.
 - parameter checkoutId: The unique ID associated with the checkout.
 - parameter isApplePay: A `Bool` indicating if the pledge was done with Apple pay.

 - returns: A `CheckoutPropertiesData` object required for checkoutProperties.
 */
public func checkoutProperties(
  from project: Project,
  baseReward: Reward,
  addOnRewards: [Reward],
  selectedQuantities: SelectedRewardQuantities,
  additionalPledgeAmount: Double,
  pledgeTotal: Double,
  shippingTotal: Double,
  checkoutId: Int? = nil,
  isApplePay: Bool?
) -> KSRAnalytics.CheckoutPropertiesData {
  let staticUsdRate = Double(project.stats.staticUsdRate)

  // Two decimal places to represent cent values
  let pledgeTotalUsd = rounded(pledgeTotal.multiplyingCurrency(staticUsdRate), places: 2)

  let bonusAmountUsd = additionalPledgeAmount
    .multiplyingCurrency(staticUsdRate)

  let addOnRewards = addOnRewards
    .filter { reward in reward.id != baseReward.id }
    .map { reward -> [Reward] in
      guard let selectedRewardQuantity = selectedQuantities[reward.id] else { return [] }
      return Array(0..<selectedRewardQuantity).map { _ in reward }
    }
    .flatMap { $0 }

  let addOnsCountTotal = addOnRewards.map(\.id).count
  let addOnsCountUnique = Set(addOnRewards.map(\.id)).count
  let addOnsMinimumUsd = Format.decimalCurrency(
    for: addOnRewards
      .reduce(0.0) { accum, addOn in accum.addingCurrency(addOn.minimum) }
      .multiplyingCurrency(staticUsdRate)
  )

  let shippingAmount: Double? = baseReward.shipping.enabled ? shippingTotal : nil

  let amount = Format.decimalCurrency(for: pledgeTotal)

  let bonusAmount = Format.decimalCurrency(for: additionalPledgeAmount)
  let bonusAmountInUsd = Format.decimalCurrency(for: bonusAmountUsd)

  let rewardId = baseReward.id
  let estimatedDelivery = baseReward.estimatedDeliveryOn

  var paymentType: String?
  if let isApplePay = isApplePay {
    paymentType = isApplePay
      ? PaymentType.applePay.rawValue
      : PaymentType.creditCard.rawValue
  }

  let shippingEnabled = baseReward.shipping.enabled
  let shippingAmountUsd = (shippingAmount?.multiplyingCurrency(staticUsdRate))
    .flatMap(Format.decimalCurrency)
  let rewardTitle = baseReward.title
  let rewardMinimumUsd = Format.decimalCurrency(for: baseReward.minimum.multiplyingCurrency(staticUsdRate))

  let userHasEligibleStoredApplePayCard = AppEnvironment.current
    .applePayCapabilities
    .applePayCapable(for: project)

  return KSRAnalytics.CheckoutPropertiesData(
    addOnsCountTotal: addOnsCountTotal,
    addOnsCountUnique: addOnsCountUnique,
    addOnsMinimumUsd: addOnsMinimumUsd,
    amount: amount,
    bonusAmount: bonusAmount,
    bonusAmountInUsd: bonusAmountInUsd,
    checkoutId: checkoutId,
    estimatedDelivery: estimatedDelivery,
    paymentType: paymentType,
    revenueInUsd: pledgeTotalUsd,
    rewardId: rewardId,
    rewardMinimumUsd: rewardMinimumUsd,
    rewardTitle: rewardTitle,
    shippingEnabled: shippingEnabled,
    shippingAmount: shippingAmount,
    shippingAmountUsd: shippingAmountUsd,
    userHasStoredApplePayCard: userHasEligibleStoredApplePayCard
  )
}
