import KsApi
import Prelude
import ReactiveSwift
import Result

public protocol RewardCellViewModelInputs {
  func configureWith(project: Project, rewardOrBacking: Either<Reward, Backing>)
  func pledgeButtonTapped()
}

public protocol RewardCellViewModelOutputs {
  var conversionLabelHidden: Signal<Bool, Never> { get }
  var conversionLabelText: Signal<String, Never> { get }
  var descriptionStackViewHidden: Signal<Bool, Never> { get }
  var descriptionLabelText: Signal<String, Never> { get }
  var items: Signal<[String], Never> { get }
  var includedItemsStackViewHidden: Signal<Bool, Never> { get }
  var pledgeButtonEnabled: Signal<Bool, Never> { get }
  var pledgeButtonTitleText: Signal<String, Never> { get }
  var rewardMinimumLabelText: Signal<String, Never> { get }
  var rewardSelected: Signal<Int, Never> { get }
  var rewardTitleLabelHidden: Signal<Bool, Never> { get }
  var rewardTitleLabelText: Signal<String, Never> { get }
}

public protocol RewardCellViewModelType {
  var inputs: RewardCellViewModelInputs { get }
  var outputs: RewardCellViewModelOutputs { get }
}

public final class RewardCellViewModel: RewardCellViewModelType, RewardCellViewModelInputs,
RewardCellViewModelOutputs {

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
          return Format.currency(max(1, Int(Float(min) * rate)),
                                 country: country,
                                 omitCurrencyCode: project.stats.omitUSCurrencyCode)
        case let .right(backing):
          return Format.currency(Int(ceil(Float(backing.amount) * rate)),
                                 country: country,
                                 omitCurrencyCode: project.stats.omitUSCurrencyCode)
        }
      }
      .map(Strings.About_reward_amount(reward_amount:))

    self.rewardMinimumLabelText = projectAndRewardOrBacking
      .map { project, rewardOrBacking in
        switch rewardOrBacking {
        case let .left(reward):
          let minimumFormattedAmount = formattedAmountForRewardOrBacking(project: project, rewardOrBacking: rewardOrBacking)

          return reward == Reward.noReward
            ? Strings.rewards_title_pledge_reward_currency_or_more(reward_currency: minimumFormattedAmount)
            : minimumFormattedAmount

        case let .right(backing):
          return formattedAmountForRewardOrBacking(project: project, rewardOrBacking: rewardOrBacking)
        }
    }

    self.descriptionLabelText = reward
      .map { $0 == Reward.noReward ? "" : $0.description }

    self.rewardTitleLabelHidden = reward
      .map { $0.title == nil && $0 != Reward.noReward }

    self.rewardTitleLabelText = projectAndReward
      .map(rewardTitle(project:reward:))

    let rewardItemsIsEmpty = reward
      .map { $0.rewardsItems.isEmpty }

    self.includedItemsStackViewHidden = reward.map { $0.remaining == 0 || $0.rewardsItems.isEmpty }
      .skipRepeats()

    self.items = reward
      .map { reward in
        reward.rewardsItems.map { rewardsItem in
          rewardsItem.quantity > 1
            ? "(\(Format.wholeNumber(rewardsItem.quantity))) \(rewardsItem.item.name)"
            : rewardsItem.item.name
        }
    }

    self.pledgeButtonTitleText = projectAndRewardOrBacking.map { project, rewardOrBacking in
      let minimumFormattedAmount = formattedAmountForRewardOrBacking(project: project, rewardOrBacking: rewardOrBacking)
      return project.personalization.isBacking == true
        ? Strings.Select_this_reward_instead()
        : Strings.rewards_title_pledge_reward_currency_or_more(reward_currency: minimumFormattedAmount)
    }

    self.rewardSelected = reward
      .takeWhen(self.pledgeButtonTappedProperty.signal)
      .map { $0.id }

    self.descriptionStackViewHidden = projectAndRewardOrBacking.mapConst(false)
    self.pledgeButtonEnabled = projectAndRewardOrBacking.mapConst(true)
  }

  private let projectAndRewardOrBackingProperty = MutableProperty<(Project, Either<Reward, Backing>)?>(nil)
  public func configureWith(project: Project, rewardOrBacking: Either<Reward, Backing>) {
    self.projectAndRewardOrBackingProperty.value = (project, rewardOrBacking)
  }

  private let pledgeButtonTappedProperty = MutableProperty(())
  public func pledgeButtonTapped() {
    self.pledgeButtonTappedProperty.value = ()
  }

  public let conversionLabelHidden: Signal<Bool, Never>
  public let conversionLabelText: Signal<String, Never>
  public let descriptionStackViewHidden: Signal<Bool, Never>
  public let descriptionLabelText: Signal<String, Never>
  public let items: Signal<[String], Never>
  public let includedItemsStackViewHidden: Signal<Bool, Never>
  public let pledgeButtonEnabled: Signal<Bool, Never>
  public let pledgeButtonTitleText: Signal<String, Never>
  public let rewardMinimumLabelText: Signal<String, Never>
  public let rewardSelected: Signal<Int, Never>
  public let rewardTitleLabelHidden: Signal<Bool, Never>
  public let rewardTitleLabelText: Signal<String, Never>

  public var inputs: RewardCellViewModelInputs { return self }
  public var outputs: RewardCellViewModelOutputs { return self }
}

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
    return reward == Reward.noReward
      ? Strings.Id_just_like_to_support_the_project()
      : (reward.title ?? "")
  }

  return reward.title ?? Strings.Thank_you_for_supporting_this_project()
}

private func footerString(project: Project, reward: Reward) -> String {
  var parts: [String] = []

  if let endsAt = reward.endsAt, project.state == .live
    && endsAt > 0
    && endsAt >= AppEnvironment.current.dateType.init().timeIntervalSince1970 {

    let (time, unit) = Format.duration(secondsInUTC: min(endsAt, project.dates.deadline),
                                       abbreviate: true,
                                       useToGo: false)

    parts.append(Strings.Time_left_left(time_left: time + " " + unit))
  }

  if let remaining = reward.remaining, reward.limit != nil && project.state == .live {
    parts.append(Strings.Left_count_left(left_count: remaining))
  }

  if let backersCount = reward.backersCount {
    parts.append(Strings.general_backer_count_backers(backer_count: backersCount))
  }

  return parts
    .map { part in part.nonBreakingSpaced() }
    .joined(separator: " • ")
}

private func formattedAmount(for backing: Backing) -> String {
  let amount = backing.amount
  let backingAmount = floor(amount) == backing.amount
    ? String(Int(amount))
    : String(format: "%.2f", backing.amount)
  return backingAmount
}

private func formattedAmountForRewardOrBacking(project: Project, rewardOrBacking: Either<Reward, Backing>) -> String {
  switch rewardOrBacking {
  case let .left(reward):
    let min = minPledgeAmount(forProject: project, reward: reward)
    return Format.currency(min,
                           country: project.country,
                           omitCurrencyCode: project.stats.omitUSCurrencyCode)
  case let .right(backing):
    let amount = backing.amount
    let backingAmount = floor(amount) == backing.amount
      ? String(Int(amount))
      : String(format: "%.2f", backing.amount)
    return Format.formattedCurrency(backingAmount,
                                   country: project.country,
                                   omitCurrencyCode: project.stats.omitUSCurrencyCode)
  }
}
