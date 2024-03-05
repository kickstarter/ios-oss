import Foundation
import KsApi
import PassKit
import Prelude
import ReactiveSwift

public protocol ConfirmDetailsViewModelInputs {
  func configure(with data: PledgeViewData)
  func goToLoginSignupTapped()
  func pledgeAmountViewControllerDidUpdate(with data: PledgeAmountData)
  func shippingRuleSelected(_ shippingRule: ShippingRule)
  func submitButtonTapped()
  func userSessionStarted()
  func viewDidLoad()
}

public protocol ConfirmDetailsViewModelOutputs {
  var configurePledgeSummaryHeaderWithData: Signal<PledgeExpandableRewardsHeaderViewData, Never> { get }
  var configureLocalPickupViewWithData: Signal<PledgeLocalPickupViewData, Never> { get }
  var configurePledgeAmountViewWithData: Signal<PledgeAmountViewConfigData, Never> { get }
  var configurePledgeAmountSummaryViewControllerWithData: Signal<PledgeAmountSummaryViewData, Never> { get }
  var configureRewardsSummaryViewWithData: Signal<
    (PostCampaignRewardsSummaryViewData, PledgeSummaryViewData),
    Never
  > { get }
  var configureShippingLocationViewWithData: Signal<PledgeShippingLocationViewData, Never> { get }
  var configureShippingSummaryViewWithData: Signal<PledgeShippingSummaryViewData, Never> { get }
  var pledgeTotalSummarySectionIsHidden: Signal<Bool, Never> { get }
  var goToLoginSignup: Signal<(LoginIntent, Project, Reward), Never> { get }
  var localPickupViewHidden: Signal<Bool, Never> { get }
  var notifyPledgeAmountViewControllerUnavailableAmountChanged: Signal<Double, Never> { get }
  var pledgeAmountViewHidden: Signal<Bool, Never> { get }
  var pledgeAmountSummaryViewHidden: Signal<Bool, Never> { get }
  var pledgeRewardsSummaryViewHidden: Signal<Bool, Never> { get }
  var shippingLocationViewHidden: Signal<Bool, Never> { get }
  var shippingSummaryViewHidden: Signal<Bool, Never> { get }
  var rootStackViewLayoutMargins: Signal<UIEdgeInsets, Never> { get }
}

public protocol ConfirmDetailsViewModelType {
  var inputs: ConfirmDetailsViewModelInputs { get }
  var outputs: ConfirmDetailsViewModelOutputs { get }
}

public class ConfirmDetailsViewModel: ConfirmDetailsViewModelType, ConfirmDetailsViewModelInputs,
  ConfirmDetailsViewModelOutputs {
  public init() {
    let initialData = Signal.combineLatest(
      self.configureWithDataProperty.signal,
      self.viewDidLoadProperty.signal
    )
    .map(first)
    .skipNil()

    let project = initialData.map(\.project)
    let baseReward = initialData.map(\.rewards).map(\.first).skipNil()
    let rewards = initialData.map(\.rewards)
    let selectedQuantities = initialData.map(\.selectedQuantities)
    let selectedLocationId = initialData.map(\.selectedLocationId)
    let refTag = initialData.map(\.refTag)
    let context = initialData.map(\.context)

    let backing = project.map { $0.personalization.backing }.skipNil()

    self.pledgeAmountViewHidden = context.map { $0.pledgeAmountViewHidden }
    self.pledgeAmountSummaryViewHidden = Signal.zip(baseReward, context).map { baseReward, context in
      (baseReward.isNoReward && context == .update) || context.pledgeAmountSummaryViewHidden
    }

    let selectedShippingRule = Signal.merge(
      project.mapConst(nil),
      self.shippingRuleSelectedSignal.wrapInOptional()
    )

    let allRewardsTotal = Signal.combineLatest(
      rewards,
      selectedQuantities
    )
    .map(calculateAllRewardsTotal)

    let calculatedShippingTotal = Signal.combineLatest(
      selectedShippingRule.skipNil(),
      rewards,
      selectedQuantities
    )
    .map(calculateShippingTotal)

    let baseRewardShippingTotal = Signal.zip(project, baseReward, selectedShippingRule)
      .map(getBaseRewardShippingTotal)

    let allRewardsShippingTotal = Signal.merge(
      baseRewardShippingTotal,
      calculatedShippingTotal
    )

    // Initial pledge amount is zero if not backed.
    let initialAdditionalPledgeAmount = Signal.merge(
      initialData.filter { $0.project.personalization.backing == nil }.mapConst(0.0),
      backing.map(\.bonusAmount)
    )
    .take(first: 1)

    let additionalPledgeAmount = Signal.merge(
      self.pledgeAmountDataSignal.map { $0.amount },
      initialAdditionalPledgeAmount
    )

    self.notifyPledgeAmountViewControllerUnavailableAmountChanged = Signal.combineLatest(
      allRewardsTotal,
      allRewardsShippingTotal
    )
    .map { $0.addingCurrency($1) }

    let projectAndReward = Signal.zip(project, baseReward)

    /**
     Shipping location selector is hidden if the context hides it,
     if the base reward has no shipping, when add-ons were selected or when base reward has local pickup option.
     */
    let nonLocalPickupShippingLocationViewHidden = Signal.combineLatest(baseReward, rewards, context)
      .map { baseReward, rewards, context in
        [
          context.shippingLocationViewHidden,
          !baseReward.shipping.enabled,
          rewards.count > 1
        ].contains(true)
      }

    self.shippingLocationViewHidden = Signal
      .combineLatest(nonLocalPickupShippingLocationViewHidden, baseReward)
      .map { flag, baseReward in
        isRewardLocalPickup(baseReward) ? true : flag
      }

    /**
     Shipping summary view is hidden when updating,
     if the base reward has no shipping, when NO add-ons were selected or when base reward has local pickup option.
     */
    let nonLocalPickupShippingSummaryViewHidden = Signal.combineLatest(baseReward, rewards, context)
      .map { baseReward, rewards, context in
        [
          context.isAny(of: .update, .changePaymentMethod, .fixPaymentMethod),
          !baseReward.shipping.enabled,
          rewards.count == 1
        ].contains(true)
      }

    self.shippingSummaryViewHidden = Signal.combineLatest(nonLocalPickupShippingSummaryViewHidden, baseReward)
      .map { flag, baseReward in
        isRewardLocalPickup(baseReward) ? true : flag
      }

    let shippingViewsHidden: Signal<Bool, Never> = Signal.combineLatest(
      self.shippingSummaryViewHidden,
      self.shippingLocationViewHidden
    )
    .map { a, b -> Bool in
      let r = a && b
      return r
    }

    let shippingViewsHiddenConditionsForPledgeAmountSummary: Signal<Bool, Never> = Signal
      .combineLatest(
        nonLocalPickupShippingLocationViewHidden,
        nonLocalPickupShippingSummaryViewHidden
      )
      .map { a, b -> Bool in
        let r = a && b
        return r
      }

    self.localPickupViewHidden = baseReward.map(isRewardLocalPickup).negate()

    // Only shown for regular non-add-ons based rewards
    self.configureShippingLocationViewWithData = Signal.combineLatest(
      projectAndReward,
      shippingViewsHidden.filter(isFalse),
      selectedLocationId
    )
    .map { projectAndReward, _, selectedLocationId in
      (projectAndReward.0, projectAndReward.1, selectedLocationId)
    }
    .map { project, reward, locationId in
      (project, reward, true, locationId)
    }

    // Only shown for add-ons based rewards
    self.configureShippingSummaryViewWithData = Signal.combineLatest(
      selectedShippingRule.skipNil().map(\.location.localizedName),
      project.map(\.stats.omitUSCurrencyCode),
      project.map { project in
        projectCountry(forCurrency: project.stats.currency) ?? project.country
      },
      allRewardsShippingTotal
    )
    .map(PledgeShippingSummaryViewData.init)

    self.configurePledgeAmountViewWithData = Signal.combineLatest(
      projectAndReward,
      initialAdditionalPledgeAmount
    )
    .map(unpack)
    .map { project, reward, additionalPledgeAmount in
      (
        project,
        reward,
        additionalPledgeAmount
      )
    }

    // Only shown for if the shipping summary view and shipping location view are hidden
    self.configureLocalPickupViewWithData = Signal.combineLatest(
      projectAndReward,
      shippingViewsHidden.filter(isTrue)
    )
    .switchMap { projectAndReward, _ -> SignalProducer<PledgeLocalPickupViewData?, Never> in
      guard let locationName = projectAndReward.1.localPickup?.displayableName else {
        return SignalProducer(value: nil)
      }

      let localPickupLocationData = PledgeLocalPickupViewData(locationName: locationName)

      return SignalProducer(value: localPickupLocationData)
    }
    .skipNil()

    /**
     * The total pledge amount that will be used to create the backing.
     * For a regular reward this includes the bonus support amount,
     * the total of all rewards and their respective shipping costs.
     * For No Reward this is only the pledge amount.
     */
    let calculatedPledgeTotal = Signal.combineLatest(
      additionalPledgeAmount,
      allRewardsShippingTotal,
      allRewardsTotal
    )
    .map(calculatePledgeTotal)

    let pledgeTotal = Signal.merge(
      backing.map(\.amount),
      calculatedPledgeTotal
    )

    let projectAndConfirmationLabelHidden = Signal.combineLatest(
      project,
      context.map { $0.confirmationLabelHidden }
    )

    self.goToLoginSignup = Signal.combineLatest(project, baseReward, self.goToLoginSignupSignal)
      .map { (LoginIntent.backProject, $0.0, $0.1) }

    self.configurePledgeSummaryHeaderWithData = Signal.zip(
      baseReward.map(\.isNoReward).filter(isFalse),
      project,
      rewards,
      selectedQuantities
    )
    .map { _, project, rewards, selectedQuantities in
      guard let projectCurrencyCountry = projectCountry(forCurrency: project.stats.currency) else {
        return (rewards, selectedQuantities, project.country, project.stats.omitUSCurrencyCode)
      }

      return (rewards, selectedQuantities, projectCurrencyCountry, project.stats.omitUSCurrencyCode)
    }
    .map(PledgeExpandableRewardsHeaderViewData.init)

    self.pledgeRewardsSummaryViewHidden = Signal.zip(context, baseReward)
      .map { context, reward in
        if context.isAny(of: .pledge, .updateReward) {
          return reward.isNoReward
        }

        return context.expandableRewardViewHidden
      }

    self.rootStackViewLayoutMargins = self.pledgeRewardsSummaryViewHidden.map { hidden in
      hidden ? UIEdgeInsets(topBottom: Styles.grid(3)) : UIEdgeInsets(bottom: Styles.grid(3))
    }

    self.configurePledgeAmountSummaryViewControllerWithData = Signal.combineLatest(
      projectAndReward,
      allRewardsTotal,
      additionalPledgeAmount,
      shippingViewsHiddenConditionsForPledgeAmountSummary,
      context
    )
    .map { projectAndReward, allRewardsTotal, amount, shippingViewsHidden, context in
      (projectAndReward.0, projectAndReward.1, allRewardsTotal, amount, shippingViewsHidden, context)
    }
    .map(pledgeAmountSummaryViewData)
    .skipNil()

    let rewardsSummaryPledgeData = Signal.combineLatest(
      projectAndConfirmationLabelHidden,
      pledgeTotal
    )
    .map(unpack)
    .map { project, confirmationLabelHidden, total in (project, total, confirmationLabelHidden) }
    .map(pledgeSummaryViewData)

    let shippingSummaryData = Signal.combineLatest(
      selectedShippingRule.skipNil().map(\.location.localizedName),
      project.map(\.stats.omitUSCurrencyCode),
      project.map { project in
        projectCountry(forCurrency: project.stats.currency) ?? project.country
      },
      allRewardsShippingTotal
    )
    .map(PledgeShippingSummaryViewData.init)

    self.configureRewardsSummaryViewWithData = Signal.zip(
      baseReward.map(\.isNoReward).filter(isFalse),
      project,
      rewards,
      selectedQuantities,
      rewardsSummaryPledgeData,
      shippingSummaryData
    )
    .map { _, project, rewards, selectedQuantities, rewardsSummaryPledgeData, shippingSummaryData -> (
      PostCampaignRewardsSummaryViewData,
      PledgeSummaryViewData
    ) in
    guard let projectCurrencyCountry = projectCountry(forCurrency: project.stats.currency) else {
      return (
        PostCampaignRewardsSummaryViewData
          .init(
            rewards: rewards,
            selectedQuantities: selectedQuantities,
            projectCountry: project.country,
            omitCurrencyCode: project.stats.omitUSCurrencyCode,
            shipping: shippingSummaryData
          ),
        rewardsSummaryPledgeData
      )
    }

    return (
      PostCampaignRewardsSummaryViewData
        .init(
          rewards: rewards,
          selectedQuantities: selectedQuantities,
          projectCountry: projectCurrencyCountry,
          omitCurrencyCode: project.stats.omitUSCurrencyCode,
          shipping: shippingSummaryData
        ),
      rewardsSummaryPledgeData
    )
    }

    self.pledgeTotalSummarySectionIsHidden = Signal.zip(baseReward, context).map { baseReward, context in
      (baseReward.isNoReward && context == .update) || context.pledgeAmountSummaryViewHidden
    }
  }

  // MARK: - Inputs

  private let configureWithDataProperty = MutableProperty<PledgeViewData?>(nil)
  public func configure(with data: PledgeViewData) {
    self.configureWithDataProperty.value = data
  }

  private let (goToLoginSignupSignal, goToLoginSignupObserver) = Signal<Void, Never>.pipe()
  public func goToLoginSignupTapped() {
    self.goToLoginSignupObserver.send(value: ())
  }

  private let (pledgeAmountDataSignal, pledgeAmountObserver) = Signal<PledgeAmountData, Never>.pipe()
  public func pledgeAmountViewControllerDidUpdate(with data: PledgeAmountData) {
    self.pledgeAmountObserver.send(value: data)
  }

  private let (shippingRuleSelectedSignal, shippingRuleSelectedObserver) = Signal<ShippingRule, Never>.pipe()
  public func shippingRuleSelected(_ shippingRule: ShippingRule) {
    self.shippingRuleSelectedObserver.send(value: shippingRule)
  }

  private let (submitButtonTappedSignal, submitButtonTappedObserver) = Signal<Void, Never>.pipe()
  public func submitButtonTapped() {
    self.submitButtonTappedObserver.send(value: ())
  }

  private let (userSessionStartedSignal, userSessionStartedObserver) = Signal<Void, Never>.pipe()
  public func userSessionStarted() {
    self.userSessionStartedObserver.send(value: ())
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  // MARK: - Outputs

  public let configurePledgeSummaryHeaderWithData: Signal<PledgeExpandableRewardsHeaderViewData, Never>
  public let configureLocalPickupViewWithData: Signal<PledgeLocalPickupViewData, Never>
  public let configurePledgeAmountViewWithData: Signal<PledgeAmountViewConfigData, Never>
  public let configurePledgeAmountSummaryViewControllerWithData: Signal<PledgeAmountSummaryViewData, Never>
  public let configureRewardsSummaryViewWithData: Signal<(
    PostCampaignRewardsSummaryViewData,
    PledgeSummaryViewData
  ), Never>
  public let configureShippingLocationViewWithData: Signal<PledgeShippingLocationViewData, Never>
  public let configureShippingSummaryViewWithData: Signal<PledgeShippingSummaryViewData, Never>
  public let goToLoginSignup: Signal<(LoginIntent, Project, Reward), Never>
  public let localPickupViewHidden: Signal<Bool, Never>
  public let notifyPledgeAmountViewControllerUnavailableAmountChanged: Signal<Double, Never>
  public let pledgeAmountViewHidden: Signal<Bool, Never>
  public let pledgeAmountSummaryViewHidden: Signal<Bool, Never>
  public let pledgeTotalSummarySectionIsHidden: Signal<Bool, Never>
  public let pledgeRewardsSummaryViewHidden: Signal<Bool, Never>
  public let shippingLocationViewHidden: Signal<Bool, Never>
  public let shippingSummaryViewHidden: Signal<Bool, Never>
  public let rootStackViewLayoutMargins: Signal<UIEdgeInsets, Never>

  public var inputs: ConfirmDetailsViewModelInputs { return self }
  public var outputs: ConfirmDetailsViewModelOutputs { return self }
}

// MARK: - Functions

private func requiresSCA(_ envelope: StripeSCARequiring) -> Bool {
  return envelope.requiresSCAFlow
}

// MARK: - Validation Functions

private func amountValid(
  project: Project,
  reward: Reward,
  pledgeAmountData: PledgeAmountData,
  initialAdditionalPledgeAmount: Double,
  context: PledgeViewContext
) -> Bool {
  guard
    project.personalization.backing != nil,
    context.isUpdating,
    userIsBacking(reward: reward, inProject: project)
  else {
    return pledgeAmountData.isValid
  }

  /**
   The amount is valid if it's changed or if the reward has add-ons.
   This works because of the validation that would have occurred during add-ons selection,
   that is, in `RewardAddOnSelectionViewController` we don't navigate further unless the selection changes.
   */
  return [
    pledgeAmountData.amount != initialAdditionalPledgeAmount || reward.hasAddOns,
    pledgeAmountData.isValid
  ]
  .allSatisfy(isTrue)
}

private func shippingRuleValid(
  project: Project,
  reward: Reward,
  shippingRule: ShippingRule?,
  context: PledgeViewContext
) -> Bool {
  if context.isCreating || context == .updateReward {
    return !reward.shipping.enabled || shippingRule != nil
  }

  guard
    let backing = project.personalization.backing,
    let shippingRule = shippingRule,
    context.isUpdating
  else {
    return false
  }

  return backing.locationId != shippingRule.location.id
}

private func paymentMethodValid(
  project: Project,
  reward: Reward,
  paymentSourceId: String,
  context: PledgeViewContext
) -> Bool {
  guard
    let backedPaymentSourceId = project.personalization.backing?.paymentSource?.id,
    context.isUpdating,
    userIsBacking(reward: reward, inProject: project)
  else {
    return true
  }

  if project.personalization.backing?.status == .errored {
    return true
  } else if backedPaymentSourceId != paymentSourceId {
    return true
  }

  return false
}

private func allValuesChangedAndValid(
  amountValid: Bool,
  shippingRuleValid: Bool,
  paymentSourceValid: Bool,
  context: PledgeViewContext
) -> Bool {
  if context.isUpdating, context != .updateReward {
    return amountValid || shippingRuleValid || paymentSourceValid
  }

  return amountValid && shippingRuleValid
}

// MARK: - Helper Functions

private func pledgeSummaryViewData(
  project: Project,
  total: Double,
  confirmationLabelHidden: Bool
) -> PledgeSummaryViewData {
  return (project, total, confirmationLabelHidden)
}

private func pledgeAmountSummaryViewData(
  with project: Project,
  reward _: Reward,
  allRewardsTotal: Double,
  additionalPledgeAmount: Double,
  shippingViewsHidden: Bool,
  context: PledgeViewContext
) -> PledgeAmountSummaryViewData? {
  guard let backing = project.personalization.backing else { return nil }

  let rewardIsLocalPickup = isRewardLocalPickup(backing.reward)
  let projectCurrencyCountry = projectCountry(forCurrency: project.stats.currency) ?? project.country

  return .init(
    bonusAmount: additionalPledgeAmount,
    bonusAmountHidden: context == .update,
    isNoReward: backing.reward?.isNoReward ?? false,
    locationName: backing.locationName,
    omitUSCurrencyCode: project.stats.omitUSCurrencyCode,
    projectCurrencyCountry: projectCurrencyCountry,
    pledgedOn: backing.pledgedAt,
    rewardMinimum: allRewardsTotal,
    shippingAmount: backing.shippingAmount.flatMap(Double.init),
    shippingAmountHidden: !shippingViewsHidden,
    rewardIsLocalPickup: rewardIsLocalPickup
  )
}
