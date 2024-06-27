import Foundation
import KsApi
import PassKit
import Prelude
import ReactiveSwift
import Stripe

public struct PostCampaignCheckoutData: Equatable {
  public let project: Project
  public let baseReward: Reward
  public let rewards: [Reward]
  public let selectedQuantities: SelectedRewardQuantities
  public let bonusAmount: Double?
  public let total: Double
  public let shipping: PledgeShippingSummaryViewData?
  public let refTag: RefTag?
  public let context: PledgeViewContext
  public let checkoutId: String
}

public struct PostCampaignPaymentAuthorizationData: Equatable {
  public let project: Project
  public let hasNoReward: Bool
  public let subtotal: Double
  public let bonus: Double
  public let shipping: Double
  public let total: Double
  public let merchantIdentifier: String
  public let paymentIntent: String
}

public struct PaymentSourceValidation {
  public let paymentIntentClientSecret: String
  public let selectedCardStripeCardId: String?
  public let requiresConfirmation: Bool
}

public protocol PostCampaignCheckoutViewModelInputs {
  func checkoutTerminated()
  func configure(with data: PostCampaignCheckoutData)
  func confirmPaymentSuccessful(clientSecret: String)
  func creditCardSelected(source: PaymentSourceSelected)
  func pledgeDisclaimerViewDidTapLearnMore()
  func submitButtonTapped()
  func termsOfUseTapped(with: HelpType)
  func viewDidLoad()
}

public protocol PostCampaignCheckoutViewModelOutputs {
  var configurePaymentMethodsViewControllerWithValue: Signal<PledgePaymentMethodsValue, Never> { get }
  var configurePledgeRewardsSummaryViewWithData: Signal<
    (PostCampaignRewardsSummaryViewData, Double?, PledgeSummaryViewData),
    Never
  > { get }
  var configurePledgeViewCTAContainerView: Signal<PledgeViewCTAContainerViewData, Never> { get }
  var configureStripeIntegration: Signal<StripeConfigurationData, Never> { get }
  var processingViewIsHidden: Signal<Bool, Never> { get }
  var showErrorBannerWithMessage: Signal<String, Never> { get }
  var showWebHelp: Signal<HelpType, Never> { get }
  var validateCheckoutSuccess: Signal<PaymentSourceValidation, Never> { get }
  var checkoutComplete: Signal<ThanksPageData, Never> { get }
  var checkoutError: Signal<ErrorEnvelope, Never> { get }
}

public protocol PostCampaignCheckoutViewModelType {
  var inputs: PostCampaignCheckoutViewModelInputs { get }
  var outputs: PostCampaignCheckoutViewModelOutputs { get }
  var applePayViewModel: ApplePayCheckoutViewModel { get }
}

/*
 viewDidLoad
 configure
 selectedCard
 validate
 submit
 complete or terminate
 */

public class PostCampaignCheckoutViewModel: PostCampaignCheckoutViewModelType,
  PostCampaignCheckoutViewModelInputs,
  PostCampaignCheckoutViewModelOutputs {
  /// ApplePay Service isn't  injected directly because it needs access to initial config data as well as the StripeIntentService
  public let applePayViewModel: ApplePayCheckoutViewModel
  let stripeIntentService: StripeIntentServiceType

  public init(stripeIntentService: StripeIntentServiceType) {
    let initialData = Signal.combineLatest(
      self.configureWithDataProperty.signal,
      self.viewDidLoadProperty.signal
    )
    .map(first)
    .skipNil()

    // MARK: Dependencies

    self.stripeIntentService = stripeIntentService
    self.applePayViewModel = ApplePayCheckoutViewModel(
      withConfigurationSignal: initialData,
      stripeIntentService: self.stripeIntentService
    )

    // MARK: Initial Config Data

    let context = initialData.map(\.context)
    let checkoutId = initialData.map(\.checkoutId)
    let baseReward = initialData.map(\.rewards).map(\.first)

    self.configurePaymentMethodsViewControllerWithValue = Signal.combineLatest(initialData, checkoutId)
      .compactMap { data, checkoutId -> PledgePaymentMethodsValue? in
        guard let user = AppEnvironment.current.currentUser else { return nil }
        let reward = data.baseReward

        return (user, data.project, checkoutId, reward, data.context, data.refTag)
      }

    self.showWebHelp = Signal.merge(
      self.termsOfUseTappedSignal,
      self.pledgeDisclaimerViewDidTapLearnMoreSignal.mapConst(.trust)
    )

    self.configurePledgeRewardsSummaryViewWithData = initialData
      .compactMap { data in
        let rewardsData = PostCampaignRewardsSummaryViewData(
          rewards: data.rewards,
          selectedQuantities: data.selectedQuantities,
          projectCountry: data.project.country,
          omitCurrencyCode: data.project.stats.omitUSCurrencyCode,
          shipping: data.shipping
        )
        let pledgeData = PledgeSummaryViewData(
          project: data.project,
          total: data.total,
          confirmationLabelHidden: true
        )
        return (rewardsData, data.bonusAmount, pledgeData)
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

    // MARK: Validate Checkout Details On Submit

    let selectedCard = self.creditCardSelectedProperty.signal.skipNil()

    let processingViewIsHidden = MutableProperty<Bool>(true)

    // MARK: - Validate Existing Cards

    let newPaymentIntentForExistingCards = Signal.combineLatest(initialData, checkoutId)
      .takeWhen(selectedCard)
      .switchMap { initialData, checkoutId in
        let projectId = initialData.project.graphID
        let pledgeTotal = initialData.total

        return stripeIntentService.createPaymentIntent(
          for: projectId,
          checkoutId: checkoutId,
          pledgeTotal: pledgeTotal
        )
        .materialize()
      }

    let paymentIntentClientSecretForExistingCards = newPaymentIntentForExistingCards.values()
      .map { $0.clientSecret }

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

    // MARK: Apple Pay

    /// See ApplePayCheckoutViewModel.swift

    let applePayErrors = Signal.merge(
      self.applePayViewModel.createNewPaymentIntentError,
      self.applePayViewModel.validateCheckoutError
    )

    let validateCheckoutExistingCardError = validateCheckoutExistingCard.errors()

    self.showErrorBannerWithMessage = self.applePayViewModel.validateCheckoutError
      .map { error in
        switch error.ksrCode {
        case .ValidateCheckoutError:
          return error.errorMessages.first ?? Strings.Something_went_wrong_please_try_again()
        default:
          return Strings.Something_went_wrong_please_try_again()
        }
      }

    // MARK: CompleteOnSessionCheckout

    let completeCheckoutWithCreditCardInput: Signal<GraphAPI.CompleteOnSessionCheckoutInput, Never> = Signal
      .combineLatest(self.confirmPaymentSuccessfulProperty.signal.skipNil(), checkoutId, selectedCard)
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

    let checkoutCompleteSignal = Signal
      .merge(
        completeCheckoutWithCreditCardInput,
        self.applePayViewModel.completeCheckoutWithApplePayInput
      )
      .switchMap { input in
        AppEnvironment.current.apiService.completeOnSessionCheckout(input: input).materialize()
      }

    let thanksPageData = Signal.combineLatest(initialData, baseReward)
      .map { initialData, baseReward -> ThanksPageData? in
        guard let reward = baseReward else { return nil }

        return (initialData.project, reward, nil, initialData.total)
      }

    self.checkoutComplete = thanksPageData.skipNil()
      .takeWhen(checkoutCompleteSignal.signal.values())
      .map { $0 }

    self.checkoutError = checkoutCompleteSignal.signal.errors()

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
      context
    )
    .map { pledgeButtonEnabled, context in
      PledgeViewCTAContainerViewData(
        isLoggedIn: true, // Users should always be logged in when they get to the Checkout screen.
        isEnabled: pledgeButtonEnabled,
        context: context,
        willRetryPaymentMethod: false // Only retry in the `fixPaymentMethod` context.
      )
    }

    self.processingViewIsHidden = Signal.merge(
      // Processing view starts hidden, so show at the start of a pledge flow.
      self.submitButtonTappedProperty.signal.mapConst(false),
      self.applePayViewModel.applePayButtonTappedSignal.mapConst(false),
      // Hide view again whenever pledge flow is completed/cancelled/errors.
      applePayErrors.mapConst(true),
      validateCheckoutExistingCardError.mapConst(true),
      self.checkoutTerminatedProperty.signal.mapConst(true),
      checkoutCompleteSignal.signal.mapConst(true)
    )

    // MARK: - Tracking

    // Page viewed event
    initialData
      .observeValues { data in
        AppEnvironment.current.ksrAnalytics.trackCheckoutPaymentPageViewed(
          project: data.project,
          reward: data.baseReward,
          pledgeViewContext: data.context,
          checkoutData: self.trackingDataFromCheckoutParams(data),
          refTag: data.refTag
        )
      }

    // Pledge button tapped event
    initialData
      .takeWhen(self.submitButtonTappedProperty.signal)
      .observeValues { data in
        AppEnvironment.current.ksrAnalytics.trackPledgeSubmitButtonClicked(
          project: data.project,
          reward: data.baseReward,
          typeContext: .creditCard,
          checkoutData: self.trackingDataFromCheckoutParams(data),
          refTag: data.refTag
        )
      }

    // Apple pay button tapped event
    initialData
      .takeWhen(self.applePayViewModel.applePayButtonTappedSignal)
      .observeValues { data in
        AppEnvironment.current.ksrAnalytics.trackPledgeSubmitButtonClicked(
          project: data.project,
          reward: data.baseReward,
          typeContext: .applePay,
          checkoutData: self.trackingDataFromCheckoutParams(data, isApplePay: true),
          refTag: data.refTag
        )
      }
  }

  // MARK: - Helpers

  private func trackingDataFromCheckoutParams(
    _ data: PostCampaignCheckoutData,
    isApplePay: Bool = false
  )
    -> KSRAnalytics.CheckoutPropertiesData {
    return checkoutProperties(
      from: data.project,
      baseReward: data.baseReward,
      addOnRewards: data.rewards,
      selectedQuantities: data.selectedQuantities,
      additionalPledgeAmount: data.bonusAmount ?? 0,
      pledgeTotal: data.total,
      shippingTotal: data.shipping?.total ?? 0,
      checkoutId: data.checkoutId,
      isApplePay: isApplePay
    )
  }

  // MARK: - Inputs

  private let checkoutTerminatedProperty = MutableProperty(())
  public func checkoutTerminated() {
    self.checkoutTerminatedProperty.value = ()
  }

  private let configureWithDataProperty = MutableProperty<PostCampaignCheckoutData?>(nil)
  public func configure(with data: PostCampaignCheckoutData) {
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

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  // MARK: - Outputs

  public let configurePaymentMethodsViewControllerWithValue: Signal<PledgePaymentMethodsValue, Never>
  public let configurePledgeRewardsSummaryViewWithData: Signal<(
    PostCampaignRewardsSummaryViewData,
    Double?,
    PledgeSummaryViewData
  ), Never>
  public let configurePledgeViewCTAContainerView: Signal<PledgeViewCTAContainerViewData, Never>
  public let configureStripeIntegration: Signal<StripeConfigurationData, Never>
  public let processingViewIsHidden: Signal<Bool, Never>
  public let showErrorBannerWithMessage: Signal<String, Never>
  public let showWebHelp: Signal<HelpType, Never>
  public let validateCheckoutSuccess: Signal<PaymentSourceValidation, Never>
  public let checkoutComplete: Signal<ThanksPageData, Never>
  public let checkoutError: Signal<ErrorEnvelope, Never>

  public var inputs: PostCampaignCheckoutViewModelInputs { return self }
  public var outputs: PostCampaignCheckoutViewModelOutputs { return self }
}
