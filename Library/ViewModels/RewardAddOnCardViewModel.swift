import KsApi
import Prelude
import ReactiveSwift

public enum RewardAddOnCardViewContext {
  case pledge
  case manage
}

public typealias RewardAddOnCardViewData = (
  project: Project,
  reward: Reward,
  context: RewardAddOnCardViewContext,
  shippingRule: ShippingRule?
)

public protocol RewardAddOnCardViewModelInputs {
  func configure(with data: RewardAddOnCardViewData)
  func rewardAddOnCardTapped()
}

public protocol RewardAddOnCardViewModelOutputs {
  var cardUserInteractionIsEnabled: Signal<Bool, Never> { get }
  var amountConversionLabelHidden: Signal<Bool, Never> { get }
  var amountConversionLabelText: Signal<String, Never> { get }
  var amountLabelAttributedText: Signal<NSAttributedString, Never> { get }
  var descriptionLabelText: Signal<String, Never> { get }
  var includedItemsLabelAttributedText: Signal<NSAttributedString, Never> { get }
  var includedItemsStackViewHidden: Signal<Bool, Never> { get }
  var pillsViewHidden: Signal<Bool, Never> { get }
  var reloadPills: Signal<[String], Never> { get }
  var rewardSelected: Signal<Int, Never> { get }
  var rewardTitleLabelText: Signal<String, Never> { get }
}

public protocol RewardAddOnCardViewModelType {
  var inputs: RewardAddOnCardViewModelInputs { get }
  var outputs: RewardAddOnCardViewModelOutputs { get }
}

public final class RewardAddOnCardViewModel: RewardAddOnCardViewModelType, RewardAddOnCardViewModelInputs,
  RewardAddOnCardViewModelOutputs {
  public init() {
    let configData = self.configDataProperty.signal
      .skipNil()

    let project: Signal<Project, Never> = configData.map { $0.0 }
    let reward: Signal<Reward, Never> = configData.map { $0.1 }

    let projectAndReward = Signal.zip(project, reward)
    let projectRewardShippingRule = configData.map {
      project, reward, _, shippingRule in (project, reward, shippingRule)
    }

    self.amountConversionLabelHidden = project.map(needsConversion(project:) >>> negate)

    self.amountConversionLabelText = projectRewardShippingRule
      .filter(first >>> needsConversion(project:))
      .map { project, reward, shippingRule -> (Project, Reward, Double) in
        let convertedAmount = reward.minimum
          .addingCurrency(shippingRule?.cost ?? 0)
          .multiplyingCurrency(
            Double(project.stats.currentCurrencyRate ?? project.stats.staticUsdRate)
          )

        return (project, reward, convertedAmount)
      }
      .map { project, _, amount in
        Format.currency(
          amount,
          country: project.stats.currentCountry ?? .us,
          omitCurrencyCode: project.stats.omitUSCurrencyCode
        )
      }
      .map(Strings.About_reward_amount(reward_amount:))

    self.amountLabelAttributedText = projectRewardShippingRule
      .map(amountStringForReward)

    self.descriptionLabelText = reward.map(\.description)

    self.rewardTitleLabelText = reward.map(\.title).skipNil()

    let rewardItemsIsEmpty = reward
      .map { $0.rewardsItems.isEmpty }

    let rewardAvailable = reward
      .map { $0.remaining == 0 }.negate()

    self.includedItemsStackViewHidden = rewardItemsIsEmpty.skipRepeats()

    self.includedItemsLabelAttributedText = reward.map(\.rewardsItems)
      .map(itemsLabelAttributedText)
      .skipNil()

    self.reloadPills = projectAndReward.map(pillValues(project:reward:))
    self.pillsViewHidden = self.reloadPills.map { $0.isEmpty }

    self.rewardSelected = reward
      .takeWhen(self.rewardAddOnCardTappedProperty.signal)
      .map { $0.id }

    self.cardUserInteractionIsEnabled = rewardAvailable
  }

  private let configDataProperty = MutableProperty<RewardAddOnCardViewData?>(nil)
  public func configure(with data: RewardAddOnCardViewData) {
    self.configDataProperty.value = data
  }

  private let rewardAddOnCardTappedProperty = MutableProperty(())
  public func rewardAddOnCardTapped() {
    self.rewardAddOnCardTappedProperty.value = ()
  }

  public let amountConversionLabelHidden: Signal<Bool, Never>
  public let amountConversionLabelText: Signal<String, Never>
  public let amountLabelAttributedText: Signal<NSAttributedString, Never>
  public let cardUserInteractionIsEnabled: Signal<Bool, Never>
  public let descriptionLabelText: Signal<String, Never>
  public let includedItemsLabelAttributedText: Signal<NSAttributedString, Never>
  public let includedItemsStackViewHidden: Signal<Bool, Never>
  public let pillsViewHidden: Signal<Bool, Never>
  public let reloadPills: Signal<[String], Never>
  public let rewardSelected: Signal<Int, Never>
  public let rewardTitleLabelText: Signal<String, Never>

  public var inputs: RewardAddOnCardViewModelInputs { return self }
  public var outputs: RewardAddOnCardViewModelOutputs { return self }
}

// MARK: - Functions

private func amountStringForReward(
  project: Project,
  reward: Reward,
  shippingRule: ShippingRule?
) -> NSAttributedString {
  let font: UIFont = UIFont.ksr_footnote().weighted(.medium)
  let foregroundColor: UIColor = UIColor.ksr_green_500

  let min = minPledgeAmount(forProject: project, reward: reward)
  let amountString = Format.currency(
    min,
    country: project.country,
    omitCurrencyCode: project.stats.omitUSCurrencyCode
  )

  if let shippingRule = shippingRule {
    let shippingAmount = Format.currency(
      shippingRule.cost,
      country: project.country,
      omitCurrencyCode: project.stats.omitUSCurrencyCode
    )

    let combinedString = localizedString(
      key: "reward_amount_plus_shipping_cost_each",
      defaultValue: "%{reward_amount} + %{shipping_cost} shipping each",
      substitutions: ["reward_amount": amountString, "shipping_cost": shippingAmount]
    )

    return combinedString.attributed(
      with: font,
      foregroundColor: foregroundColor,
      attributes: [:],
      bolding: [amountString]
    )
  }

  return amountString.attributed(
    with: font,
    foregroundColor: foregroundColor,
    attributes: [:],
    bolding: [amountString]
  )
}

private func itemsLabelAttributedText(_ items: [RewardsItem]) -> NSAttributedString? {
  guard !items.isEmpty else { return nil }

  let defaultAttributes: [NSAttributedString.Key: Any] = [
    .font: UIFont.ksr_callout()
  ]
  let bulletPrefix = "•  "

  let paragraphStyle = NSMutableParagraphStyle()
  paragraphStyle.headIndent = (bulletPrefix as NSString).size(withAttributes: defaultAttributes).width
  paragraphStyle.paragraphSpacing = Styles.grid(1)

  let bulletedListAttributes: [NSAttributedString.Key: Any] = [.paragraphStyle: paragraphStyle]

  let attributedString = NSMutableAttributedString()

  items.map { rewardsItem -> NSAttributedString in
    let itemString = rewardsItem.quantity > 1
      ? "\(Format.wholeNumber(rewardsItem.quantity)) x \(rewardsItem.item.name)"
      : rewardsItem.item.name

    let suffix = rewardsItem.id == items.last?.id ? "" : "\n"

    return NSAttributedString(
      string: "\(bulletPrefix)\(itemString)\(suffix)",
      attributes: defaultAttributes.withAllValuesFrom(bulletedListAttributes)
    )
  }
  .forEach { bulletItem in attributedString.append(bulletItem) }

  return attributedString
}

private func needsConversion(project: Project) -> Bool {
  return project.stats.needsConversion
}

private func backingReward(fromProject project: Project) -> Reward? {
  guard let backing = project.personalization.backing else {
    return nil
  }

  return project.rewards
    .first { $0.id == backing.rewardId || $0.id == backing.reward?.id }
    .coalesceWith(.noReward)
}

private func pillValues(project: Project, reward: Reward) -> [String] {
  return [
    timeLeftString(project: project, reward: reward),
    remainingString(reward: reward),
    limitPerBackerString(reward: reward)
  ]
  .compact()
}

private func timeLeftString(project: Project, reward: Reward) -> String? {
  let isUnlimitedOrAvailable = reward.limit == nil || reward.remaining ?? 0 > 0

  if let endsAt = reward.endsAt,
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

private func limitPerBackerString(reward: Reward) -> String? {
  guard let limit = reward.addOnData?.limitPerBacker, limit > 0 else { return nil }

  return localizedString(
    key: "limit_limit_per_backer",
    defaultValue: "Limit %{limit_per_backer}",
    substitutions: ["limit_per_backer": "\(limit)"]
  )
}

private func remainingString(reward: Reward) -> String? {
  guard
    let limit = reward.limit,
    let remaining = reward.remaining,
    remaining > 0
  else { return nil }

  return Strings.remaining_count_left_of_limit_count(
    remaining_count: "\(remaining)",
    limit_count: "\(limit)"
  )
}
