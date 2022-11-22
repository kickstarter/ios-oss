import KsApi
import Prelude
import ReactiveSwift
import UIKit

public struct RewardCardPillData: Equatable {
  public let backgroundColor: UIColor
  public let text: String
  public let textColor: UIColor
}

public enum RewardCardViewContext {
  case pledge
  case manage
}

public typealias RewardCardViewData = (
  project: Project,
  reward: Reward,
  context: RewardCardViewContext
)

public protocol RewardCardViewModelInputs {
  func configure(with data: RewardCardViewData)
  func rewardCardTapped()
}

public protocol RewardCardViewModelOutputs {
  var cardUserInteractionIsEnabled: Signal<Bool, Never> { get }
  var conversionLabelHidden: Signal<Bool, Never> { get }
  var conversionLabelText: Signal<String, Never> { get }
  var descriptionLabelText: Signal<String, Never> { get }
  var estimatedDeliveryStackViewHidden: Signal<Bool, Never> { get }
  var estimatedDeliveryDateLabelText: Signal<String, Never> { get }
  var includedItemsStackViewHidden: Signal<Bool, Never> { get }
  var items: Signal<[String], Never> { get }
  var pillCollectionViewHidden: Signal<Bool, Never> { get }
  var reloadPills: Signal<[RewardCardPillData], Never> { get }
  var rewardLocationPickupLabelText: Signal<String, Never> { get }
  var rewardLocationStackViewHidden: Signal<Bool, Never> { get }
  var rewardMinimumLabelText: Signal<String, Never> { get }
  var rewardSelected: Signal<Int, Never> { get }
  var rewardTitleLabelHidden: Signal<Bool, Never> { get }
  var rewardTitleLabelAttributedText: Signal<NSAttributedString, Never> { get }
}

public protocol RewardCardViewModelType {
  var inputs: RewardCardViewModelInputs { get }
  var outputs: RewardCardViewModelOutputs { get }
}

public final class RewardCardViewModel: RewardCardViewModelType, RewardCardViewModelInputs,
  RewardCardViewModelOutputs {
  public init() {
    let configData = self.configDataProperty.signal
      .skipNil()

    let context = configData.map(third)

    let project: Signal<Project, Never> = configData.map(first)
    let reward: Signal<Reward, Never> = configData.map(second)

    let projectAndReward = Signal.zip(project, reward)

    self.conversionLabelHidden = project.map(needsConversion(project:) >>> negate)

    self.conversionLabelText = projectAndReward
      .filter(first >>> needsConversion(project:))
      .map { project, reward in
        Format.currency(
          reward.convertedMinimum,
          country: project.stats.currentCountry ?? .us,
          omitCurrencyCode: project.stats.omitUSCurrencyCode
        )
      }
      .map(Strings.About_reward_amount(reward_amount:))

    self.rewardMinimumLabelText = projectAndReward
      .map { project, reward in
        (project, Either<Reward, Backing>.left(reward))
      }
      .map(formattedAmountForRewardOrBacking(project:rewardOrBacking:))

    self.descriptionLabelText = projectAndReward
      .map(localizedDescription(project:reward:))

    self.rewardTitleLabelHidden = reward
      .map { $0.title == nil && !$0.isNoReward }

    self.rewardTitleLabelAttributedText = projectAndReward
      .map(rewardTitle(project:reward:))

    let rewardItemsIsEmpty = reward
      .map { $0.rewardsItems.isEmpty }

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

    self.cardUserInteractionIsEnabled = projectAndReward.map { project, reward in
      rewardsCarouselCanNavigateToReward(reward, in: project)
    }

    self.estimatedDeliveryStackViewHidden = context.combineLatest(with: reward)
      .map { context, reward in
        context == .manage || reward.estimatedDeliveryOn == nil
      }

    self.rewardLocationStackViewHidden = reward
      .map { !isRewardLocalPickup($0) }

    self.estimatedDeliveryDateLabelText = reward.map(estimatedDeliveryDateText(with:)).skipNil()
    self.rewardLocationPickupLabelText = reward.map { $0.localPickup?.displayableName }.skipNil()
  }

  private let configDataProperty = MutableProperty<RewardCardViewData?>(nil)
  public func configure(with data: RewardCardViewData) {
    self.configDataProperty.value = data
  }

  private let rewardCardTappedProperty = MutableProperty(())
  public func rewardCardTapped() {
    self.rewardCardTappedProperty.value = ()
  }

  public let cardUserInteractionIsEnabled: Signal<Bool, Never>
  public let conversionLabelHidden: Signal<Bool, Never>
  public let conversionLabelText: Signal<String, Never>
  public let descriptionLabelText: Signal<String, Never>
  public let estimatedDeliveryStackViewHidden: Signal<Bool, Never>
  public let estimatedDeliveryDateLabelText: Signal<String, Never>
  public let items: Signal<[String], Never>
  public let includedItemsStackViewHidden: Signal<Bool, Never>
  public let pillCollectionViewHidden: Signal<Bool, Never>
  public let reloadPills: Signal<[RewardCardPillData], Never>
  public let rewardLocationPickupLabelText: Signal<String, Never>
  public let rewardLocationStackViewHidden: Signal<Bool, Never>
  public let rewardMinimumLabelText: Signal<String, Never>
  public let rewardSelected: Signal<Int, Never>
  public let rewardTitleLabelHidden: Signal<Bool, Never>
  public let rewardTitleLabelAttributedText: Signal<NSAttributedString, Never>

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

private func rewardTitle(project: Project, reward: Reward) -> NSAttributedString {
  guard project.personalization.isBacking == true || currentUserIsCreator(of: project) else {
    return NSAttributedString(
      string: reward.isNoReward ? Strings.Pledge_without_a_reward() : reward.title.coalesceWith("")
    )
  }

  if reward.isNoReward {
    let string = userIsBacking(reward: reward, inProject: project)
      ? Strings.You_pledged_without_a_reward() : Strings.Pledge_without_a_reward()

    return NSAttributedString(string: string)
  }

  let attributes: [NSAttributedString.Key: Any] = [
    .font: UIFont.ksr_title2().bolded
  ]

  let title = reward.title.coalesceWith("")
  let titleAttributed = title.attributed(
    with: UIFont.ksr_title2(),
    foregroundColor: UIColor.ksr_support_700,
    attributes: attributes,
    bolding: [title]
  )

  guard
    let backing = project.personalization.backing,
    // Not the base reward, for that we just return the title without quantity.
    reward.id != backing.reward?.id,
    let selectedQuantity = selectedRewardQuantities(in: backing)[reward.id],
    selectedQuantity > 1 else {
    return titleAttributed
  }

  let qty = "\(selectedQuantity) x "
  let qtyAttributed = qty.attributed(
    with: UIFont.ksr_title2(),
    foregroundColor: UIColor.ksr_create_700,
    attributes: attributes,
    bolding: [title]
  )
  return qtyAttributed + titleAttributed
}

private func pillValues(project: Project, reward: Reward) -> [RewardCardPillData] {
  return [
    timeLeftString(project: project, reward: reward),
    backerCountOrRemainingString(project: project, reward: reward),
    shippingSummaryString(project: project, reward: reward),
    addOnsString(reward: reward)
  ]
  .compact()
}

private func addOnsString(reward: Reward) -> RewardCardPillData? {
  guard reward.hasAddOns else { return nil }

  return RewardCardPillData(
    backgroundColor: UIColor.ksr_create_700.withAlphaComponent(0.06),
    text: Strings.Add_ons(),
    textColor: UIColor.ksr_create_700
  )
}

private func timeLeftString(project: Project, reward: Reward) -> RewardCardPillData? {
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

    return RewardCardPillData(
      backgroundColor: UIColor.ksr_celebrate_100,
      text: Strings.Time_left_left(time_left: time + " " + unit),
      textColor: UIColor.ksr_support_400
    )
  }

  return nil
}

private func backerCountOrRemainingString(project: Project, reward: Reward) -> RewardCardPillData? {
  guard
    let limit = reward.limit,
    let remaining = rewardLimitRemainingForBacker(project: project, reward: reward),
    remaining > 0,
    project.state == .live
  else {
    let backersCount = reward.backersCount ?? 0

    return backersCount > 0 ? RewardCardPillData(
      backgroundColor: UIColor.ksr_create_700.withAlphaComponent(0.06),
      text: Strings.general_backer_count_backers(backer_count: backersCount),
      textColor: UIColor.ksr_create_700
    ) : nil
  }

  return RewardCardPillData(
    backgroundColor: UIColor.ksr_celebrate_100,
    text: Strings.remaining_count_left_of_limit_count(
      remaining_count: "\(remaining)",
      limit_count: "\(limit)"
    ),
    textColor: UIColor.ksr_support_400
  )
}

private func shippingSummaryString(project: Project, reward: Reward) -> RewardCardPillData? {
  if project.state == .live,
    reward.shipping.enabled,
    let shippingSummaryText = reward.shipping.summary {
    return RewardCardPillData(
      backgroundColor: UIColor.ksr_create_700.withAlphaComponent(0.06),
      text: shippingSummaryText,
      textColor: UIColor.ksr_create_700
    )
    /** FIXME: No longer used on iOS. Might still be needed on Android/Web before removing from: `Kickstarter` `config/locales/native/en.yml`
     Strings.Ships_worldwide()
     Strings.Limited_shipping()
     Strings.location_name_only(location_name: name)(location_name: name)
     */
  }

  return nil
}

private func estimatedDeliveryDateText(with reward: Reward) -> String? {
  return reward.estimatedDeliveryOn.map {
    Format.date(
      secondsInUTC: $0,
      template: DateFormatter.monthYear,
      timeZone: UTCTimeZone
    )
  }
}
