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
  var items: Signal<[String], Never> { get }
  var includedItemsStackViewHidden: Signal<Bool, Never> { get }
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

private func rewardTitle(project: Project, reward: Reward) -> String {
  guard project.personalization.isBacking == true else {
    return reward.isNoReward
      ? Strings.Make_a_pledge_without_a_reward()
      : (reward.title ?? "")
  }

  return reward.title ?? Strings.Thank_you_for_supporting_this_project()
}
