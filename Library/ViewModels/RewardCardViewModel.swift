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
  var includedItemsStackViewHidden: Signal<Bool, Never> { get }
  var items: Signal<[String], Never> { get }
  var pillCollectionViewHidden: Signal<Bool, Never> { get }
  var reloadPills: Signal<[String], Never> { get }
  var rewardMinimumLabelText: Signal<String, Never> { get }
  var rewardSelected: Signal<Int, Never> { get }
  var rewardTitleLabelHidden: Signal<Bool, Never> { get }
  var rewardTitleLabelText: Signal<String, Never> { get }
  var stateIconImageName: Signal<String, Never> { get }
  var stateIconImageTintColor: Signal<UIColor, Never> { get }
  var stateIconImageViewContainerBackgroundColor: Signal<UIColor, Never> { get }
  var stateIconImageViewContainerHidden: Signal<Bool, Never> { get }
}

public protocol RewardCardViewModelType {
  var inputs: RewardCardViewModelInputs { get }
  var outputs: RewardCardViewModelOutputs { get }
}

public final class RewardCardViewModel: RewardCardViewModelType, RewardCardViewModelInputs,
  RewardCardViewModelOutputs {
  public init() {
    let projectAndRewardOrBacking: Signal<(Project, Either<Reward, Backing>), Never> =
      self.projectAndRewardOrBackingProperty.signal.skipNil()

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
          let min = minPledgeAmount(forProject: project, reward: reward)
          return Format.currency(
            max(1, Int(Float(min) * rate)),
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

    self.descriptionLabelText = reward
      .map { $0.isNoReward ? Strings.Pledge_any_amount_to_help_bring_this_project_to_life() : $0.description }

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

    self.reloadPills = projectAndReward.map(pillStrings(project:reward:))
    self.pillCollectionViewHidden = self.reloadPills.map { $0.isEmpty }

    let stateIconImageName = projectAndReward.map(stateIconImageName(project:reward:))
    let stateIconImageColor = projectAndReward.map(stateIconImageColor(project:reward:))

    self.stateIconImageName = stateIconImageName.skipNil()
    self.stateIconImageTintColor = stateIconImageColor.skipNil()
    self.stateIconImageViewContainerBackgroundColor = stateIconImageColor
      .skipNil()
      .map { $0.withAlphaComponent(0.06) }
    self.stateIconImageViewContainerHidden = stateIconImageName.map(isNil)

    self.rewardSelected = reward
      .takeWhen(self.rewardCardTappedProperty.signal)
      .map { $0.id }

    self.cardUserInteractionIsEnabled = rewardAvailable
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
  public let items: Signal<[String], Never>
  public let includedItemsStackViewHidden: Signal<Bool, Never>
  public let pillCollectionViewHidden: Signal<Bool, Never>
  public let reloadPills: Signal<[String], Never>
  public let rewardMinimumLabelText: Signal<String, Never>
  public let rewardSelected: Signal<Int, Never>
  public let rewardTitleLabelHidden: Signal<Bool, Never>
  public let rewardTitleLabelText: Signal<String, Never>
  public let stateIconImageName: Signal<String, Never>
  public let stateIconImageTintColor: Signal<UIColor, Never>
  public let stateIconImageViewContainerBackgroundColor: Signal<UIColor, Never>
  public let stateIconImageViewContainerHidden: Signal<Bool, Never>

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

private func rewardTitle(project: Project, reward: Reward) -> String {
  guard project.personalization.isBacking == true else {
    return reward.isNoReward ? Strings.Make_a_pledge_without_a_reward() : reward.title.coalesceWith("")
  }

  if reward.isNoReward {
    if userIsBacking(reward: reward, inProject: project) {
      return Strings.Thank_you_for_supporting_this_project()
    }

    return Strings.Make_a_pledge_without_a_reward()
  }

  return reward.title.coalesceWith("")
}

private func pillStrings(project: Project, reward: Reward) -> [String] {
  var pillStrings: [String] = []

  guard project.state == .live else { return pillStrings }

  if let endsAt = reward.endsAt, endsAt > 0,
    endsAt >= AppEnvironment.current.dateType.init().timeIntervalSince1970 {
    let (time, unit) = Format.duration(
      secondsInUTC: min(endsAt, project.dates.deadline),
      abbreviate: true,
      useToGo: false
    )

    pillStrings.append(Strings.Time_left_left(time_left: time + " " + unit))
  }

  if let remaining = reward.remaining, reward.limit != nil, project.state == .live {
    pillStrings.append(Strings.Left_count_left(left_count: remaining))
  }

  if reward.shipping.enabled, let shippingSummary = reward.shipping.summary {
    pillStrings.append(shippingSummary)
  }

  return pillStrings
}

private func stateIconImageColor(project: Project, reward: Reward) -> UIColor? {
  guard userIsBacking(reward: reward, inProject: project) else { return nil }

  if project.state == .live {
    return project.personalization.backing?.status == .errored ? .ksr_apricot_500 : .ksr_blue_500
  }

  return .ksr_soft_black
}

private func stateIconImageName(project: Project, reward: Reward) -> String? {
  guard userIsBacking(reward: reward, inProject: project) else { return nil }

  return project.personalization.backing?.status == .errored ? "icon--alert" : "checkmark-reward"
}
