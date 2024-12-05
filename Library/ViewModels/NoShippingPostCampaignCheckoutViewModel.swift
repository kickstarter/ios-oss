import Foundation
import KsApi
import PassKit
import Prelude
import ReactiveSwift
import Stripe

public protocol NoShippingPostCampaignCheckoutViewModelInputs {
  func checkoutTerminated()
  func configure(with data: PledgeViewData)
  func confirmPaymentSuccessful(clientSecret: String)
  func creditCardSelected(source: PaymentSourceSelected)
  func goToLoginSignupTapped()
  func pledgeDisclaimerViewDidTapLearnMore()
  func submitButtonTapped()
  func termsOfUseTapped(with: HelpType)
  func userSessionStarted()
  func viewDidLoad()
  func applePayButtonTapped()
  func applePayContextDidCreatePayment(with paymentMethodId: String)
  func applePayContextDidComplete()
}

public protocol NoShippingPostCampaignCheckoutViewModelOutputs {
  var configureEstimatedShippingView: Signal<(String?, String?), Never> { get }
  var configurePaymentMethodsViewControllerWithValue: Signal<PledgePaymentMethodsValue, Never> { get }
  var configurePledgeRewardsSummaryViewWithData: Signal<
    (PostCampaignRewardsSummaryViewData, Double?, PledgeSummaryViewData),
    Never
  > { get }
  var configurePledgeViewCTAContainerView: Signal<PledgeViewCTAContainerViewData, Never> { get }
  var configureStripeIntegration: Signal<StripeConfigurationData, Never> { get }
  var estimatedShippingViewHidden: Signal<Bool, Never> { get }
  var goToLoginSignup: Signal<(LoginIntent, Project, Reward), Never> { get }
  var paymentMethodsViewHidden: Signal<Bool, Never> { get }
  var processingViewIsHidden: Signal<Bool, Never> { get }
  var showErrorBanner: Signal<(message: String, persist: Bool), Never> { get }
  var showWebHelp: Signal<HelpType, Never> { get }
  var validateCheckoutSuccess: Signal<PaymentSourceValidation, Never> { get }
  var goToApplePayPaymentAuthorization: Signal<PostCampaignPaymentAuthorizationData, Never> { get }
  var checkoutComplete: Signal<ThanksPageData, Never> { get }
}

public protocol NoShippingPostCampaignCheckoutViewModelType {
  var inputs: NoShippingPostCampaignCheckoutViewModelInputs { get }
  var outputs: NoShippingPostCampaignCheckoutViewModelOutputs { get }
}

public class NoShippingPostCampaignCheckoutViewModel: NoShippingPostCampaignCheckoutViewModelType,
  NoShippingPostCampaignCheckoutViewModelInputs,
  NoShippingPostCampaignCheckoutViewModelOutputs {
  let stripeIntentService: StripeIntentServiceType

  public init(stripeIntentService: StripeIntentServiceType) {
    self.stripeIntentService = stripeIntentService

    let initialData = Signal.combineLatest(
      self.configureWithDataProperty.signal,
      self.viewDidLoadProperty.signal
    )
    .map(first)
    .skipNil()

    let context = initialData.map(\.context)
    let rewards = initialData.map(\.rewards)
    let baseReward = initialData.map(\.rewards).map(\.first).skipNil()
    let project = initialData.map(\.project)
    let selectedShippingRule = initialData.map(\.selectedShippingRule)
    let selectedQuantities = initialData.map(\.selectedQuantities)
    let refTag = initialData.map(\.refTag)
    let bonusAmount = initialData.map { $0.bonusSupport ?? 0.0 }

    let backing = project.map(\.personalization.backing).skipNil()

    let isLoggedIn = Signal.merge(initialData.ignoreValues(), self.userSessionStartedSignal)
      .map { _ in AppEnvironment.current.currentUser }
      .map(isNotNil)

    // MARK: Calculate totals

    let calculatedShippingTotal = Signal.combineLatest(
      selectedShippingRule.skipNil(),
      rewards,
      selectedQuantities
    )
    .map(calculateShippingTotal)

    let allRewardsShippingTotal = Signal.merge(
      selectedShippingRule.filter(isNil).mapConst(0.0),
      calculatedShippingTotal
    )

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
      bonusAmount,
      allRewardsShippingTotal,
      allRewardsTotal
    )
    .map(calculatePledgeTotal)

    let pledgeTotal = Signal.merge(
      backing.map(\.amount),
      calculatedPledgeTotal
    )

    // MARK: Create checkout

    let pledgeDetailsData = Signal.combineLatest(
      project,
      rewards,
      bonusAmount,
      selectedQuantities,
      selectedShippingRule,
      pledgeTotal,
      refTag
    )

    let createCheckoutEvents = Signal.combineLatest(
      isLoggedIn,
      pledgeDetailsData
    )
    .filter { isLoggedIn, _ in isLoggedIn }
    .map { _, data in
      let (
        project,
        rewards,
        _,
        selectedQuantities,
        selectedShippingRule,
        pledgeTotal,
        refTag
      ) = data
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

    let checkoutId = createCheckoutEvents.values()
      .map { values in
        var checkoutId = values.checkout.id
        if let decoded = decodeBase64(checkoutId), let range = decoded.range(of: "Checkout-") {
          let id = decoded[range.upperBound...]
          checkoutId = String(id)
        }
        return checkoutId
      }

    let backingId = createCheckoutEvents.values().map(\.checkout.backingId)

    let createCheckoutError = createCheckoutEvents.errors()

    // MARK: Configure views

    self.paymentMethodsViewHidden = isLoggedIn.map(negate)

    self.configurePaymentMethodsViewControllerWithValue = Signal.combineLatest(
      project,
      baseReward,
      context,
      refTag,
      checkoutId
    )
    .compactMap { project, reward, context, refTag, checkoutId -> PledgePaymentMethodsValue? in
      guard let user = AppEnvironment.current.currentUser else { return nil }

      return (user, project, checkoutId, reward, context, refTag)
    }

    self.showWebHelp = Signal.merge(
      self.termsOfUseTappedSignal,
      self.pledgeDisclaimerViewDidTapLearnMoreSignal.mapConst(.trust)
    )

    self.configurePledgeRewardsSummaryViewWithData = Signal.combineLatest(
      initialData,
      allRewardsShippingTotal,
      pledgeTotal
    )
    .compactMap { data, shippingTotal, pledgeTotal in
      var rewards = data.rewards
      var bonus = data.bonusSupport
      if let reward = rewards.first, reward.isNoReward, let bonusAmount = bonus {
        rewards[0] = reward
          |> Reward.lens.minimum .~ bonusAmount
          |> Reward.lens.title .~ Strings.Pledge_without_a_reward()
        bonus = 0
      }
      let omitUSCurrencyCode = data.project.stats.omitUSCurrencyCode
      let projectCountry = projectCountry(forCurrency: data.project.stats.currency) ?? data.project.country
      let shippingSummary = data.selectedShippingRule.flatMap {
        PledgeShippingSummaryViewData(
          locationName: $0.location.localizedName,
          omitUSCurrencyCode: omitUSCurrencyCode,
          projectCountry: projectCountry,
          total: shippingTotal
        )
      }
      let rewardsData = PostCampaignRewardsSummaryViewData(
        rewards: data.rewards,
        selectedQuantities: data.selectedQuantities,
        projectCountry: data.project.country,
        omitCurrencyCode: omitUSCurrencyCode,
        shipping: shippingSummary
      )
      let pledgeData = PledgeSummaryViewData(
        project: data.project,
        total: pledgeTotal,
        confirmationLabelHidden: true,
        pledgeHasNoReward: pledgeHasNoRewards(rewards: rewardsData.rewards)
      )
      return (rewardsData, bonus, pledgeData)
    }

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

    self.goToLoginSignup = Signal.combineLatest(project, baseReward)
      .takeWhen(self.goToLoginSignupSignal)
      .map { project, reward in (LoginIntent.backProject, project, reward) }

    // MARK: Create Payment Intent

    let paymentIntentEvent = Signal.combineLatest(
      project,
      pledgeTotal,
      checkoutId,
      backingId
    )
    .switchMap { project, pledgeTotal, checkoutId, backingId in
      let projectId = project.graphID

      return stripeIntentService.createPaymentIntent(
        for: projectId,
        backingId: backingId,
        checkoutId: checkoutId,
        pledgeTotal: pledgeTotal
      )
      .materialize()
    }

    let paymentIntentClientSecret = paymentIntentEvent.values()
      .map { $0.clientSecret }

    let paymentIntentErrors = paymentIntentEvent.errors()

    // MARK: Validate Existing Cards

    let selectedCard = self.creditCardSelectedProperty.signal.skipNil()

    let paymentIntentClientSecretForExistingCards = paymentIntentClientSecret
      .takeWhen(selectedCard)

    let validateCheckoutExistingCardInput = Signal
      .combineLatest(
        checkoutId,
        selectedCard,
        paymentIntentClientSecretForExistingCards
      )

    // Runs validation for pre-existing cards that were created with setup intents originally but require payment intents for late pledges.
    let validateCheckoutExistingCard = validateCheckoutExistingCardInput
      .takeWhen(self.submitButtonTappedProperty.signal)
      .switchMap { checkoutId, selectedCard, paymentIntentClientSecret in

        assert(
          selectedCard.stripePaymentMethodId.isSome && selectedCard.stripePaymentMethodId != "",
          "Payment method ID should not be missing in a late pledge context."
        )

        return AppEnvironment.current.apiService
          .validateCheckout(
            checkoutId: checkoutId,
            paymentSourceId: selectedCard.stripePaymentMethodId ?? "",
            paymentIntentClientSecret: paymentIntentClientSecret
          )
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .materialize()
      }

    self.validateCheckoutSuccess = Signal
      .combineLatest(paymentIntentClientSecretForExistingCards, selectedCard)
      .takeWhen(validateCheckoutExistingCard.values())
      .map { paymentIntentClientSecret, selectedCard in

        PaymentSourceValidation(
          paymentIntentClientSecret: paymentIntentClientSecret,
          selectedCardStripeCardId: selectedCard.stripePaymentMethodId,
          requiresConfirmation: true
        )
      }

    // MARK: ApplePay

    /*

     Order of operations:
     1) Apple pay button tapped
     3) Present the payment authorization form
     4) Payment authorization form calls applePayContextDidCreatePayment with the payment method Id
     5) Payment authorization form calls paymentAuthorizationDidFinish
     6) Validate checkout using the checkoutId, payment source id, and payment intent
     */

    // Ensure all required data exists before assuming apple pay flow starts.
    let startApplePayFlow = Signal.combineLatest(project, pledgeTotal, checkoutId, backingId)
      .takeWhen(self.applePayButtonTappedSignal)

    let paymentIntentClientSecretForApplePay: Signal<String, Never> = paymentIntentClientSecret
      .takeWhen(startApplePayFlow)

    self.goToApplePayPaymentAuthorization = Signal.combineLatest(
      project,
      baseReward,
      allRewardsTotal,
      bonusAmount,
      allRewardsShippingTotal,
      pledgeTotal,
      paymentIntentClientSecretForApplePay
    )
    .map { (
      project,
      baseReward,
      allRewardsTotal,
      bonusAmount,
      allRewardsShippingTotal,
      pledgeTotal,
      paymentIntent: String
    ) -> PostCampaignPaymentAuthorizationData? in

      PostCampaignPaymentAuthorizationData(
        project: project,
        hasNoReward: baseReward.isNoReward,
        subtotal: baseReward.isNoReward ? bonusAmount : allRewardsTotal,
        bonus: baseReward.isNoReward ? 0.0 : bonusAmount,
        shipping: allRewardsShippingTotal,
        total: pledgeTotal,
        merchantIdentifier: Secrets.ApplePay.merchantIdentifier,
        paymentIntent: paymentIntent
      )
    }
    .skipNil()

    let validateCheckoutWithApplePay = Signal.combineLatest(
      paymentIntentClientSecretForApplePay,
      checkoutId,
      self.applePayPaymentMethodIdSignal.signal
    )
    .takeWhen(self.applePayContextDidCompleteSignal)
    .switchMap { (clientSecret: String, checkoutId: String, paymentMethodId: String) in
      AppEnvironment.current.apiService
        .validateCheckout(
          checkoutId: checkoutId,
          paymentSourceId: paymentMethodId,
          paymentIntentClientSecret: clientSecret
        )
        .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
        .materialize()
    }

    let validateCheckoutError = Signal
      .merge(
        validateCheckoutExistingCard.errors(),
        validateCheckoutWithApplePay.errors()
      )

    // MARK: CompleteOnSessionCheckout

    let completeCheckoutWithCreditCardInput: Signal<GraphAPI.CompleteOnSessionCheckoutInput, Never> = Signal
      .combineLatest(self.confirmPaymentSuccessfulProperty.signal.skipNil(), checkoutId, selectedCard)
      .takeWhen(self.confirmPaymentSuccessfulProperty.signal.skipNil())
      .map { (
        clientSecret: String,
        checkoutId: String,
        selectedCard: PaymentSourceSelected
      ) -> GraphAPI.CompleteOnSessionCheckoutInput in

        GraphAPI
          .CompleteOnSessionCheckoutInput(
            checkoutId: encodeToBase64("Checkout-\(checkoutId)"),
            paymentIntentClientSecret: clientSecret,
            paymentSourceId: selectedCard.savedCreditCardId,
            paymentSourceReusable: true,
            applePay: nil
          )
      }

    let completeCheckoutWithApplePayInput: Signal<GraphAPI.CompleteOnSessionCheckoutInput, Never> = Signal
      .combineLatest(paymentIntentClientSecretForApplePay, checkoutId)
      .takeWhen(validateCheckoutWithApplePay.values())
      .map {
        (
          clientSecret: String,
          checkoutId: String
        ) -> GraphAPI.CompleteOnSessionCheckoutInput in
        GraphAPI
          .CompleteOnSessionCheckoutInput(
            checkoutId: encodeToBase64("Checkout-\(checkoutId)"),
            paymentIntentClientSecret: clientSecret,
            paymentSourceId: nil,
            paymentSourceReusable: false,
            /* We are no longer sending ApplePay parameters to the backend, because Stripe Tokens are
              considered deprecated and are incompatible with PaymentIntent-based payments.

              In the future, we may use the other parameters in the ApplePayParams object, but for now,
              send nil.
              */
            applePay: nil
          )
      }

    let checkoutCompleteSignal = Signal
      .merge(
        completeCheckoutWithCreditCardInput,
        completeCheckoutWithApplePayInput
      )
      .switchMap { input in
        AppEnvironment.current.apiService.completeOnSessionCheckout(input: input).materialize()
      }

    let thanksPageData = Signal.combineLatest(project, baseReward, pledgeTotal)
      .compactMap { project, baseReward, pledgeTotal -> ThanksPageData in
        (project, baseReward, nil, pledgeTotal)
      }

    self.checkoutComplete = thanksPageData
      .takeWhen(checkoutCompleteSignal.signal.values())
      .map { $0 }

    let checkoutError = checkoutCompleteSignal.signal.errors()

    // MARK: - Error handling

    self.showErrorBanner = Signal.merge(
      createCheckoutError.map { ($0, true) },
      validateCheckoutError.map { ($0, false) },
      checkoutError.map { ($0, false) }
    )
    .map { error, shouldPersist in
      if error.ksrCode == .ValidateCheckoutError, let message = error.errorMessages.first {
        return (message: message, persist: shouldPersist)
      }

      #if DEBUG
        let serverError = error.errorMessages.first ?? ""
        let message = "\(Strings.Something_went_wrong_please_try_again())\n\(serverError)"
      #else
        let message = Strings.Something_went_wrong_please_try_again()
      #endif

      return (message: message, persist: shouldPersist)
    }

    // MARK: - UI related to checkout flow

    let existingCardActivatesPledgeButton = validateCheckoutExistingCardInput
      .mapConst(true)

    let pledgeButtonEnabled = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst(false),
      existingCardActivatesPledgeButton
    )
    .skipRepeats()

    self.configurePledgeViewCTAContainerView = Signal.combineLatest(
      pledgeButtonEnabled,
      context,
      isLoggedIn
    )
    .map { pledgeButtonEnabled, context, isLoggedIn in
      PledgeViewCTAContainerViewData(
        isLoggedIn: isLoggedIn,
        isEnabled: pledgeButtonEnabled,
        context: context,
        willRetryPaymentMethod: false // Only retry in the `fixPaymentMethod` context.
      )
    }

    self.processingViewIsHidden = Signal.merge(
      // Processing view starts hidden, so show at the start of a pledge flow.
      self.submitButtonTappedProperty.signal.mapConst(false),
      startApplePayFlow.mapConst(false),
      // Hide view again whenever pledge flow is completed/cancelled/errors.
      paymentIntentErrors.mapConst(true),
      validateCheckoutError.mapConst(true),
      self.checkoutTerminatedProperty.signal.mapConst(true),
      checkoutCompleteSignal.signal.mapConst(true)
    )

    // MARK: - Tracking

    // Use checkoutId in tracking, or default to nil if creating it errors.
    let checkoutIdOrNil = Signal.merge(
      checkoutId.wrapInOptional(),
      createCheckoutError.mapConst(nil).take(first: 1)
    )

    let checkoutData = Signal.combineLatest(
      initialData,
      baseReward,
      pledgeTotal,
      allRewardsShippingTotal,
      checkoutIdOrNil
    )

    // Page viewed event
    checkoutData.take(first: 1)
      .observeValues { data, baseReward, pledgeTotal, shippingTotal, checkoutId in
        let checkoutData = self.trackingDataFromCheckoutParams(
          data,
          baseReward: baseReward,
          pledgeTotal: pledgeTotal,
          shippingTotal: shippingTotal,
          checkoutId: checkoutId
        )
        AppEnvironment.current.ksrAnalytics.trackCheckoutPaymentPageViewed(
          project: data.project,
          reward: data.rewards[0],
          pledgeViewContext: data.context,
          checkoutData: checkoutData,
          refTag: data.refTag
        )
      }

    // Pledge button tapped event
    checkoutData
      .takeWhen(self.submitButtonTappedProperty.signal)
      .observeValues { data, baseReward, pledgeTotal, shippingTotal, checkoutId in
        let checkoutData = self.trackingDataFromCheckoutParams(
          data,
          baseReward: baseReward,
          pledgeTotal: pledgeTotal,
          shippingTotal: shippingTotal,
          checkoutId: checkoutId
        )
        AppEnvironment.current.ksrAnalytics.trackPledgeSubmitButtonClicked(
          project: data.project,
          reward: baseReward,
          typeContext: .creditCard,
          checkoutData: checkoutData,
          refTag: data.refTag
        )
      }

    // Apple pay button tapped event
    checkoutData
      .takeWhen(self.applePayButtonTappedSignal)
      .observeValues { data, baseReward, pledgeTotal, shippingTotal, checkoutId in
        let checkoutData = self.trackingDataFromCheckoutParams(
          data,
          baseReward: baseReward,
          pledgeTotal: pledgeTotal,
          shippingTotal: shippingTotal,
          checkoutId: checkoutId,
          isApplePay: true
        )
        AppEnvironment.current.ksrAnalytics.trackPledgeSubmitButtonClicked(
          project: data.project,
          reward: baseReward,
          typeContext: .applePay,
          checkoutData: checkoutData,
          refTag: data.refTag
        )
      }
  }

  // MARK: - Helpers

  private func trackingDataFromCheckoutParams(
    _ data: PledgeViewData,
    baseReward: Reward,
    pledgeTotal: Double,
    shippingTotal: Double,
    checkoutId: String?,
    isApplePay: Bool = false
  )
    -> KSRAnalytics.CheckoutPropertiesData {
    return checkoutProperties(
      from: data.project,
      baseReward: baseReward,
      addOnRewards: data.rewards,
      selectedQuantities: data.selectedQuantities,
      additionalPledgeAmount: data.bonusSupport ?? 0,
      pledgeTotal: pledgeTotal,
      shippingTotal: shippingTotal,
      checkoutId: checkoutId,
      isApplePay: isApplePay
    )
  }

  // MARK: - Inputs

  private let checkoutTerminatedProperty = MutableProperty(())
  public func checkoutTerminated() {
    self.checkoutTerminatedProperty.value = ()
  }

  private let configureWithDataProperty = MutableProperty<PledgeViewData?>(nil)
  public func configure(with data: PledgeViewData) {
    self.configureWithDataProperty.value = data
  }

  private let confirmPaymentSuccessfulProperty = MutableProperty<String?>(nil)
  public func confirmPaymentSuccessful(clientSecret: String) {
    self.confirmPaymentSuccessfulProperty.value = clientSecret
  }

  private let creditCardSelectedProperty =
    MutableProperty<PaymentSourceSelected?>(nil)
  public func creditCardSelected(
    source: PaymentSourceSelected
  ) {
    self.creditCardSelectedProperty.value = source
  }

  private let (goToLoginSignupSignal, goToLoginSignupObserver) = Signal<Void, Never>.pipe()
  public func goToLoginSignupTapped() {
    self.goToLoginSignupObserver.send(value: ())
  }

  private let (pledgeDisclaimerViewDidTapLearnMoreSignal, pledgeDisclaimerViewDidTapLearnMoreObserver)
    = Signal<Void, Never>.pipe()
  public func pledgeDisclaimerViewDidTapLearnMore() {
    self.pledgeDisclaimerViewDidTapLearnMoreObserver.send(value: ())
  }

  private let submitButtonTappedProperty = MutableProperty(())
  public func submitButtonTapped() {
    self.submitButtonTappedProperty.value = ()
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

  private let (applePayButtonTappedSignal, applePayButtonTappedObserver) = Signal<Void, Never>.pipe()
  public func applePayButtonTapped() {
    self.applePayButtonTappedObserver.send(value: ())
  }

  private let (applePayPaymentMethodIdSignal, applePayPaymentMethodIdObserver) = Signal<String, Never>.pipe()
  public func applePayContextDidCreatePayment(with paymentMethodId: String) {
    self.applePayPaymentMethodIdObserver.send(value: paymentMethodId)
  }

  private let (applePayContextDidCompleteSignal, applePayContextDidCompleteObserver)
    = Signal<Void, Never>.pipe()
  public func applePayContextDidComplete() {
    self.applePayContextDidCompleteObserver.send(value: ())
  }

  // MARK: - Outputs

  public let configureEstimatedShippingView: Signal<(String?, String?), Never>
  public let configurePaymentMethodsViewControllerWithValue: Signal<PledgePaymentMethodsValue, Never>
  public let configurePledgeRewardsSummaryViewWithData: Signal<(
    PostCampaignRewardsSummaryViewData,
    Double?,
    PledgeSummaryViewData
  ), Never>
  public let configurePledgeViewCTAContainerView: Signal<PledgeViewCTAContainerViewData, Never>
  public let configureStripeIntegration: Signal<StripeConfigurationData, Never>
  public let estimatedShippingViewHidden: Signal<Bool, Never>
  public let goToLoginSignup: Signal<(LoginIntent, Project, Reward), Never>
  public let processingViewIsHidden: Signal<Bool, Never>
  public let showErrorBanner: Signal<(message: String, persist: Bool), Never>
  public let showWebHelp: Signal<HelpType, Never>
  public let paymentMethodsViewHidden: Signal<Bool, Never>
  public let validateCheckoutSuccess: Signal<PaymentSourceValidation, Never>
  public let goToApplePayPaymentAuthorization: Signal<PostCampaignPaymentAuthorizationData, Never>
  public let checkoutComplete: Signal<ThanksPageData, Never>

  public var inputs: NoShippingPostCampaignCheckoutViewModelInputs { return self }
  public var outputs: NoShippingPostCampaignCheckoutViewModelOutputs { return self }
}
