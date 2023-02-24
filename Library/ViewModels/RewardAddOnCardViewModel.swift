import KsApi
import Prelude
import ReactiveSwift
import UIKit

public struct RewardAddOnCardViewData: Equatable {
  public let project: Project
  public let reward: Reward
  public let context: RewardCardViewContext
  public let shippingRule: ShippingRule?
  public let selectedQuantities: SelectedRewardQuantities
}

public protocol RewardAddOnCardViewModelInputs {
  func addButtonTapped()
  func configure(with data: RewardAddOnCardViewData)
  func rewardAddOnCardTapped()
  func stepperValueChanged(_ value: Double)
}

public protocol RewardAddOnCardViewModelOutputs {
  var addButtonHidden: Signal<Bool, Never> { get }
  var amountConversionLabelHidden: Signal<Bool, Never> { get }
  var amountConversionLabelText: Signal<String, Never> { get }
  var amountLabelAttributedText: Signal<NSAttributedString, Never> { get }
  var descriptionLabelText: Signal<String, Never> { get }
  var generateSelectionFeedback: Signal<Void, Never> { get }
  var generateNotificationWarningFeedback: Signal<Void, Never> { get }
  var includedItemsLabelAttributedText: Signal<NSAttributedString, Never> { get }
  var includedItemsStackViewHidden: Signal<Bool, Never> { get }
  var notifiyDelegateDidSelectQuantity: Signal<(SelectedRewardQuantity, SelectedRewardId), Never> { get }
  var pillsViewHidden: Signal<Bool, Never> { get }
  var quantityLabelText: Signal<String, Never> { get }
  var reloadPills: Signal<[String], Never> { get }
  var rewardLocationPickupLabelText: Signal<String, Never> { get }
  var rewardLocationStackViewHidden: Signal<Bool, Never> { get }
  var rewardSelected: Signal<Int, Never> { get }
  var rewardTitleLabelText: Signal<String, Never> { get }
  var stepperMaxValue: Signal<Double, Never> { get }
  var stepperStackViewHidden: Signal<Bool, Never> { get }
  var stepperValue: Signal<Double, Never> { get }
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

    let project: Signal<Project, Never> = configData.map(\.project)
    let reward: Signal<Reward, Never> = configData.map(\.reward)
    let selectedQuantities: Signal<SelectedRewardQuantities, Never> = configData.map(\.selectedQuantities)

    let projectAndReward = Signal.zip(project, reward)
    let projectRewardShippingRule = configData.map {
      data in (data.project, data.reward, data.shippingRule)
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
          omitCurrencyCode: project.stats.omitUSCurrencyCode,
          roundingMode: .up
        )
      }
      .map(Strings.About_reward_amount(reward_amount:))

    self.amountLabelAttributedText = projectRewardShippingRule
      .map(amountStringForReward)

    self.descriptionLabelText = reward.map(\.description)

    self.rewardTitleLabelText = reward.map(\.title).skipNil()

    let rewardItemsIsEmpty = reward
      .map { $0.rewardsItems.isEmpty }

    self.includedItemsStackViewHidden = rewardItemsIsEmpty.skipRepeats()

    self.includedItemsLabelAttributedText = reward.map(\.rewardsItems)
      .map(itemsLabelAttributedText)
      .skipNil()

    self.reloadPills = projectAndReward.map(pillValues(project:reward:))
    self.pillsViewHidden = self.reloadPills.map { $0.isEmpty }

    self.rewardSelected = reward
      .takeWhen(self.rewardAddOnCardTappedProperty.signal)
      .map { $0.id }

    let initialSelectedQuantity = Signal.combineLatest(
      reward,
      selectedQuantities
    )
    .map { reward, selectedQuantities in selectedQuantities[reward.id] ?? 0 }

    let updatedSelectedQuantity = Signal.merge(
      self.addButtonTappedProperty.signal.mapConst(1),
      self.stepperValueChangedProperty.signal.skipNil().map(Int.init)
    )

    let initialOrUpdatedSelectedQuantity = Signal.merge(
      initialSelectedQuantity,
      updatedSelectedQuantity
    )

    self.addButtonHidden = initialOrUpdatedSelectedQuantity.map { $0 > 0 }

    self.quantityLabelText = initialOrUpdatedSelectedQuantity.map(String.init)

    self.notifiyDelegateDidSelectQuantity = updatedSelectedQuantity
      .withLatest(from: reward.map(\.id))

    self.rewardLocationStackViewHidden = reward
      .map { !isRewardLocalPickup($0) }

    self.rewardLocationPickupLabelText = reward.map { $0.localPickup?.displayableName }.skipNil()

    self.stepperMaxValue = projectAndReward
      .map { project, reward in
        rewardLimitPerBackerRemainingForBacker(project: project, reward: reward) ?? 0
      }
      .map(Double.init)

    self.stepperStackViewHidden = initialOrUpdatedSelectedQuantity.map { $0 == 0 }

    self.stepperValue = initialOrUpdatedSelectedQuantity
      .map(Double.init)

    let generateFeedbackWithValues = updatedSelectedQuantity.map(Double.init)
      .withLatestFrom(self.stepperMaxValue)

    self.generateSelectionFeedback = generateFeedbackWithValues
      .filter { value, max in value > 0 && value < max }
      .ignoreValues()

    self.generateNotificationWarningFeedback = generateFeedbackWithValues
      .filter { value, max in value == 0 || value >= max }
      .ignoreValues()
  }

  private let addButtonTappedProperty = MutableProperty(())
  public func addButtonTapped() {
    self.addButtonTappedProperty.value = ()
  }

  private let configDataProperty = MutableProperty<RewardAddOnCardViewData?>(nil)
  public func configure(with data: RewardAddOnCardViewData) {
    self.configDataProperty.value = data
  }

  private let rewardAddOnCardTappedProperty = MutableProperty(())
  public func rewardAddOnCardTapped() {
    self.rewardAddOnCardTappedProperty.value = ()
  }

  private let stepperValueChangedProperty = MutableProperty<Double?>(nil)
  public func stepperValueChanged(_ value: Double) {
    self.stepperValueChangedProperty.value = value
  }

  public let addButtonHidden: Signal<Bool, Never>
  public let amountConversionLabelHidden: Signal<Bool, Never>
  public let amountConversionLabelText: Signal<String, Never>
  public let amountLabelAttributedText: Signal<NSAttributedString, Never>
  public let descriptionLabelText: Signal<String, Never>
  public let generateSelectionFeedback: Signal<Void, Never>
  public let generateNotificationWarningFeedback: Signal<Void, Never>
  public let includedItemsLabelAttributedText: Signal<NSAttributedString, Never>
  public let includedItemsStackViewHidden: Signal<Bool, Never>
  public let notifiyDelegateDidSelectQuantity: Signal<(SelectedRewardQuantity, SelectedRewardId), Never>
  public let pillsViewHidden: Signal<Bool, Never>
  public let quantityLabelText: Signal<String, Never>
  public let reloadPills: Signal<[String], Never>
  public let rewardSelected: Signal<Int, Never>
  public let rewardTitleLabelText: Signal<String, Never>
  public let rewardLocationPickupLabelText: Signal<String, Never>
  public let rewardLocationStackViewHidden: Signal<Bool, Never>
  public let stepperMaxValue: Signal<Double, Never>
  public let stepperStackViewHidden: Signal<Bool, Never>
  public let stepperValue: Signal<Double, Never>

  public var inputs: RewardAddOnCardViewModelInputs { return self }
  public var outputs: RewardAddOnCardViewModelOutputs { return self }
}

// MARK: - Functions

private func amountStringForReward(
  project: Project,
  reward: Reward,
  shippingRule: ShippingRule?
) -> NSAttributedString {
  let font: UIFont = UIFont.ksr_subhead().weighted(.medium)
  let foregroundColor: UIColor = UIColor.ksr_create_700

  let projectCurrencyCountry = projectCountry(forCurrency: project.stats.currency) ?? project.country

  let min = minPledgeAmount(forProject: project, reward: reward)
  let amountString = Format.currency(
    min,
    country: projectCurrencyCountry,
    omitCurrencyCode: project.stats.omitUSCurrencyCode
  )

  if let shippingRule = shippingRule, shippingRule.cost > 0 {
    let shippingAmount = Format.currency(
      shippingRule.cost,
      country: projectCurrencyCountry,
      omitCurrencyCode: project.stats.omitUSCurrencyCode
    )

    let combinedString = Strings.reward_amount_plus_shipping_cost_each(
      reward_amount: amountString,
      shipping_cost: shippingAmount
    )

    let attributedString = combinedString.attributed(
      with: UIFont.ksr_footnote().weighted(.medium),
      foregroundColor: foregroundColor,
      attributes: [:],
      bolding: []
    )

    let mutableString = NSMutableAttributedString(attributedString: attributedString)
    let amountRange = (combinedString as NSString).localizedStandardRange(of: amountString)

    mutableString.setAttributes([.font: font], range: amountRange)

    return mutableString
  }

  return amountString.attributed(
    with: font,
    foregroundColor: foregroundColor,
    attributes: [:],
    bolding: []
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

    let suffix = rewardsItem.item.id == items.last?.item.id ? "" : "\n"

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
    remainingString(project: project, reward: reward),
    limitPerBackerString(project: project, reward: reward)
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

private func limitPerBackerString(project: Project, reward: Reward) -> String? {
  guard
    let limitPerBacker = rewardLimitPerBackerRemainingForBacker(project: project, reward: reward),
    limitPerBacker > 0
  else { return nil }

  return Strings.limit_limit_per_backer(limit_per_backer: "\(limitPerBacker)")
}

private func remainingString(project: Project, reward: Reward) -> String? {
  guard
    let limit = reward.limit,
    let remaining = rewardLimitRemainingForBacker(project: project, reward: reward),
    remaining > 0
  else { return nil }

  return Strings.remaining_count_left_of_limit_count(
    remaining_count: "\(remaining)",
    limit_count: "\(limit)"
  )
}
