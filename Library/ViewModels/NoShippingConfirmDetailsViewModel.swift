import Foundation
import KsApi
import PassKit
import Prelude
import ReactiveSwift

public protocol NoShippingConfirmDetailsViewModelInputs {
  func configure(with data: PledgeViewData)
  func continueCTATapped()
  func pledgeAmountViewControllerDidUpdate(with data: PledgeAmountData)
  func userSessionStarted()
  func viewDidLoad()
}

public protocol NoShippingConfirmDetailsViewModelOutputs {
  var configureCTAWithPledgeTotal: Signal<(Project, Double), Never> { get }
  var configureLocalPickupViewWithData: Signal<PledgeLocalPickupViewData, Never> { get }
  var configurePledgeAmountViewWithData: Signal<PledgeAmountViewConfigData, Never> { get }
  var configurePledgeRewardsSummaryViewWithData: Signal<
    (PostCampaignRewardsSummaryViewData, Double?, PledgeSummaryViewData),
    Never
  > { get }
  var configurePledgeSummaryViewControllerWithData: Signal<PledgeSummaryViewData, Never> { get }
  var createCheckoutSuccess: Signal<PostCampaignCheckoutData, Never> { get }
  var goToLoginSignup: Signal<(LoginIntent, Project, Reward?), Never> { get }
  var localPickupViewHidden: Signal<Bool, Never> { get }
  var pledgeAmountViewHidden: Signal<Bool, Never> { get }
  var pledgeRewardsSummaryViewHidden: Signal<Bool, Never> { get }
  var pledgeSummaryViewHidden: Signal<Bool, Never> { get }
  var showErrorBannerWithMessage: Signal<String, Never> { get }
}

public protocol NoShippingConfirmDetailsViewModelType {
  var inputs: NoShippingConfirmDetailsViewModelInputs { get }
  var outputs: NoShippingConfirmDetailsViewModelOutputs { get }
}

public class NoShippingConfirmDetailsViewModel: NoShippingConfirmDetailsViewModelType,
  NoShippingConfirmDetailsViewModelInputs,
  NoShippingConfirmDetailsViewModelOutputs {
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
    let selectedShippingRule = initialData.map(\.selectedShippingRule)
    let selectedQuantities = initialData.map(\.selectedQuantities)
    let selectedLocationId = initialData.map(\.selectedLocationId)
    let context = initialData.map(\.context)
    let refTag = initialData.map(\.refTag)

    let backing = project.map { $0.personalization.backing }.skipNil()

    let isLoggedIn = Signal.merge(initialData.ignoreValues(), self.userSessionStartedSignal)
      .map { _ in AppEnvironment.current.currentUser }
      .map(isNotNil)

    self.goToLoginSignup = Signal.combineLatest(isLoggedIn, initialData)
      .takeWhen(self.continueCTATappedProperty.signal)
      .filter { isLoggedIn, _ in isLoggedIn == false }
      .map { _, data in
        let baseReward = data.rewards.first
        return (LoginIntent.backProject, data.project, baseReward)
      }

    // MARK: Pledge Amount

    self.pledgeAmountViewHidden = context.map { $0.pledgeAmountViewHidden }

    let shippingRule = Signal.merge(
      project.mapConst(nil),
      selectedShippingRule
    )

    let calculatedShippingTotal = Signal.combineLatest(
      shippingRule.skipNil(),
      rewards,
      selectedQuantities
    )
    .map(calculateShippingTotal)

    let baseRewardShippingTotal = Signal.zip(project, baseReward, shippingRule)
      .map(getBaseRewardShippingTotal)

    let allRewardsShippingTotal = Signal.merge(
      baseRewardShippingTotal,
      calculatedShippingTotal
    )

    /// If initial data includes a custom pledge amount, use that.
    /// If not, bonus amount is 0 if there's no backing.
    let initialPledgeAmount = Signal.zip(initialData.map(\.bonusSupport), project)
      .map { bonusSupport, project in
        if let bonusSupport { return bonusSupport }
        if let backing = project.personalization.backing { return backing.bonusAmount }
        return 0.0
      }

    /// Called when pledge or bonus is updated by backer
    let additionalPledgeAmount = Signal.merge(
      self.pledgeAmountDataSignal.map { $0.amount },
      initialPledgeAmount
    )

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

    self.localPickupViewHidden = baseReward.map(isRewardLocalPickup).negate()

    self.configurePledgeAmountViewWithData = Signal.combineLatest(
      projectAndReward,
      initialPledgeAmount
    )
    .map(unpack)
    .map { project, reward, additionalPledgeAmount in
      (
        project,
        reward,
        additionalPledgeAmount
      )
    }

    /// Only shown for if the shipping summary view and shipping location view are hidden
    self.configureLocalPickupViewWithData = projectAndReward
      .switchMap { projectAndReward -> SignalProducer<PledgeLocalPickupViewData?, Never> in
        guard let locationName = projectAndReward.1.localPickup?.displayableName else {
          return SignalProducer(value: nil)
        }

        let localPickupLocationData = PledgeLocalPickupViewData(locationName: locationName)

        return SignalProducer(value: localPickupLocationData)
      }
      .skipNil()

    // MARK: Total Pledge Summary

    /// Hide when there is a reward and shipping is enabled (accounts for digital rewards), and in a pledge context
    self.pledgeSummaryViewHidden = Signal.zip(baseReward, context).map { baseReward, context in
      baseReward.isNoReward == false && context == .latePledge
    }

    let allRewardsTotal = Signal.combineLatest(
      rewards,
      selectedQuantities
    )
    .map(calculateAllRewardsTotal)

    /**
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

    let pledgeTotalSummaryData = Signal.combineLatest(
      projectAndConfirmationLabelHidden,
      pledgeTotal
    )
    .map(unpack)
    .map { project, confirmationLabelHidden, total in (project, total, confirmationLabelHidden) }
    .map(pledgeSummaryViewData)

    self.configurePledgeSummaryViewControllerWithData = pledgeTotalSummaryData

    // MARK: Pledge + Rewards Summary Table

    self.pledgeRewardsSummaryViewHidden = Signal.zip(context, baseReward)
      .map { context, reward in
        if context.isAny(of: .pledge, .updateReward) {
          return reward.isNoReward
        }

        return context.expandableRewardViewHidden
      }

    let shippingSummaryData = Signal.combineLatest(
      shippingRule.skipNil().map(\.location.localizedName),
      project.map(\.stats.omitUSCurrencyCode),
      project.map { project in
        projectCountry(forCurrency: project.stats.currency) ?? project.country
      },
      allRewardsShippingTotal
    )
    .map(PledgeShippingSummaryViewData.init)

    let optionalShippingSummaryData = Signal.merge(
      project.mapConst(nil),
      shippingSummaryData.wrapInOptional()
    )

    let bonusOrPledgeUpdatedAmount = self.pledgeAmountDataSignal.map { $0.amount }

    self.configurePledgeRewardsSummaryViewWithData = Signal.combineLatest(
      baseReward.map(\.isNoReward).filter(isFalse),
      project,
      rewards,
      selectedQuantities,
      optionalShippingSummaryData,
      bonusOrPledgeUpdatedAmount,
      pledgeTotalSummaryData
    )
    .map { _, project, rewards, selectedQuantities, shippingSummaryData, bonusOrPledgeUpdatedAmount, pledgeTotalSummaryData -> (
      PostCampaignRewardsSummaryViewData,
      Double?,
      PledgeSummaryViewData
    ) in
      (
        PostCampaignRewardsSummaryViewData(
          rewards: rewards,
          selectedQuantities: selectedQuantities,
          projectCountry: project.country,
          omitCurrencyCode: project.stats.omitUSCurrencyCode,
          shipping: shippingSummaryData
        ),
        bonusOrPledgeUpdatedAmount,
        pledgeTotalSummaryData
      )
    }

    self.configureCTAWithPledgeTotal = Signal.combineLatest(project, pledgeTotal)

    // MARK: CreateCheckout GraphQL Call

    let pledgeDetailsData = Signal.combineLatest(
      project,
      rewards,
      selectedQuantities,
      selectedShippingRule,
      pledgeTotal,
      refTag
    )

    let isLoggedInAndContinueButtonTapped = Signal.merge(
      self.continueCTATappedProperty.signal,
      self.userSessionStartedSignal
    )

    let createCheckoutEvents = Signal.combineLatest(isLoggedIn, pledgeDetailsData)
      .takeWhen(isLoggedInAndContinueButtonTapped)
      .filter { isLoggedIn, _ in isLoggedIn }
      .map { _, pledgeDetailsData in
        let (
          project,
          rewards,
          selectedQuantities,
          selectedShippingRule,
          pledgeTotal,
          refTag
        ) = pledgeDetailsData
        let rewardsIDs: [String] = rewards.first?.isNoReward == true
          ? []
          : rewards.flatMap { reward -> [String] in
            guard let count = selectedQuantities[reward.id] else {
              return []
            }
            return [String](repeating: reward.graphID, count: count)
          }

        let locationId = selectedShippingRule.flatMap { String($0.location.id) }

        return CreateCheckoutInput(
          projectId: project.graphID,
          amount: String(format: "%.2f", pledgeTotal),
          locationId: locationId,
          rewardIds: rewardsIDs,
          refParam: refTag?.stringTag
        )
      }
      .switchMap { input in
        AppEnvironment.current.apiService
          .createCheckout(input: input)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .materialize()
      }

    let checkoutValues = createCheckoutEvents.values()
      .map { values in
        var checkoutId = values.checkout.id
        var backingId = values.checkout.backingId

        if let decoded = decodeBase64(checkoutId), let range = decoded.range(of: "Checkout-") {
          let id = decoded[range.upperBound...]
          checkoutId = String(id)
        }

        return (checkoutId, backingId)
      }

    self.createCheckoutSuccess = checkoutValues.withLatestFrom(
      Signal.combineLatest(
        initialData,
        bonusOrPledgeUpdatedAmount,
        optionalShippingSummaryData,
        pledgeTotal,
        baseReward,
        selectedShippingRule
      )
    )
    .map { checkoutAndBackingId, otherData -> PostCampaignCheckoutData in
      let (checkoutId, backingId) = checkoutAndBackingId
      let (initialData, bonusOrReward, shipping, pledgeTotal, baseReward, shippingRule) = otherData
      var rewards = initialData.rewards
      var bonus = bonusOrReward
      if let reward = rewards.first, reward.isNoReward {
        rewards[0] = reward
          |> Reward.lens.minimum .~ bonusOrReward
          |> Reward.lens.title .~ Strings.Pledge_without_a_reward()
        bonus = 0
      }

      return PostCampaignCheckoutData(
        project: initialData.project,
        baseReward: baseReward,
        rewards: rewards,
        selectedQuantities: initialData.selectedQuantities,
        bonusAmount: bonus == 0 ? nil : bonus,
        total: pledgeTotal,
        shipping: shipping,
        refTag: initialData.refTag,
        context: initialData.context,
        checkoutId: checkoutId,
        backingId: backingId,
        selectedShippingRule: shippingRule
      )
    }

    self.showErrorBannerWithMessage = createCheckoutEvents.errors()
      .map { _ in Strings.Something_went_wrong_please_try_again() }
  }

  // MARK: - Inputs

  private let continueCTATappedProperty = MutableProperty(())
  public func continueCTATapped() {
    self.continueCTATappedProperty.value = ()
  }

  private let configureWithDataProperty = MutableProperty<PledgeViewData?>(nil)
  public func configure(with data: PledgeViewData) {
    self.configureWithDataProperty.value = data
  }

  private let continueButtonTappedProperty = MutableProperty(())
  public func continueButtonTapped() {
    self.continueButtonTappedProperty.value = ()
  }

  private let (pledgeAmountDataSignal, pledgeAmountObserver) = Signal<PledgeAmountData, Never>.pipe()
  public func pledgeAmountViewControllerDidUpdate(with data: PledgeAmountData) {
    self.pledgeAmountObserver.send(value: data)
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

  public let configureCTAWithPledgeTotal: Signal<(Project, Double), Never>
  public let configureLocalPickupViewWithData: Signal<PledgeLocalPickupViewData, Never>
  public let configurePledgeAmountViewWithData: Signal<PledgeAmountViewConfigData, Never>
  public let configurePledgeRewardsSummaryViewWithData: Signal<(
    PostCampaignRewardsSummaryViewData,
    Double?,
    PledgeSummaryViewData
  ), Never>
  public let configurePledgeSummaryViewControllerWithData: Signal<PledgeSummaryViewData, Never>
  public let createCheckoutSuccess: Signal<PostCampaignCheckoutData, Never>
  public let goToLoginSignup: Signal<(LoginIntent, Project, Reward?), Never>
  public let localPickupViewHidden: Signal<Bool, Never>
  public let pledgeAmountViewHidden: Signal<Bool, Never>
  public let pledgeRewardsSummaryViewHidden: Signal<Bool, Never>
  public let pledgeSummaryViewHidden: Signal<Bool, Never>
  public let showErrorBannerWithMessage: Signal<String, Never>

  public var inputs: NoShippingConfirmDetailsViewModelInputs { return self }
  public var outputs: NoShippingConfirmDetailsViewModelOutputs { return self }
}

// MARK: - Helper Functions

private func pledgeSummaryViewData(
  project: Project,
  total: Double,
  confirmationLabelHidden: Bool
) -> PledgeSummaryViewData {
  return (project, total, confirmationLabelHidden)
}
