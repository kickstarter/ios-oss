import KsApi
import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result

private struct CheckoutRetryError: Error {}

public protocol CheckoutRacingViewModelInputs {
  /// Configure with the checkout URL.
  func configureWith(url: URL)
}

public protocol CheckoutRacingViewModelOutputs {
  /// Emits when an alert should be shown.
  var showAlert: Signal<String, NoError> { get }

  /// Emits when the checkout's state is successful.
  var goToThanks: Signal<Void, NoError> { get }
}

public protocol CheckoutRacingViewModelType: CheckoutRacingViewModelInputs, CheckoutRacingViewModelOutputs {
  var inputs: CheckoutRacingViewModelInputs { get }
  var outputs: CheckoutRacingViewModelOutputs { get }
}

public final class CheckoutRacingViewModel: CheckoutRacingViewModelType {
  public init() {

    let envelope = initialURLProperty.signal.skipNil()
      .map { $0.absoluteString }
      .promoteErrors(CheckoutRetryError.self)
      .switchMap { url in
        SignalProducer<(), CheckoutRetryError>(value: ())
          .ksr_delay(.seconds(1), on: AppEnvironment.current.scheduler)
          .flatMap {
            AppEnvironment.current.apiService.fetchCheckout(checkoutUrl: url)
              .flatMapError { _ in
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
          .retry(upTo: 9)
          .timeout(
            after: 10,
            raising: CheckoutRetryError(),
            on: AppEnvironment.current.scheduler
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

    self.showAlert = Signal.merge(failedCheckoutError, timedOutError)
  }

  fileprivate let initialURLProperty = MutableProperty<URL?>(nil)
  public func configureWith(url: URL) {
    self.initialURLProperty.value = url
  }

  public let goToThanks: Signal<Void, NoError>
  public let showAlert: Signal<String, NoError>

  public var inputs: CheckoutRacingViewModelInputs { return self }
  public var outputs: CheckoutRacingViewModelOutputs { return self }
}
