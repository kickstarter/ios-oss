import Foundation
import KsApi
import ReactiveSwift

public class ApplePayCheckoutViewModel {
  init(withConfigurationSignal configureWithData: Signal<PostCampaignCheckoutData, Never>) {
    /*
     Order of operations:
     1) Apple pay button tapped
     2) Generate a new payment intent
     3) Present the payment authorization form
     4) Payment authorization form calls applePayContextDidCreatePayment with ApplePay params
     5) Payment authorization form calls paymentAuthorizationDidFinish
     */

    let createPaymentIntentForApplePay: Signal<Signal<PaymentIntentEnvelope, ErrorEnvelope>.Event, Never> =
      configureWithData
        .takeWhen(self.applePayButtonTappedSignal)
        .switchMap { initialData in
          let projectId = initialData.project.graphID
          let pledgeTotal = initialData.total

          return AppEnvironment.current.apiService
            .createPaymentIntentInput(input: CreatePaymentIntentInput(
              projectId: projectId,
              amountDollars: String(format: "%.2f", pledgeTotal),
              digitalMarketingAttributed: nil
            ))
            .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
            .materialize()
        }

    self.errors = createPaymentIntentForApplePay.errors()

    let newPaymentIntentForApplePay: Signal<String, Never> = createPaymentIntentForApplePay
      .values()
      .map { $0.clientSecret }

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

    self.completeCheckoutWithApplePayInput = Signal
      .combineLatest(newPaymentIntentForApplePay, configureWithData, self.applePayParamsSignal.mapConst(true))
      .takeWhen(self.applePayContextDidCompleteSignal)
      .map {
        (
          clientSecret: String,
          data: PostCampaignCheckoutData,
          _: Bool
        ) -> GraphAPI.CompleteOnSessionCheckoutInput in
        let checkoutId = data.checkoutId

        return GraphAPI
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

  // inputs

  private let (applePayButtonTappedSignal, applePayButtonTappedObserver) = Signal<Void, Never>.pipe()
  public func applePayButtonTapped() {
    self.applePayButtonTappedObserver.send(value: ())
  }

  private let (applePayParamsSignal, applePayParamsObserver) = Signal<ApplePayParams, Never>.pipe()
  public func applePayContextDidCreatePayment(params: ApplePayParams) {
    self.applePayParamsObserver.send(value: params)
  }

  private let (applePayContextDidCompleteSignal, applePayContextDidCompleteObserver)
    = Signal<Void, Never>.pipe()
  public func applePayContextDidComplete() {
    self.applePayContextDidCompleteObserver.send(value: ())
  }

  // outputs
  public var goToApplePayPaymentAuthorization: Signal<PostCampaignPaymentAuthorizationData, Never>
  public var completeCheckoutWithApplePayInput: Signal<GraphAPI.CompleteOnSessionCheckoutInput, Never>
  public var errors: Signal<ErrorEnvelope, Never>
}
