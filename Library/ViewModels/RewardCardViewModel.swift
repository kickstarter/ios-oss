import KsApi
import Prelude
import ReactiveSwift

public protocol RewardCardViewModelInputs {
  func configureWith(project: Project, rewardOrBacking: Either<Reward, Backing>)
  func rewardCardTapped()
}

public protocol RewardCardViewModelOutputs {
  var cardUserInteractionIsEnabled: Signal<Bool, Never> { get }
  var conversionLabelHidden: Signal<Bool, Never> { get }
  var conversionLabelText: Signal<String, Never> { get }
  var descriptionLabelText: Signal<String, Never> { get }
  var estimatedDeliveryDateLabelHidden: Signal<Bool, Never> { get }
  var estimatedDeliveryDateLabelText: Signal<String, Never> { get }
  var includedItemsStackViewHidden: Signal<Bool, Never> { get }
  var items: Signal<[String], Never> { get }
  var pillCollectionViewHidden: Signal<Bool, Never> { get }
  var reloadPills: Signal<[String], Never> { get }
  var rewardMinimumLabelText: Signal<String, Never> { get }
  var rewardSelected: Signal<Int, Never> { get }
  var rewardTitleLabelHidden: Signal<Bool, Never> { get }
  var rewardTitleLabelText: Signal<String, Never> { get }
}

public protocol RewardCardViewModelType {
  var inputs: RewardCardViewModelInputs { get }
  var outputs: RewardCardViewModelOutputs { get }
}

public final class RewardCardViewModel: RewardCardViewModelType, RewardCardViewModelInputs,
  RewardCardViewModelOutputs {
  public init() {
    let projectAndRewardOrBacking: Signal<(Project, Either<Reward, Backing>), Never> =
      self.projectAndRewardOrBackingProperty.signal
        .skipNil()
        .map { ($0.0, $0.1) }

    let project: Signal<Project, Never> = projectAndRewardOrBacking.map(first)

    let reward: Signal<Reward, Never> = projectAndRewardOrBacking
      .map { project, rewardOrBacking -> Reward in
        rewardOrBacking.left
          ?? rewardOrBacking.right?.reward
          ?? backingReward(fromProject: project)
          ?? Reward.noReward
      }

    let projectAndReward = Signal.zip(project, reward)

    self.conversionLabelHidden = project.map(needsConversion(project:) >>> negate)
    /* The conversion logic here is currently the same as what we already have, but note that
     this will likely change to make rounding more consistent
     */
    self.conversionLabelText = projectAndRewardOrBacking
      .filter(first >>> needsConversion(project:))
      .map { project, rewardOrBacking in
        let (country, rate) = zip(
          project.stats.currentCountry,
          project.stats.currentCurrencyRate
        ) ?? (.us, project.stats.staticUsdRate)
        switch rewardOrBacking {
        case let .left(reward):
          return Format.currency(
            reward.convertedMinimum,
            country: country,
            omitCurrencyCode: project.stats.omitUSCurrencyCode
          )
        case let .right(backing):
          return Format.currency(
            Int(ceil(Float(backing.amount) * rate)),
            country: country,
            omitCurrencyCode: project.stats.omitUSCurrencyCode
          )
        }
      }
      .map(Strings.About_reward_amount(reward_amount:))

    self.rewardMinimumLabelText = projectAndRewardOrBacking
      .map(formattedAmountForRewardOrBacking(project:rewardOrBacking:))

    self.descriptionLabelText = projectAndReward
      .map(localizedDescription(project:reward:))

    self.rewardTitleLabelHidden = reward
      .map { $0.title == nil && !$0.isNoReward }

    self.rewardTitleLabelText = projectAndReward
      .map(rewardTitle(project:reward:))

    let rewardItemsIsEmpty = reward
      .map { $0.rewardsItems.isEmpty }

    let rewardAvailable = reward
      .map { $0.remaining == 0 }.negate()

    self.includedItemsStackViewHidden = rewardItemsIsEmpty.skipRepeats()

    self.items = reward
      .map { reward in
        reward.rewardsItems.map { rewardsItem in
          rewardsItem.quantity > 1
            ? "(\(Format.wholeNumber(rewardsItem.quantity))) \(rewardsItem.item.name)"
            : rewardsItem.item.name
        }
      }

    self.reloadPills = projectAndReward.map(pillValues(project:reward:))
    self.pillCollectionViewHidden = self.reloadPills.map { $0.isEmpty }

    self.rewardSelected = reward
      .takeWhen(self.rewardCardTappedProperty.signal)
      .map { $0.id }

    self.cardUserInteractionIsEnabled = rewardAvailable

    self.estimatedDeliveryDateLabelHidden = reward.map { $0.estimatedDeliveryOn }.map(isNil)
    self.estimatedDeliveryDateLabelText = reward.map(estimatedDeliveryText(with:)).skipNil()
  }

  private let projectAndRewardOrBackingProperty = MutableProperty<(Project, Either<Reward, Backing>)?>(nil)
  public func configureWith(project: Project, rewardOrBacking: Either<Reward, Backing>) {
    self.projectAndRewardOrBackingProperty.value = (project, rewardOrBacking)
  }

  private let rewardCardTappedProperty = MutableProperty(())
  public func rewardCardTapped() {
    self.rewardCardTappedProperty.value = ()
  }

  public let cardUserInteractionIsEnabled: Signal<Bool, Never>
  public let conversionLabelHidden: Signal<Bool, Never>
  public let conversionLabelText: Signal<String, Never>
  public let descriptionLabelText: Signal<String, Never>
  public let estimatedDeliveryDateLabelHidden: Signal<Bool, Never>
  public let estimatedDeliveryDateLabelText: Signal<String, Never>
  public let items: Signal<[String], Never>
  public let includedItemsStackViewHidden: Signal<Bool, Never>
  public let pillCollectionViewHidden: Signal<Bool, Never>
  public let reloadPills: Signal<[String], Never>
  public let rewardMinimumLabelText: Signal<String, Never>
  public let rewardSelected: Signal<Int, Never>
  public let rewardTitleLabelHidden: Signal<Bool, Never>
  public let rewardTitleLabelText: Signal<String, Never>

  public var inputs: RewardCardViewModelInputs { return self }
  public var outputs: RewardCardViewModelOutputs { return self }
}

// MARK: - Private Helpers

private func needsConversion(project: Project) -> Bool {
  return project.stats.needsConversion
}

private func backingReward(fromProject project: Project) -> Reward? {
  guard let backing = project.personalization.backing else {
    return nil
  }

  return project.rewards
    .filter { $0.id == backing.rewardId || $0.id == backing.reward?.id }
    .first
    .coalesceWith(.noReward)
}

private func localizedDescription(project: Project, reward: Reward) -> String {
  guard project.personalization.isBacking == true else {
    return reward.isNoReward ? Strings.Back_it_because_you_believe_in_it() : reward.description
  }

  if reward.isNoReward {
    return userIsBacking(reward: reward, inProject: project)
      ? Strings.Thanks_for_bringing_this_project_one_step_closer_to_becoming_a_reality()
      : Strings.Back_it_because_you_believe_in_it()
  }

  return reward.description
}

private func rewardTitle(project: Project, reward: Reward) -> String {
  guard project.personalization.isBacking == true else {
    return reward.isNoReward ? Strings.Pledge_without_a_reward() : reward.title.coalesceWith("")
  }

  if reward.isNoReward {
    return userIsBacking(reward: reward, inProject: project)
      ? Strings.You_pledged_without_a_reward() : Strings.Pledge_without_a_reward()
  }

  return reward.title.coalesceWith("")
}

private func pillValues(project: Project, reward: Reward) -> [String] {
  return [
    timeLeftString(project: project, reward: reward),
    backerCountOrRemainingString(project: project, reward: reward),
    shippingSummaryString(project: project, reward: reward)
  ]
  .compact()
}

private func timeLeftString(project: Project, reward: Reward) -> String? {
  let isUnlimitedOrAvailable = reward.limit == nil || reward.remaining ?? 0 > 0

  if project.state == .live,
    let endsAt = reward.endsAt,
    endsAt > 0,
    endsAt >= AppEnvironment.current.dateType.init().timeIntervalSince1970,
    isUnlimitedOrAvailable {
    let (time, unit) = Format.duration(
      secondsInUTC: min(endsAt, project.dates.deadline),
      abbreviate: true,
      useToGo: false
    )

    return Strings.Time_left_left(time_left: time + " " + unit)
  }

  return nil
}

private func backerCountOrRemainingString(project: Project, reward: Reward) -> String? {
  guard
    let limit = reward.limit,
    let remaining = reward.remaining,
    remaining > 0,
    project.state == .live
  else {
    let backersCount = reward.backersCount ?? 0

    return backersCount > 0
      ? Strings.general_backer_count_backers(backer_count: backersCount)
      : nil
  }

  return Strings.remaining_count_left_of_limit_count(
    remaining_count: "\(remaining)",
    limit_count: "\(limit)"
  )
}

private func shippingSummaryString(project: Project, reward: Reward) -> String? {
  if project.state == .live, reward.shipping.enabled, let type = reward.shipping.type {
    switch type {
    case .anywhere:
      return Strings.Ships_worldwide()
    case .multipleLocations:
      return Strings.Limited_shipping()
    case .noShipping: return nil
    case .singleLocation:
      if let name = reward.shipping.location?.localizedName {
        return Strings.location_name_only(location_name: name)
      }

      return nil
    }
  }

  return nil
}

private func estimatedDeliveryText(with reward: Reward) -> String? {
  return reward.estimatedDeliveryOn.map {
    Strings.backing_info_estimated_delivery_date(
      delivery_date: Format.date(
        secondsInUTC: $0,
        template: DateFormatter.monthYear,
        timeZone: UTCTimeZone
      )
    )
  }
}
