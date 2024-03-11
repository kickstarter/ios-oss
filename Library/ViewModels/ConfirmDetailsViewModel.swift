import Foundation
import KsApi
import PassKit
import Prelude
import ReactiveSwift

public protocol ConfirmDetailsViewModelInputs {
  func configure(with data: PledgeViewData)
  func pledgeAmountViewControllerDidUpdate(with data: PledgeAmountData)
  func shippingRuleSelected(_ shippingRule: ShippingRule)
  func viewDidLoad()
}

public protocol ConfirmDetailsViewModelOutputs {
  var configureLocalPickupViewWithData: Signal<PledgeLocalPickupViewData, Never> { get }
  var configurePledgeAmountViewWithData: Signal<PledgeAmountViewConfigData, Never> { get }
  var configureShippingLocationViewWithData: Signal<PledgeShippingLocationViewData, Never> { get }
  var configureShippingSummaryViewWithData: Signal<PledgeShippingSummaryViewData, Never> { get }
  var localPickupViewHidden: Signal<Bool, Never> { get }
  var pledgeAmountViewHidden: Signal<Bool, Never> { get }
  var shippingLocationViewHidden: Signal<Bool, Never> { get }
  var shippingSummaryViewHidden: Signal<Bool, Never> { get }
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
    let context = initialData.map(\.context)

    let backing = project.map { $0.personalization.backing }.skipNil()

    // MARK: Pledge Amount

    self.pledgeAmountViewHidden = context.map { $0.pledgeAmountViewHidden }

    let selectedShippingRule = Signal.merge(
      project.mapConst(nil),
      self.shippingRuleSelectedSignal.wrapInOptional()
    )

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

    let projectAndReward = Signal.zip(project, baseReward)

    // MARK: Local Pickup + Shipping

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
  }

  // MARK: - Inputs

  private let configureWithDataProperty = MutableProperty<PledgeViewData?>(nil)
  public func configure(with data: PledgeViewData) {
    self.configureWithDataProperty.value = data
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

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  // MARK: - Outputs

  public let configureLocalPickupViewWithData: Signal<PledgeLocalPickupViewData, Never>
  public let configurePledgeAmountViewWithData: Signal<PledgeAmountViewConfigData, Never>
  public let configureShippingLocationViewWithData: Signal<PledgeShippingLocationViewData, Never>
  public let configureShippingSummaryViewWithData: Signal<PledgeShippingSummaryViewData, Never>
  public let localPickupViewHidden: Signal<Bool, Never>
  public let pledgeAmountViewHidden: Signal<Bool, Never>
  public let shippingLocationViewHidden: Signal<Bool, Never>
  public let shippingSummaryViewHidden: Signal<Bool, Never>

  public var inputs: ConfirmDetailsViewModelInputs { return self }
  public var outputs: ConfirmDetailsViewModelOutputs { return self }
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
