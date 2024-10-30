import Foundation
import KsApi
import PassKit
import Prelude
import ReactiveSwift

public typealias NoShippingPledgeViewCTAContainerViewData = (
  project: Project,
  total: Double,
  isLoggedIn: Bool,
  isEnabled: Bool,
  context: PledgeViewContext,
  willRetryPaymentMethod: Bool
)

public protocol NoShippingPledgeViewModelInputs {
  func applePayButtonTapped()
  func configure(with data: PledgeViewData)
  func creditCardSelected(with paymentSourceData: PaymentSourceSelected)
  func goToLoginSignupTapped()
  func paymentAuthorizationDidAuthorizePayment(
    paymentData: (displayName: String?, network: String?, transactionIdentifier: String)
  )
  func paymentAuthorizationViewControllerDidFinish()
  func pledgeAmountViewControllerDidUpdate(with data: PledgeAmountData)
  func pledgeDisclaimerViewDidTapLearnMore()
  func scaFlowCompleted(with result: StripePaymentHandlerActionStatusType, error: Error?)
  func stripeTokenCreated(token: String?, error: Error?) -> PKPaymentAuthorizationStatus
  func submitButtonTapped()
  func termsOfUseTapped(with: HelpType)
  func userSessionStarted()
  func viewDidLoad()
}

public protocol NoShippingPledgeViewModelOutputs {
  var beginSCAFlowWithClientSecret: Signal<String, Never> { get }
  var configureEstimatedShippingView: Signal<(String?, String?), Never> { get }
  var configureLocalPickupViewWithData: Signal<PledgeLocalPickupViewData, Never> { get }
  var configurePaymentMethodsViewControllerWithValue: Signal<PledgePaymentMethodsValue, Never> { get }
  var configurePledgeAmountViewWithData: Signal<PledgeAmountViewConfigData, Never> { get }
  var configurePledgeAmountSummaryViewControllerWithData: Signal<PledgeAmountSummaryViewData, Never> { get }
  var configurePledgeRewardsSummaryViewWithData: Signal<
    (PostCampaignRewardsSummaryViewData, Double?, PledgeSummaryViewData),
    Never
  > { get }
  var configurePledgeViewCTAContainerView: Signal<NoShippingPledgeViewCTAContainerViewData, Never> { get }
  var configureStripeIntegration: Signal<StripeConfigurationData, Never> { get }
  var descriptionSectionSeparatorHidden: Signal<Bool, Never> { get }
  var estimatedShippingViewHidden: Signal<Bool, Never> { get }
  var goToApplePayPaymentAuthorization: Signal<PaymentAuthorizationData, Never> { get }
  var goToThanks: Signal<ThanksPageData, Never> { get }
  var goToLoginSignup: Signal<(LoginIntent, Project, Reward), Never> { get }
  var localPickupViewHidden: Signal<Bool, Never> { get }
  var notifyDelegateUpdatePledgeDidSucceedWithMessage: Signal<String, Never> { get }
  var notifyPledgeAmountViewControllerUnavailableAmountChanged: Signal<Double, Never> { get }
  var paymentMethodsViewHidden: Signal<Bool, Never> { get }
  var pledgeAmountViewHidden: Signal<Bool, Never> { get }
  var pledgeAmountSummaryViewHidden: Signal<Bool, Never> { get }
  var popToRootViewController: Signal<(), Never> { get }
  var processingViewIsHidden: Signal<Bool, Never> { get }
  var showApplePayAlert: Signal<(String, String), Never> { get }
  var showErrorBannerWithMessage: Signal<String, Never> { get }
  var showWebHelp: Signal<HelpType, Never> { get }
  var title: Signal<String, Never> { get }
  var showPledgeOverTimeUI: Signal<Bool, Never> { get }
}

public protocol NoShippingPledgeViewModelType {
  var inputs: NoShippingPledgeViewModelInputs { get }
  var outputs: NoShippingPledgeViewModelOutputs { get }
}

public class NoShippingPledgeViewModel: NoShippingPledgeViewModelType, NoShippingPledgeViewModelInputs,
  NoShippingPledgeViewModelOutputs {
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
    let selectedShippingRule = initialData.map(\.selectedShippingRule)
    let refTag = initialData.map(\.refTag)
    let context = initialData.map(\.context)

    let initialDataUnpacked = Signal.zip(project, baseReward, refTag, context)

    let backing = project.map { $0.personalization.backing }.skipNil()
    self.showPledgeOverTimeUI = project.signal.map { $0.isPledgeOverTimeAllowed }

    self.pledgeAmountViewHidden = context.map { $0.pledgeAmountViewHidden }
    self.pledgeAmountSummaryViewHidden = Signal.zip(baseReward, context).map { baseReward, context in
      (baseReward.isNoReward && context == .update) || context.pledgeAmountSummaryViewHidden
    }

    self.descriptionSectionSeparatorHidden = Signal.combineLatest(context, baseReward)
      .map { context, reward in
        if context.isAny(of: .pledge, .updateReward) {
          return reward.isNoReward == false
        }

        return context.sectionSeparatorsHidden
      }

    let isLoggedIn = Signal.merge(initialData.ignoreValues(), self.userSessionStartedSignal)
      .map { _ in AppEnvironment.current.currentUser }
      .map(isNotNil)

    let allRewardsTotal = Signal.combineLatest(
      rewards,
      selectedQuantities
    )
    .map(calculateAllRewardsTotal)

    let initialShippingTotal = project.map { project in
      guard let backing = project.personalization.backing else {
        return 0.0
      }
      return backing.shippingAmount ?? 0.0
    }

    let calculatedShippingTotal = Signal.combineLatest(
      selectedShippingRule.skipNil(),
      rewards,
      selectedQuantities
    )
    .map(calculateShippingTotal)

    let allRewardsShippingTotal = Signal.merge(
      initialShippingTotal,
      calculatedShippingTotal
    )

    // Initial pledge amount is zero if not backed and not set previously in the flow.
    let initialAdditionalPledgeAmount = initialData.map {
      if let bonusSupport = $0.bonusSupport {
        return bonusSupport
      } else if let backing = $0.project.personalization.backing {
        return backing.bonusAmount
      } else {
        return 0.0
      }
    }

    // TODO(MBL-1670): Delete the additional pledge amount, any validation, and the stepper class.
    let additionalPledgeAmount = Signal.merge(
      self.pledgeAmountDataSignal.map { $0.amount },
      initialAdditionalPledgeAmount
    )

    self.notifyPledgeAmountViewControllerUnavailableAmountChanged = allRewardsTotal

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

    /**
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

    self.configureLocalPickupViewWithData = projectAndReward
      .switchMap { projectAndReward -> SignalProducer<PledgeLocalPickupViewData?, Never> in
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
     * the total of all rewards
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

    // The selected shipping rule, if present, is always the most up-to-date shipping information.
    // If not present, get shipping location from the backing instead.
    let shippingLocation: Signal<String?, Never> = Signal.combineLatest(project, selectedShippingRule)
      .map { project, shippingRule in
        if let shippingRule {
          return shippingRule.location.localizedName
        }
        if let backing = project.personalization.backing {
          return backing.locationName
        }
        return nil
      }

    let shippingSummaryViewDataNonnil = Signal.combineLatest(
      shippingLocation.skipNil(),
      project.map(\.stats.omitUSCurrencyCode),
      project.map { project in
        projectCountry(forCurrency: project.stats.currency) ?? project.country
      },
      allRewardsShippingTotal
    )
    .map(PledgeShippingSummaryViewData.init)

    let shippingSummaryViewData = Signal.merge(
      shippingSummaryViewDataNonnil.wrapInOptional(),
      shippingLocation.filter(isNil).mapConst(nil)
    )

    self.configurePledgeRewardsSummaryViewWithData = Signal.combineLatest(
      initialData,
      pledgeTotal,
      additionalPledgeAmount,
      shippingSummaryViewData,
      rewards
    )
    .compactMap { data, pledgeTotal, additionalPledgeAmount, shipping, rewards in
      let rewardsData = PostCampaignRewardsSummaryViewData(
        rewards: data.rewards,
        selectedQuantities: data.selectedQuantities,
        projectCountry: data.project.country,
        omitCurrencyCode: data.project.stats.omitUSCurrencyCode,
        shipping: shipping
      )
      let pledgeData = PledgeSummaryViewData(
        project: data.project,
        total: pledgeTotal,
        confirmationLabelHidden: true,
        pledgeHasNoReward: pledgeHasNoRewards(rewards: rewards)
      )
      return (rewardsData, additionalPledgeAmount, pledgeData)
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

    let configurePaymentMethodsViewController = Signal.merge(
      initialDataUnpacked,
      initialDataUnpacked.takeWhen(self.userSessionStartedSignal)
    )

    self.configurePaymentMethodsViewControllerWithValue = configurePaymentMethodsViewController
      .filter { !$3.paymentMethodsViewHidden }
      .compactMap { project, reward, refTag, context -> PledgePaymentMethodsValue? in
        guard let user = AppEnvironment.current.currentUser else { return nil }

        // This second to last value - pledgeTotal - is only needed when the payment methods controller
        // is used in late campaign pledges. There is an assert in PledgePaymentMethodsViewModel to ensure
        // we don't accidentally propagate this nan downstream.
        return (user, project, "", reward, context, refTag)
      }

    self.goToLoginSignup = Signal.combineLatest(project, baseReward, self.goToLoginSignupSignal)
      .map { (LoginIntent.backProject, $0.0, $0.1) }

    self.paymentMethodsViewHidden = Signal.combineLatest(isLoggedIn, context)
      .map { !$0 || $1.paymentMethodsViewHidden }

    let pledgeAmountIsValid: Signal<Bool, Never> = self.pledgeAmountDataSignal
      .map { $0.isValid }

    self.configureStripeIntegration = Signal.combineLatest(
      initialData,
      context
    )
    .filter { !$1.paymentMethodsViewHidden }
    .ignoreValues()
    .map { _ in
      (
        Secrets.ApplePay.merchantIdentifier,
        AppEnvironment.current.environmentType.stripePublishableKey
      )
    }

    /// The `selectedPaymentSource` will take the payment source id (A) or the setup intent client secret (B) and map only to `createBackingData` or `updateBackingData`
    let selectedPaymentSource = Signal.merge(
      initialData.mapConst(nil),
      self.creditCardSelectedSignal.wrapInOptional()
    )

    self.showWebHelp = Signal.merge(
      self.termsOfUseTappedSignal,
      self.pledgeDisclaimerViewDidTapLearnMoreSignal.mapConst(.trust)
    )

    self.configureEstimatedShippingView = Signal.combineLatest(
      project,
      rewards,
      selectedShippingRule,
      selectedQuantities
    )
    .map { project, rewards, shippingRule, selectedQuantities in
      guard let rule = shippingRule else { return (nil, nil) }

      return (
        estimatedShippingText(
          for: rewards,
          project: project,
          locationId: rule.location.id,
          selectedQuantities: selectedQuantities
        ),
        estimatedShippingConversionText(
          for: rewards,
          project: project,
          locationId: rule.location.id,
          selectedQuantities: selectedQuantities
        )
      )
    }

    self.estimatedShippingViewHidden = Signal.combineLatest(self.configureEstimatedShippingView, baseReward)
      .map { estimatedShippingStrings, reward in
        let (estimatedShipping, _) = estimatedShippingStrings
        return reward.shipping.enabled == false || estimatedShipping == nil
      }

    // MARK: - Apple Pay

    let changingApplePayPaymentMethod = self.applePayButtonTappedSignal
      .combineLatest(with: context)
      .map(second)
      .filter { $0 == .changePaymentMethod }
      .ignoreValues()

    let goToApplePayPaymentAuthorization = pledgeAmountIsValid
      .takeWhen(self.applePayButtonTappedSignal)
      .filter(isTrue)

    let showApplePayAlert = pledgeAmountIsValid
      .takeWhen(self.applePayButtonTappedSignal)
      .filter(isFalse)

    let paymentAuthorizationData: Signal<PaymentAuthorizationData, Never> = Signal.combineLatest(
      project,
      baseReward,
      allRewardsTotal,
      additionalPledgeAmount,
      allRewardsShippingTotal
    )
    .map { project, reward, allRewardsTotal, additionalPledgeAmount, shippingTotal -> PaymentAuthorizationData in
      let r = (
        project,
        reward,
        allRewardsTotal,
        additionalPledgeAmount,
        shippingTotal,
        Secrets.ApplePay.merchantIdentifier
      ) as PaymentAuthorizationData

      return r
    }

    self.goToApplePayPaymentAuthorization = paymentAuthorizationData
      .takeWhen(goToApplePayPaymentAuthorization)

    let pkPaymentData = self.pkPaymentSignal
      .map { pkPayment -> PKPaymentData? in
        guard let displayName = pkPayment.displayName, let network = pkPayment.network else {
          return nil
        }

        return (displayName, network, pkPayment.transactionIdentifier)
      }

    // MARK: - Create Apple Pay Backing

    let applePayStatusSuccess = Signal.combineLatest(
      self.stripeTokenSignal.skipNil(),
      self.stripeErrorSignal.filter(isNil),
      pkPaymentData.skipNil()
    )
    .mapConst(PKPaymentAuthorizationStatus.success)

    let applePayStatusFailure = Signal.merge(
      self.stripeErrorSignal.skipNil().ignoreValues(),
      self.stripeTokenSignal.filter(isNil).ignoreValues(),
      pkPaymentData.filter(isNil).ignoreValues()
    )
    .mapConst(PKPaymentAuthorizationStatus.failure)

    self.createApplePayBackingStatusProperty <~ Signal.merge(
      applePayStatusSuccess,
      applePayStatusFailure
    )

    let willCreateApplePayBacking = Signal.combineLatest(
      applePayStatusSuccess,
      context
    )
    .map { $1.isCreating }
    .filter(isTrue)

    // MARK: - Update Apple Pay Backing

    let applePayParams = Signal.combineLatest(
      pkPaymentData.skipNil(),
      self.stripeTokenSignal.skipNil()
    )
    .map { paymentData, token in
      (
        paymentData.displayName,
        paymentData.network,
        paymentData.transactionIdentifier,
        token
      )
    }
    .map(ApplePayParams.init)

    let applePayParamsData = Signal.merge(
      initialData.mapConst(nil),
      applePayParams.wrapInOptional()
    )

    // MARK: - Create Backing

    let createBackingData = Signal.combineLatest(
      project,
      rewards,
      pledgeTotal,
      selectedQuantities,
      selectedShippingRule,
      selectedPaymentSource,
      applePayParamsData,
      refTag
    )
    .map {
      project,
        rewards,
        pledgeTotal,
        selectedQuantities,
        selectedShippingRule,
        selectedPaymentSource,
        applePayParams,
        refTag
        -> CreateBackingData in

      var paymentSourceId = selectedPaymentSource?.savedCreditCardId

      return (
        project: project,
        rewards: rewards,
        pledgeTotal: pledgeTotal,
        selectedQuantities: selectedQuantities,
        shippingRule: selectedShippingRule,
        paymentSourceId: paymentSourceId,
        setupIntentClientSecret: nil,
        applePayParams: applePayParams,
        refTag: refTag
      )
    }

    let createButtonTapped = context
      .takeWhen(self.submitButtonTappedSignal)
      .filter { context in context.isCreating }
      .ignoreValues()

    let createBackingDataAndIsApplePay = createBackingData.takePairWhen(
      Signal.merge(
        createButtonTapped.mapConst(false),
        willCreateApplePayBacking
      )
    )

    // Captures the checkoutId immediately and avoids a race condition further down the chain.
    let checkoutIdProperty = MutableProperty<Int?>(nil)
    let processingViewIsHidden = MutableProperty<Bool>(true)

    let createBackingEvents = createBackingDataAndIsApplePay
      .map(CreateBackingInput.input(from:isApplePay:))
      .switchMap { [checkoutIdProperty] input in
        AppEnvironment.current.apiService.createBacking(input: input)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .on(
            starting: {
              processingViewIsHidden.value = false
            },
            terminated: {
              processingViewIsHidden.value = true
            }
          )
          .map { envelope -> StripeSCARequiring in
            checkoutIdProperty.value = decompose(id: envelope.createBacking.checkout.id)
            return envelope as StripeSCARequiring
          }
          .materialize()
      }

    // MARK: - Update Backing

    let updateBackingData = Signal.combineLatest(
      backing,
      rewards,
      pledgeTotal,
      selectedQuantities,
      selectedShippingRule,
      selectedPaymentSource,
      applePayParamsData
    )
    .map {
      backing,
        rewards,
        pledgeTotal,
        selectedQuantities,
        selectedShippingRule,
        selectedPaymentSource,
        applePayParams
        -> UpdateBackingData in
      var paymentSourceId = selectedPaymentSource?.savedCreditCardId

      return (
        backing: backing,
        rewards: rewards,
        pledgeTotal: pledgeTotal,
        selectedQuantities: selectedQuantities,
        shippingRule: selectedShippingRule,
        paymentSourceId: paymentSourceId,
        setupIntentClientSecret: nil,
        applePayParams: applePayParams
      )
    }

    let willUpdateApplePayBacking = Signal.combineLatest(
      applePayStatusSuccess,
      context
    )
    .map { $1.isUpdating }
    .filter(isTrue)

    let updateButtonTapped = context
      .takeWhen(self.submitButtonTappedSignal)
      .filter { context in context.isUpdating }
      .ignoreValues()

    let updateBackingDataAndIsApplePay = updateBackingData.takePairWhen(
      Signal.merge(
        updateButtonTapped.mapConst(false),
        willUpdateApplePayBacking
      )
    )

    let updateBackingEvents = updateBackingDataAndIsApplePay
      .map(UpdateBackingInput.input(from:isApplePay:))
      .switchMap { input in
        AppEnvironment.current.apiService.updateBacking(input: input)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .on(
            starting: {
              processingViewIsHidden.value = false
            },
            terminated: {
              processingViewIsHidden.value = true
            }
          )
          .map { $0 as StripeSCARequiring }
          .materialize()
      }

    let createOrUpdateEvent = Signal.merge(
      createBackingEvents,
      updateBackingEvents
    )

    self.processingViewIsHidden = processingViewIsHidden.signal

    // MARK: - Form Validation

    let amountChangedAndValid = Signal.combineLatest(
      project,
      baseReward,
      self.pledgeAmountDataSignal,
      initialAdditionalPledgeAmount,
      context
    )
    .map(amountValid)

    self.showApplePayAlert = Signal.combineLatest(
      project,
      self.pledgeAmountDataSignal
    )
    .takeWhen(showApplePayAlert)
    .map { project, pledgeAmountData in (project, pledgeAmountData.min, pledgeAmountData.max) }
    .map { project, min, max in
      (
        Strings.Almost_there(),
        Strings.Please_enter_a_pledge_amount_between_min_and_max(
          min: Format
            .currency(
              min,
              country: projectCountry(forCurrency: project.stats.currency) ?? project.country,
              omitCurrencyCode: false
            ),
          max: Format
            .currency(
              max,
              country: projectCountry(forCurrency: project.stats.currency) ?? project.country,
              omitCurrencyCode: false
            )
        )
      )
    }

    let notChangingPaymentMethod = context.map { context in
      context.isUpdating && context != .changePaymentMethod
    }
    .filter(isTrue)

    /// The `paymentMethodChangedAndValid` will do as it before taking the payment source id (A) or the setup intent client secret (B), one or the other for comparison against the existing backing payment source id. It does not care which of two payment sources the id refers to.
    let paymentMethodChangedAndValid = Signal.merge(
      notChangingPaymentMethod.mapConst(false),
      Signal.combineLatest(
        project,
        baseReward,
        self.creditCardSelectedSignal,
        context
      )
      .map(paymentMethodValid)
    )

    let valuesChangedAndValid = Signal.combineLatest(
      amountChangedAndValid,
      paymentMethodChangedAndValid,
      context
    )
    .map(allValuesChangedAndValid)

    let isEnabled = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst(false)
        .take(until: valuesChangedAndValid.ignoreValues()),
      valuesChangedAndValid,
      self.submitButtonTappedSignal.mapConst(false),
      createOrUpdateEvent.filter { $0.isTerminating }.mapConst(true)
    )
    .skipRepeats()

    let isCreateOrUpdateBacking = Signal.merge(
      self.submitButtonTappedSignal.mapConst(true),
      Signal.merge(willUpdateApplePayBacking, willCreateApplePayBacking).mapConst(false)
    )

    // MARK: - Success/Failure

    let scaFlowCompletedWithError = self.scaFlowCompletedWithResultSignal
      .filter { $0.0.status == .failed }
      .map(second)
      .skipNil()

    let scaFlowCompletedWithSuccess = self.scaFlowCompletedWithResultSignal
      .filter { $0.0.status == .succeeded }
      .map(first)
      .ignoreValues()

    let didInitiateApplePayBacking = Signal.merge(
      willCreateApplePayBacking,
      willUpdateApplePayBacking
    )

    let paymentAuthorizationDidFinish = didInitiateApplePayBacking
      .takeWhen(self.paymentAuthorizationDidFinishSignal)

    let createOrUpdateApplePayBackingCompleted = Signal.zip(
      didInitiateApplePayBacking,
      createOrUpdateEvent.filter { $0.isTerminating }.ignoreValues(),
      paymentAuthorizationDidFinish
    )

    let valuesOrNil = Signal.merge(
      createOrUpdateEvent.values().wrapInOptional(),
      isCreateOrUpdateBacking.mapConst(nil)
    )

    let createOrUpdateBackingEventValuesNoSCA = valuesOrNil
      .skipNil()
      .filter(requiresSCA >>> isFalse)

    let createOrUpdateBackingDidCompleteNoSCA = isCreateOrUpdateBacking
      .takeWhen(createOrUpdateBackingEventValuesNoSCA)
      .filter(isTrue)
      .ignoreValues()

    let createOrUpdateBackingEventValuesRequiresSCA = valuesOrNil
      .skipNil()
      .filter(requiresSCA)

    self.beginSCAFlowWithClientSecret = createOrUpdateBackingEventValuesRequiresSCA
      .map { $0.clientSecret }
      .skipNil()

    let didCompleteApplePayBacking = valuesOrNil
      .takeWhen(createOrUpdateApplePayBackingCompleted)
      .skipNil()

    let creatingContext = context.filter { $0.isCreating }

    let createBackingCompletionEvents = Signal.merge(
      didCompleteApplePayBacking.combineLatest(with: willCreateApplePayBacking).ignoreValues(),
      createOrUpdateBackingDidCompleteNoSCA.combineLatest(with: creatingContext).ignoreValues(),
      scaFlowCompletedWithSuccess.combineLatest(with: creatingContext).ignoreValues()
    )

    let thanksPageData = Signal.combineLatest(
      createBackingDataAndIsApplePay,
      checkoutIdProperty.signal,
      baseReward,
      additionalPledgeAmount,
      allRewardsShippingTotal
    )
    .map { dataAndIsApplePay, checkoutId, baseReward, additionalPledgeAmount, shippingTotal
      -> (CreateBackingData, Bool, String?, Reward, Double, Double) in
      let (data, isApplePay) = dataAndIsApplePay
      guard let checkoutId = checkoutId else {
        return (
          data,
          isApplePay,
          nil,
          baseReward,
          additionalPledgeAmount,
          shippingTotal
        )
      }
      return (
        data,
        isApplePay,
        String(checkoutId),
        baseReward,
        additionalPledgeAmount,
        shippingTotal
      )
    }
    .map { data, isApplePay, checkoutId, baseReward, additionalPledgeAmount, shippingTotal
      -> ThanksPageData? in
      let checkoutPropsData = checkoutProperties(
        from: data.project,
        baseReward: baseReward,
        addOnRewards: data.rewards,
        selectedQuantities: data.selectedQuantities,
        additionalPledgeAmount: additionalPledgeAmount,
        pledgeTotal: data.pledgeTotal,
        shippingTotal: shippingTotal,
        checkoutId: checkoutId,
        isApplePay: isApplePay
      )

      return (data.project, baseReward, checkoutPropsData, data.pledgeTotal)
    }
    .skipNil()

    self.goToThanks = thanksPageData
      .takeWhen(createBackingCompletionEvents)

    let errorsOrNil = Signal.merge(
      createOrUpdateEvent.errors().wrapInOptional(),
      isCreateOrUpdateBacking.mapConst(nil)
    )

    let createOrUpdateApplePayBackingError = createOrUpdateApplePayBackingCompleted
      .withLatest(from: errorsOrNil)
      .map(second)
      .skipNil()

    let createOrUpdateBackingError = isCreateOrUpdateBacking
      .takePairWhen(errorsOrNil.skipNil())
      .filter(first >>> isTrue)
      .map(second)

    let updatingContext = context.filter { $0.isUpdating }

    let updateBackingCompletionEvents = Signal.merge(
      didCompleteApplePayBacking.combineLatest(with: willUpdateApplePayBacking).ignoreValues(),
      createOrUpdateBackingDidCompleteNoSCA.combineLatest(with: updatingContext).ignoreValues(),
      scaFlowCompletedWithSuccess.combineLatest(with: updatingContext).ignoreValues()
    )

    self.notifyDelegateUpdatePledgeDidSucceedWithMessage = updateBackingCompletionEvents
      .mapConst(Strings.Got_it_your_changes_have_been_saved())

    let graphErrors = Signal.merge(
      createOrUpdateApplePayBackingError,
      createOrUpdateBackingError
    )
    .map { $0.localizedDescription }

    let scaErrors = scaFlowCompletedWithError.map { $0.localizedDescription }

    self.showErrorBannerWithMessage = Signal.merge(
      graphErrors,
      scaErrors
    )

    self.popToRootViewController = self.notifyDelegateUpdatePledgeDidSucceedWithMessage.ignoreValues()

    let willRetryPaymentMethod = Signal.combineLatest(
      context,
      project,
      selectedPaymentSource
    )
    .map { context, project, selectedPaymentSource -> Bool in

      context == .fixPaymentMethod
        && project.personalization.backing?.paymentSource?.id == selectedPaymentSource?.savedCreditCardId
    }
    .skipRepeats()

    self.configurePledgeViewCTAContainerView = Signal.combineLatest(
      project,
      pledgeTotal.skipRepeats(),
      isLoggedIn,
      isEnabled,
      context,
      willRetryPaymentMethod
    )
    .map { $0 as NoShippingPledgeViewCTAContainerViewData }

    self.title = context.map { $0.title }

    let trackCheckoutPageViewData = Signal.zip(
      project,
      baseReward,
      rewards,
      selectedQuantities,
      refTag,
      initialAdditionalPledgeAmount,
      pledgeTotal,
      context
    )

    // MARK: - Tracking

    trackCheckoutPageViewData
      .observeValues { project, baseReward, rewards, selectedQuantities, refTag, additionalPledgeAmount, pledgeTotal, pledgeViewContext in
        let checkoutData = checkoutProperties(
          from: project,
          baseReward: baseReward,
          addOnRewards: rewards,
          selectedQuantities: selectedQuantities,
          additionalPledgeAmount: additionalPledgeAmount,
          pledgeTotal: pledgeTotal,
          shippingTotal: 0,
          checkoutId: nil,
          isApplePay: false
        )

        AppEnvironment.current.ksrAnalytics.trackCheckoutPaymentPageViewed(
          project: project,
          reward: baseReward,
          pledgeViewContext: pledgeViewContext,
          checkoutData: checkoutData,
          refTag: refTag
        )
      }

    let pledgeSubmitEventsSignal = Signal.combineLatest(
      createBackingData,
      baseReward,
      additionalPledgeAmount
    )

    // Pledge pledge_submit event
    pledgeSubmitEventsSignal
      .takeWhen(self.submitButtonTappedSignal)
      .map { data, baseReward, additionalPledgeAmount in
        let checkoutData = checkoutProperties(
          from: data.project,
          baseReward: baseReward,
          addOnRewards: data.rewards,
          selectedQuantities: data.selectedQuantities,
          additionalPledgeAmount: additionalPledgeAmount,
          pledgeTotal: data.pledgeTotal,
          shippingTotal: 0,
          checkoutId: nil,
          isApplePay: false
        )

        return (data.project, baseReward, data.refTag, checkoutData)
      }
      .observeValues { project, reward, refTag, checkoutData in
        AppEnvironment.current.ksrAnalytics.trackPledgeSubmitButtonClicked(
          project: project,
          reward: reward,
          typeContext: .creditCard,
          checkoutData: checkoutData,
          refTag: refTag
        )
      }

    // Pay With Apple pledge_submit event
    pledgeSubmitEventsSignal
      .takeWhen(self.applePayButtonTappedSignal)
      .map { data, baseReward, additionalPledgeAmount in
        let checkoutData = checkoutProperties(
          from: data.project,
          baseReward: baseReward,
          addOnRewards: data.rewards,
          selectedQuantities: data.selectedQuantities,
          additionalPledgeAmount: additionalPledgeAmount,
          pledgeTotal: data.pledgeTotal,
          shippingTotal: 0,
          checkoutId: nil,
          isApplePay: true
        )

        return (data.project, baseReward, data.refTag, checkoutData)
      }
      .observeValues { project, reward, refTag, checkoutData in
        AppEnvironment.current.ksrAnalytics.trackPledgeSubmitButtonClicked(
          project: project,
          reward: reward,
          typeContext: .applePay,
          checkoutData: checkoutData,
          refTag: refTag
        )
      }
  }

  // MARK: - Inputs

  private let (applePayButtonTappedSignal, applePayButtonTappedObserver) = Signal<Void, Never>.pipe()
  public func applePayButtonTapped() {
    self.applePayButtonTappedObserver.send(value: ())
  }

  private let configureWithDataProperty = MutableProperty<PledgeViewData?>(nil)
  public func configure(with data: PledgeViewData) {
    self.configureWithDataProperty.value = data
  }

  private let (creditCardSelectedSignal, creditCardSelectedObserver) = Signal<PaymentSourceSelected, Never>
    .pipe()
  public func creditCardSelected(with paymentSourceData: PaymentSourceSelected) {
    self.creditCardSelectedObserver.send(value: paymentSourceData)
  }

  private let (pkPaymentSignal, pkPaymentObserver) = Signal<(
    displayName: String?,
    network: String?,
    transactionIdentifier: String
  ), Never>.pipe()
  public func paymentAuthorizationDidAuthorizePayment(paymentData: (
    displayName: String?,
    network: String?,
    transactionIdentifier: String
  )) {
    self.pkPaymentObserver.send(value: paymentData)
  }

  private let (paymentAuthorizationDidFinishSignal, paymentAuthorizationDidFinishObserver)
    = Signal<Void, Never>.pipe()
  public func paymentAuthorizationViewControllerDidFinish() {
    self.paymentAuthorizationDidFinishObserver.send(value: ())
  }

  private let (goToLoginSignupSignal, goToLoginSignupObserver) = Signal<Void, Never>.pipe()
  public func goToLoginSignupTapped() {
    self.goToLoginSignupObserver.send(value: ())
  }

  private let (pledgeAmountDataSignal, pledgeAmountObserver) = Signal<PledgeAmountData, Never>.pipe()
  public func pledgeAmountViewControllerDidUpdate(with data: PledgeAmountData) {
    self.pledgeAmountObserver.send(value: data)
  }

  private let (pledgeDisclaimerViewDidTapLearnMoreSignal, pledgeDisclaimerViewDidTapLearnMoreObserver)
    = Signal<Void, Never>.pipe()
  public func pledgeDisclaimerViewDidTapLearnMore() {
    self.pledgeDisclaimerViewDidTapLearnMoreObserver.send(value: ())
  }

  private let (scaFlowCompletedWithResultSignal, scaFlowCompletedWithResultObserver)
    = Signal<(StripePaymentHandlerActionStatusType, Error?), Never>.pipe()
  public func scaFlowCompleted(with result: StripePaymentHandlerActionStatusType, error: Error?) {
    self.scaFlowCompletedWithResultObserver.send(value: (result, error))
  }

  private let (stripeTokenSignal, stripeTokenObserver) = Signal<String?, Never>.pipe()
  private let (stripeErrorSignal, stripeErrorObserver) = Signal<Error?, Never>.pipe()

  private let (submitButtonTappedSignal, submitButtonTappedObserver) = Signal<Void, Never>.pipe()
  public func submitButtonTapped() {
    self.submitButtonTappedObserver.send(value: ())
  }

  private let createApplePayBackingStatusProperty = MutableProperty<PKPaymentAuthorizationStatus>(.failure)
  public func stripeTokenCreated(token: String?, error: Error?) -> PKPaymentAuthorizationStatus {
    self.stripeTokenObserver.send(value: token)
    self.stripeErrorObserver.send(value: error)

    return self.createApplePayBackingStatusProperty.value
  }

  private let (termsOfUseTappedSignal, termsOfUseTappedObserver) = Signal<HelpType, Never>.pipe()
  public func termsOfUseTapped(with helpType: HelpType) {
    self.termsOfUseTappedObserver.send(value: helpType)
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

  public let beginSCAFlowWithClientSecret: Signal<String, Never>
  public let configureEstimatedShippingView: Signal<(String?, String?), Never>
  public let configureLocalPickupViewWithData: Signal<PledgeLocalPickupViewData, Never>
  public let configurePaymentMethodsViewControllerWithValue: Signal<PledgePaymentMethodsValue, Never>
  public let configurePledgeAmountViewWithData: Signal<PledgeAmountViewConfigData, Never>
  public let configurePledgeAmountSummaryViewControllerWithData: Signal<PledgeAmountSummaryViewData, Never>
  public let configurePledgeRewardsSummaryViewWithData: Signal<
    (PostCampaignRewardsSummaryViewData, Double?, PledgeSummaryViewData),
    Never
  >
  public let configurePledgeViewCTAContainerView: Signal<NoShippingPledgeViewCTAContainerViewData, Never>
  public let configureStripeIntegration: Signal<StripeConfigurationData, Never>
  public let descriptionSectionSeparatorHidden: Signal<Bool, Never>
  public let estimatedShippingViewHidden: Signal<Bool, Never>
  public let goToApplePayPaymentAuthorization: Signal<PaymentAuthorizationData, Never>
  public let goToThanks: Signal<ThanksPageData, Never>
  public let goToLoginSignup: Signal<(LoginIntent, Project, Reward), Never>
  public let localPickupViewHidden: Signal<Bool, Never>
  public let notifyDelegateUpdatePledgeDidSucceedWithMessage: Signal<String, Never>
  public let notifyPledgeAmountViewControllerUnavailableAmountChanged: Signal<Double, Never>
  public let paymentMethodsViewHidden: Signal<Bool, Never>
  public let pledgeAmountViewHidden: Signal<Bool, Never>
  public let pledgeAmountSummaryViewHidden: Signal<Bool, Never>
  public let popToRootViewController: Signal<(), Never>
  public let processingViewIsHidden: Signal<Bool, Never>
  public let showErrorBannerWithMessage: Signal<String, Never>
  public let showApplePayAlert: Signal<(String, String), Never>
  public let showWebHelp: Signal<HelpType, Never>
  public let title: Signal<String, Never>
  public let showPledgeOverTimeUI: Signal<Bool, Never>

  public var inputs: NoShippingPledgeViewModelInputs { return self }
  public var outputs: NoShippingPledgeViewModelOutputs { return self }
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
    pledgeAmountData
      .amount != initialAdditionalPledgeAmount || (reward.hasAddOns || featureNoShippingAtCheckout()),
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
  paymentSource: PaymentSourceSelected,
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
  } else if backedPaymentSourceId != paymentSource.savedCreditCardId {
    return true
  }

  return false
}

private func allValuesChangedAndValid(
  amountValid: Bool,
  paymentSourceValid: Bool,
  context: PledgeViewContext
) -> Bool {
  if context.isUpdating, context != .updateReward {
    return amountValid || paymentSourceValid
  }

  return amountValid
}

// MARK: - Helper Functions

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
