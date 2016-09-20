import KsApi
import Prelude
import ReactiveCocoa
import ReactiveExtensions
import Result

private struct CheckoutRetryError: ErrorType {}

public protocol CheckoutRacingViewModelInputs {
  /// Configure with the checkout URL.
  func configureWith(url url: NSURL)
}

public protocol CheckoutRacingViewModelOutputs {
  /// Emits when an alert should be shown indicating the pledge was not successful.
  var showFailureAlert: Signal<String, NoError> { get }

  /// Emits when the checkout's state is successful.
  var goToThanks: Signal<Void, NoError> { get }
}

public protocol CheckoutRacingViewModelType: CheckoutRacingViewModelInputs, CheckoutRacingViewModelOutputs {
  var inputs: CheckoutRacingViewModelInputs { get }
  var outputs: CheckoutRacingViewModelOutputs { get }
}

public final class CheckoutRacingViewModel: CheckoutRacingViewModelType {
  public init() {

    let envelope = initialURLProperty.signal.ignoreNil()
      .map { optionalize($0.absoluteString) }
      .ignoreNil()
      .promoteErrors(CheckoutRetryError.self)
      .switchMap { url in
        SignalProducer<(), CheckoutRetryError>(value: ())
          .delay(1, onScheduler: AppEnvironment.current.scheduler)
          .flatMap {
            AppEnvironment.current.apiService.fetchCheckout(checkoutUrl: url)
              .flatMapError { errorEnv in
                return SignalProducer(error: CheckoutRetryError())
              }
              .flatMap { envelope -> SignalProducer<CheckoutEnvelope, CheckoutRetryError> in

                switch envelope.state {
                case .authorizing, .verifying:
                  return SignalProducer(error: CheckoutRetryError())
                case .failed, .successful:
                  return SignalProducer(value: envelope)
                }
            }
          }
          .retry(9)
          .timeoutWithError(
            CheckoutRetryError(),
            afterInterval: 10,
            onScheduler: AppEnvironment.current.scheduler
          )
      }
      .materialize()

    self.goToThanks = envelope
      .values()
      .filter { $0.state == .successful }
      .ignoreValues()

    let failedCheckoutError = envelope
      .values()
      .filter { $0.state == .failed }
      .map { $0.stateReason }

    let timedOutError = envelope.errors()
      .mapConst(Strings.project_checkout_finalizing_timeout_message())

    self.showFailureAlert = Signal.merge(failedCheckoutError, timedOutError)
  }

  private let initialURLProperty = MutableProperty<NSURL?>(nil)
  public func configureWith(url url: NSURL) {
    self.initialURLProperty.value = url
  }

  public let goToThanks: Signal<Void, NoError>
  public let showFailureAlert: Signal<String, NoError>

  public var inputs: CheckoutRacingViewModelInputs { return self }
  public var outputs: CheckoutRacingViewModelOutputs { return self }
}
