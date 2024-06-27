import Foundation
import KsApi
import Prelude
import ReactiveSwift

public protocol ApplePayCheckoutViewModelInputs {
  func applePayButtonTapped()
  func applePayContextDidCreatePayment(with paymentMethodId: String)
  func applePayContextDidComplete()
}

public protocol ApplePayCheckoutViewModelOutputs {
  var goToApplePayPaymentAuthorization: Signal<PostCampaignPaymentAuthorizationData, Never> { get }
  var completeCheckoutWithApplePayInput: Signal<GraphAPI.CompleteOnSessionCheckoutInput, Never> { get }
  var validateCheckoutError: Signal<ErrorEnvelope, Never> { get }
  var createNewPaymentIntentError: Signal<ErrorEnvelope, Never> { get }
}

public class ApplePayCheckoutViewModel: ApplePayCheckoutViewModelInputs, ApplePayCheckoutViewModelOutputs {
  // MARK: Late Pledge Init

  /// Crowdfunding logic may need to be in it's own init.

  /*

   Core Late Pledge Functionality:
   1) Apple pay button tapped
   2) Create a new payment intent
   3) Present the payment authorization form
   4) Payment authorization form calls applePayContextDidCreatePayment with the payment method Id
   5) Payment authorization form calls paymentAuthorizationDidFinish
   6) Validate checkout using the checkoutId, payment source id, and payment intent
   7) Notify the parent View Model that Apple Pay checkout is complete
   */

  public init(
    withConfigurationSignal configureWithData: Signal<PostCampaignCheckoutData, Never>,
    stripeIntentService: StripeIntentServiceType
  ) {
    let checkoutId = configureWithData.map(\.checkoutId)

    // MARK: Create a new payment intent

    let createPaymentIntentForApplePay: Signal<Signal<PaymentIntentEnvelope, ErrorEnvelope>.Event, Never> =
      configureWithData
        .takeWhen(self.applePayButtonTappedSignal)
        .switchMap { initialData in
          let projectId = initialData.project.graphID
          let pledgeTotal = initialData.total
          let checkoutId = initialData.checkoutId

          return stripeIntentService.createPaymentIntent(
            for: projectId,
            checkoutId: checkoutId,
            pledgeTotal: pledgeTotal
          )
          .materialize()
        }

    self.createNewPaymentIntentError = createPaymentIntentForApplePay.errors()

    let newPaymentIntentForApplePay: Signal<String, Never> = createPaymentIntentForApplePay
      .values()
      .map { $0.clientSecret }

    // MARK: Present the payment authorization form

    self.goToApplePayPaymentAuthorization = configureWithData
      .signal
      .combineLatest(with: newPaymentIntentForApplePay)
      .map { (
        data: PostCampaignCheckoutData,
        paymentIntent: String
      ) -> PostCampaignPaymentAuthorizationData? in
        let baseReward = data.baseReward

        return PostCampaignPaymentAuthorizationData(
          project: data.project,
          hasNoReward: baseReward.isNoReward,
          subtotal: baseReward.isNoReward ? baseReward.minimum : calculateAllRewardsTotal(
            addOnRewards: data.rewards,
            selectedQuantities: data.selectedQuantities
          ),
          bonus: data.bonusAmount ?? 0,
          shipping: data.shipping?.total ?? 0,
          total: data.total,
          merchantIdentifier: Secrets.ApplePay.merchantIdentifier,
          paymentIntent: paymentIntent
        )
      }
      .skipNil()

    // MARK: Validate Checkout

    let validateCheckoutWithApplePay = Signal.combineLatest(
      newPaymentIntentForApplePay,
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

    self.validateCheckoutError = validateCheckoutWithApplePay.errors()

    // MARK: Complete Checkout

    self.completeCheckoutWithApplePayInput = Signal
      .combineLatest(newPaymentIntentForApplePay, checkoutId)
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
  }

  // MARK: Inputs

  public let (applePayButtonTappedSignal, applePayButtonTappedObserver) = Signal<Void, Never>.pipe()
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

  // MARK: Outputs

  public let goToApplePayPaymentAuthorization: Signal<PostCampaignPaymentAuthorizationData, Never>
  public var completeCheckoutWithApplePayInput: Signal<GraphAPI.CompleteOnSessionCheckoutInput, Never>
  public var validateCheckoutError: Signal<ErrorEnvelope, Never>
  public var createNewPaymentIntentError: Signal<ErrorEnvelope, Never>
}
