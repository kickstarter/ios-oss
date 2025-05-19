import KsApi
import Prelude
import ReactiveSwift
import UIKit
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
  // project currency is more accurate to find the country to base the min/max values off of.
  let projectCurrencyCountry = projectCountry(forCurrency: project.stats.currency) ?? project.country
  let country = AppEnvironment.current.launchedCountries.countries
    .first { $0 == projectCurrencyCountry }
    .coalesceWith(projectCurrencyCountry)

  switch reward {
  case .none, .some(Reward.noReward):
    return (Double(country.minPledge ?? 1), Double(country.maxPledge ?? 10_000))
  case let .some(reward):
    guard let backing = project.personalization.backing else {
      return (reward.minimum, Double(country.maxPledge ?? 10_000))
    }

    let min: Double

    /// Account for the case where the originally selected reward pricing, for this backing, has since changed to late pledge pricing. We should always use the original pricing at the time of the backing over the most current state.
    if backing.isLatePledge == true {
      min = reward.latePledgeAmount > 0 ? reward.latePledgeAmount : reward.minimum
    } else {
      min = reward.pledgeAmount > 0 ? reward.pledgeAmount : reward.minimum
    }

    return (min, Double(country.maxPledge ?? 10_000))
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
 Returns the full currency symbol for a currencyCode. Special logic is added around prefixing currency symbols
 with country/currency codes based on a variety of factors.

 - parameter currencyCode: The currency code.
 - parameter omitCurrencyCode: Safe to omit the US currencyCode
 - parameter env: Current Environment.

 - returns: The currency symbol that can be used for currency display.
 */
public func currencySymbol(
  forCurrencyCode currencyCode: String,
  omitCurrencyCode: Bool = true,
  env: Environment = AppEnvironment.current
) -> String {
  let country = projectCountry(forCurrency: currencyCode, env: env) ?? .us

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

/**
 Returns the full country for a currency code.

 - parameter code: The currency code.
 - parameter env: Current Environment.

 - returns: The first matching country for currency symbol
 */
public func projectCountry(
  forCurrency code: String?,
  env: Environment = AppEnvironment.current
) -> Project.Country? {
  guard let currencyCode = code,
        let country = env.launchedCountries.countries.filter({ $0.currencyCode == currencyCode }).first else {
    return nil
  }
  // return a hardcoded Country if it matches the country code
  return country
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
      currencyCode: project.stats.currency,
      omitCurrencyCode: project.stats.omitUSCurrencyCode
    )
  case let .right(backing):
    return Format.formattedCurrency(
      backing.amount,
      currencyCode: project.stats.currency,
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
  return LegacyColors.ksr_white.uiColor()
}

public func rewardIsAvailable(_ reward: Reward) -> Bool {
  reward.isAvailable == true || reward.isNoReward
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
  let isAvailableForNewBacker = rewardIsAvailable(reward) && !isBacking
  /// Backers should always be able to edit the currently backed reward. It's the only path to update the pledge/bonus amount.
  let isAvailableForExistingBackerToEdit = isBacking

  if featurePostCampaignPledgeEnabled(), project.isInPostCampaignPledgingPhase {
    return [
      project.state == .successful,
      isAvailableForNewBacker
    ]
    .allSatisfy(isTrue)
  }

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
  return reward.startsAt == nil || (reward.startsAt ?? 0) <= AppEnvironment.current.dateType.init()
    .timeIntervalSince1970
}

/**
 Determines if an end date from a given reward/add on is after the current date.

 - parameter reward:           The reward being evaluated

 - returns: A Bool representing whether the reward has an end date after to the current date/time.
 */
public func isEndDateAfterToday(for reward: Reward) -> Bool {
  return reward.endsAt == nil || (reward.endsAt ?? 0) >= AppEnvironment.current.dateType.init()
    .timeIntervalSince1970
}

/*
 A helper that assists in rounding a Double to a given number of decimal places
 */
public func rounded(_ value: Double, places: Int16) -> Decimal {
  let roundingBehavior = NSDecimalNumberHandler(
    roundingMode: .bankers,
    scale: places,
    raiseOnExactness: true,
    raiseOnOverflow: true,
    raiseOnUnderflow: true,
    raiseOnDivideByZero: true
  )

  return NSDecimalNumber(value: value).rounding(accordingToBehavior: roundingBehavior) as Decimal
}

/*
 A helper that assists in rounding a Float to a given number of decimal places
 */
public func rounded(_ value: Float, places: Int16) -> Decimal {
  let roundingBehavior = NSDecimalNumberHandler(
    roundingMode: .bankers,
    scale: places,
    raiseOnExactness: true,
    raiseOnOverflow: true,
    raiseOnUnderflow: true,
    raiseOnDivideByZero: true
  )

  return NSDecimalNumber(value: value).rounding(accordingToBehavior: roundingBehavior) as Decimal
}

/**
 An helper func that calculates  shipping total for base reward

 - parameter project: The `Project` associated with a group of Rewards.
 - parameter baseReward: The reward being evaluated
 - parameter shippingRule: `ShippingRule` information about shipping details of selected rewards.

 - returns: A `Double` of the shipping value. If the `Project` `Backing` object is nil,
            and `baseReward` shipping is not enabled, the value is `0.0`
 */
public func getBaseRewardShippingTotal(
  project: Project,
  baseReward: Reward,
  shippingRule: ShippingRule?
) -> Double {
  // If digital or local pickup there is no shipping
  guard !isRewardDigital(baseReward),
        !isRewardLocalPickup(baseReward),
        baseReward != .noReward else { return 0.0 }
  let backing = project.personalization.backing

  // If there is no `Backing` (new pledge), return the rewards shipping rule
  return backing.isNil ?
    baseReward.shippingRule(matching: shippingRule)?.cost ?? 0.0 :
    backing?.shippingAmount.flatMap(Double.init) ?? 0.0
}

/**
 An helper func that calculates  shipping total for base reward

 -  parameter shippingRule: `ShippingRule` information about shipping details of selected rewards.
 - parameter addOnRewards: An array of `Reward` objects representing the available add-ons.
 - parameter quantities: A dictionary that aggregates the quantity of selected add-ons.

 - returns: A `Double` of the shipping value.
 */
func calculateShippingTotal(
  shippingRule: ShippingRule,
  addOnRewards: [Reward],
  quantities: SelectedRewardQuantities
) -> Double {
  let calculatedShippingTotal = addOnRewards.reduce(0.0) { total, reward in
    guard !isRewardDigital(reward), !isRewardLocalPickup(reward), reward != .noReward else { return total }

    let shippingCostForReward = reward.shippingRule(matching: shippingRule)?.cost ?? 0

    let totalShippingForReward = shippingCostForReward
      .multiplyingCurrency(Double(quantities[reward.id] ?? 0))

    return total.addingCurrency(totalShippingForReward)
  }

  return calculatedShippingTotal
}

/**
 An helper func that calculates  pledge total for all rewards

 - parameter pledgeAmount: The amount pledged for a project.
 - parameter shippingCost: The shipping cost for the pledge.
 - parameter addOnRewardsTotal: The total amount of all addOn rewards.

 - returns: A `Double` of the pledge value.
 */
func calculatePledgeTotal(
  pledgeAmount: Double,
  shippingCost: Double,
  addOnRewardsTotal: Double
) -> Double {
  let r = [pledgeAmount, shippingCost, addOnRewardsTotal].reduce(0) { accum, amount in
    accum.addingCurrency(amount)
  }

  return r
}

/**
 Indicates whether a pledge is being made with a "no reward" `Reward`.

 - parameter reward: A `Rewards` array associated with the current pledge.

 - returns: A `Bool` for if the selected reward is a "non reward" type
 */

public func pledgeHasNoRewards(rewards: [Reward]) -> Bool {
  rewards.count == 1 && rewards.first?.isNoReward == true
}

/**
 An helper func that calculates  pledge total for all rewards

 - parameter addOnRewards: The `Project` associated with a group of Rewards.
 - parameter selectedQuantities: A dictionary that aggregates the quantity of selected add-ons.

 - returns: A `Double` of all rewards add-ons total.
 */
func calculateAllRewardsTotal(
  addOnRewards: [Reward],
  selectedQuantities: SelectedRewardQuantities
) -> Double {
  addOnRewards.filter { !$0.isNoReward }
    .reduce(0.0) { total, reward -> Double in
      let totalForReward = reward.minimum
        .multiplyingCurrency(Double(selectedQuantities[reward.id] ?? 0))

      return total.addingCurrency(totalForReward)
    }
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
  checkoutId: String? = nil,
  isApplePay: Bool?
) -> KSRAnalytics.CheckoutPropertiesData {
  let staticUsdRate = Double(project.stats.staticUsdRate)

  // Two decimal places to represent cent values
  let pledgeTotalUsd = rounded(pledgeTotal.multiplyingCurrency(staticUsdRate), places: 2)

  let bonusAmountUsd = rounded(additionalPledgeAmount.multiplyingCurrency(staticUsdRate), places: 2)

  let addOnRewards = addOnRewards
    .filter { reward in reward.id != baseReward.id }
    .map { reward -> [Reward] in
      guard let selectedRewardQuantity = selectedQuantities[reward.id] else { return [] }
      return Array(0..<selectedRewardQuantity).map { _ in reward }
    }
    .flatMap { $0 }

  let addOnsCountTotal = addOnRewards.map(\.id).count
  let addOnsCountUnique = Set(addOnRewards.map(\.id)).count
  let addOnsMinimumUsd = addOnRewards
    .reduce(0.0) { accum, addOn in accum.addingCurrency(addOn.minimum) }
    .multiplyingCurrency(staticUsdRate)

  let shippingAmount: Double? = baseReward.shipping.enabled ? shippingTotal : nil

  let rewardId = String(baseReward.id)
  let estimatedDelivery = baseReward.estimatedDeliveryOn

  var paymentType: String?
  if let isApplePay = isApplePay {
    paymentType = isApplePay
      ? PaymentType.applePay.trackingString
      : PaymentType.creditCard.trackingString
  }

  let rewardTitle = baseReward.title
  let rewardMinimumUsd = rounded(baseReward.minimum.multiplyingCurrency(staticUsdRate), places: 2)
  let shippingEnabled = baseReward.shipping.enabled
  let shippingAmountUsd = shippingAmount?.multiplyingCurrency(staticUsdRate)

  let userHasEligibleStoredApplePayCard = AppEnvironment.current
    .applePayCapabilities
    .applePayCapable(for: project)

  return KSRAnalytics.CheckoutPropertiesData(
    addOnsCountTotal: addOnsCountTotal,
    addOnsCountUnique: addOnsCountUnique,
    addOnsMinimumUsd: addOnsMinimumUsd,
    bonusAmountInUsd: bonusAmountUsd,
    checkoutId: checkoutId,
    estimatedDelivery: estimatedDelivery,
    paymentType: paymentType,
    revenueInUsd: pledgeTotalUsd,
    rewardId: rewardId,
    rewardMinimumUsd: rewardMinimumUsd,
    rewardTitle: rewardTitle,
    shippingEnabled: shippingEnabled,
    shippingAmountUsd: shippingAmountUsd,
    userHasStoredApplePayCard: userHasEligibleStoredApplePayCard
  )
}

/**
 Indicates `Reward` is locally picked up/not.

 - parameter reward: A `Reward` object

 - returns: A `Bool` for if a reward is locally picked up/not
 */

public func isRewardLocalPickup(_ reward: Reward?) -> Bool {
  guard let existingReward = reward else {
    return false
  }

  return !existingReward.shipping.enabled &&
    existingReward.localPickup != nil &&
    existingReward.shipping
    .preference.isAny(of: Reward.Shipping.Preference.local)
}

/**
 Indicates `Reward` is digital or not.

 - parameter reward: A `Reward` object

 - returns: A `Bool` for if a reward is digital or not
 */

public func isRewardDigital(_ reward: Reward?) -> Bool {
  guard let existingReward = reward else {
    return false
  }

  return !existingReward.shipping.enabled &&
    existingReward.shipping.preference
    .isAny(of: Reward.Shipping.Preference.none)
}

public func estimatedShippingText(
  for rewards: [Reward],
  project: Project,
  locationId: Int,
  selectedQuantities: SelectedRewardQuantities? = nil
) -> String? {
  guard project.stats.needsConversion == false else {
    return estimatedShippingConversionText(for: rewards, project: project, locationId: locationId)
  }

  let (estimatedMin, estimatedMax) = estimatedMinMax(
    from: rewards,
    locationId: locationId,
    selectedQuantities: selectedQuantities
  )

  guard estimatedMin > 0, estimatedMax > 0 else { return nil }

  let projectCurrency = project.stats.currency

  let formattedMin = Format.currency(
    estimatedMin,
    currencyCode: projectCurrency,
    omitCurrencyCode: project.stats.omitUSCurrencyCode,
    roundingMode: .halfUp
  )

  let formattedMax = Format.currency(
    estimatedMax,
    currencyCode: projectCurrency,
    omitCurrencyCode: project.stats.omitUSCurrencyCode,
    roundingMode: .halfUp
  )

  let estimatedShippingString: String = formattedMin == formattedMax
    ? "\(formattedMin)"
    : "\(formattedMin)-\(formattedMax)"

  return estimatedShippingString
}

public func estimatedShippingConversionText(
  for rewards: [Reward],
  project: Project,
  locationId: Int,
  selectedQuantities: SelectedRewardQuantities? = nil
) -> String? {
  guard project.stats.needsConversion else { return nil }

  let (estimatedMin, estimatedMax) = estimatedMinMax(
    from: rewards,
    locationId: locationId,
    selectedQuantities: selectedQuantities
  )

  guard estimatedMin > 0, estimatedMax > 0 else { return nil }

  let convertedMin = estimatedMin * Double(project.stats.currentCurrencyRate ?? project.stats.staticUsdRate)
  let convertedMax = estimatedMax * Double(project.stats.currentCurrencyRate ?? project.stats.staticUsdRate)
  let currencyCode = project.stats.currency

  let formattedMin = Format.currency(
    convertedMin,
    currencyCode: currencyCode,
    omitCurrencyCode: project.stats.omitUSCurrencyCode,
    roundingMode: .halfUp
  )

  let formattedMax = Format.currency(
    convertedMax,
    currencyCode: currencyCode,
    omitCurrencyCode: project.stats.omitUSCurrencyCode,
    roundingMode: .halfUp
  )

  let conversionText: String = formattedMin == formattedMax
    ? Strings.About_reward_amount(reward_amount: formattedMin)
    : Strings.About_reward_amount(reward_amount: "\(formattedMin)-\(formattedMax)")

  return conversionText
}

public func attributedCurrency(withProject project: Project, total: Double) -> NSAttributedString? {
  let defaultAttributes = checkoutCurrencyDefaultAttributes()
    .withAllValuesFrom([.foregroundColor: LegacyColors.ksr_support_700])
  let currencyCode = project.statsCurrency

  return Format.attributedCurrency(
    total,
    currencyCode: currencyCode,
    omitCurrencyCode: project.stats.omitUSCurrencyCode,
    defaultAttributes: defaultAttributes,
    superscriptAttributes: checkoutCurrencySuperscriptAttributes()
  )
}

private func estimatedMinMax(
  from rewards: [Reward],
  locationId: Int,
  selectedQuantities: SelectedRewardQuantities?
) -> (Double, Double) {
  var min: Double = 0
  var max: Double = 0

  rewards.forEach { reward in
    guard reward.shipping.enabled,
          let shippingRules = reward.shippingRulesExpanded ?? reward.shippingRules else { return }

    var shipping: ShippingRule? = shippingRules.first(where: { $0.location.id == locationId })

    if shipping == nil && reward.shipping.preference == .unrestricted {
      shipping = shippingRules.first
    }

    /// Verify there are estimated amounts greater than 0
    guard let estimatedMin = shipping?.estimatedMin?.amount,
          let estimatedMax = shipping?.estimatedMax?.amount,
          estimatedMin > 0 || estimatedMax > 0 else {
      return
    }

    min += estimatedMin * Double(selectedQuantities?[reward.id] ?? 1)
    max += estimatedMax * Double(selectedQuantities?[reward.id] ?? 1)
  }

  return (min, max)
}

/**
 Determines the section header height for the pledge summary table view in our checkout screens..

 - parameter sectionIdentifier: A `PledgeRewardsSummarySection?` object

 - returns: A `CGFloat` for setting the height of the given section.
 */

public func heightForHeaderInPledgeSummarySection(sectionIdentifier: PledgeRewardsSummarySection?)
  -> CGFloat {
  guard let section = sectionIdentifier else {
    return UITableView.automaticDimension
  }

  /// Hides the first section header because we're using our own custom UITableCell.
  let shouldHideSectionHeader = section == .header || section == .shipping || section == .bonusSupport
  return shouldHideSectionHeader ? 0 : UITableView.automaticDimension
}
