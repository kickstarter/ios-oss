import Foundation
import KsApi
import PassKit
import ReactiveSwift

public protocol ApplePayTokenUseCaseType {
  var uiInputs: ApplePayTokenUseCaseUIInputs { get }
  var uiOutputs: ApplePayTokenUseCaseUIOutputs { get }
  var dataOutputs: ApplePayTokenUseCaseDataOutputs { get }
}

public protocol ApplePayTokenUseCaseUIInputs {
  func applePayButtonTapped()
  func paymentAuthorizationDidAuthorizePayment(paymentData: (
    displayName: String?,
    network: String?,
    transactionIdentifier: String
  ))
  func paymentAuthorizationViewControllerDidFinish()
  func stripeTokenCreated(token: String?, error: Error?) -> PKPaymentAuthorizationStatus
}

public protocol ApplePayTokenUseCaseUIOutputs {
  var goToApplePayPaymentAuthorization: Signal<PaymentAuthorizationData, Never> { get }
}

public protocol ApplePayTokenUseCaseDataOutputs {
  var applePayParams: Signal<ApplePayParams?, Never> { get }
  var applePayAuthorizationStatus: Signal<PKPaymentAuthorizationStatus, Never> { get }
  var paymentAuthorizationDidFinish: Signal<Void, Never> { get }
}

/**
 A use case for ApplePay transactions in the regular (not post!) pledge flow.

 To complete an ApplePay payment, the use case should be used in this order:
 - `uiInputs.applePayButtonTapped()` - The ApplePay button has been tapped
 - `uiOutputs.goToApplePayPaymentAuthorization` - The view controller should display a `PKPaymentAuthorizationViewController` with the sent `PKPaymentRequest`
 - `uiInputs.paymentAuthorizationDidAuthorizePayment(paymentData:)` - The `PKPaymentAuthorizationViewController` successfully authorized a payment
 - `uiInputs.stripeTokenCreated(token:error:)` - Stripe successfully turned the `PKPayment` into a Stripe token. Returns a status, which is also sent by the `applePayAuthorizationStatus` signal.
 - `uiInputs.paymentAuthorizationViewControllerDidFinish()` - The `PKPaymentAuthorizationViewController` was dismissed
 - `dataOutputs.applePayParams` - Sends parameters which can be used in `CreateBacking` or `UpdateBacking`. Sends an initial `nil`value, by default.

 Other inputs and outputs:

 Data Inputs:
 - `initialData` - An `initialData` event is required for any other signals to send.

 Data Outputs:
 - `applePayAuthorizationStatus` - Sends an event indicating whether the ApplePay flow succeeded or failed.
 - `paymentAuthorizationDidFinish` - Sends an event with the ApplePay spreadsheet closes.
  */

public final class ApplePayTokenUseCase: ApplePayTokenUseCaseType, ApplePayTokenUseCaseUIInputs,
  ApplePayTokenUseCaseUIOutputs, ApplePayTokenUseCaseDataOutputs {
  init(initialData: Signal<PaymentAuthorizationData, Never>) {
    self.goToApplePayPaymentAuthorization = initialData
      .takeWhen(self.applePayButtonTappedSignal)

    let pkPaymentData = self.pkPaymentSignal
      .map { pkPayment -> PKPaymentData? in
        guard let displayName = pkPayment.displayName, let network = pkPayment.network else {
          return nil
        }

        return (displayName, network, pkPayment.transactionIdentifier)
      }

    let applePayStatusSuccess = Signal.combineLatest(
      self.stripeTokenSignal.skipNil(),
      self.stripeErrorSignal.filter { $0 == nil },
      pkPaymentData.skipNil()
    )
    .mapConst(PKPaymentAuthorizationStatus.success)

    let applePayStatusFailure = Signal.merge(
      self.stripeErrorSignal.skipNil().ignoreValues(),
      self.stripeTokenSignal.filter { $0 == nil }.ignoreValues(),
      pkPaymentData.filter { $0 == nil }.ignoreValues()
    )
    .mapConst(PKPaymentAuthorizationStatus.failure)

    self.createApplePayBackingStatusProperty <~ Signal.merge(
      applePayStatusSuccess,
      applePayStatusFailure
    )

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
    .takeWhen(self.paymentAuthorizationDidFinishSignal)

    self.applePayParams = Signal.merge(
      initialData.mapConst(nil),
      applePayParams.wrapInOptional()
    )

    self.applePayAuthorizationStatus = self.createApplePayBackingStatusProperty.signal
  }

  // MARK: - Inputs

  private let (applePayButtonTappedSignal, applePayButtonTappedObserver) = Signal<Void, Never>.pipe()
  public func applePayButtonTapped() {
    self.applePayButtonTappedObserver.send(value: ())
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

  public var paymentAuthorizationDidFinish: Signal<Void, Never> {
    return self.paymentAuthorizationDidFinishSignal
  }

  private let (stripeTokenSignal, stripeTokenObserver) = Signal<String?, Never>.pipe()
  private let (stripeErrorSignal, stripeErrorObserver) = Signal<Error?, Never>.pipe()

  private let createApplePayBackingStatusProperty = MutableProperty<PKPaymentAuthorizationStatus>(.failure)
  public func stripeTokenCreated(token: String?, error: Error?) -> PKPaymentAuthorizationStatus {
    self.stripeTokenObserver.send(value: token)
    self.stripeErrorObserver.send(value: error)

    return self.createApplePayBackingStatusProperty.value
  }

  // MARK: - Outputs

  public let goToApplePayPaymentAuthorization: Signal<PaymentAuthorizationData, Never>
  public let applePayParams: Signal<ApplePayParams?, Never>
  public let applePayAuthorizationStatus: Signal<PKPaymentAuthorizationStatus, Never>

  // MARK: - Interface

  public var uiInputs: ApplePayTokenUseCaseUIInputs { return self }
  public var uiOutputs: ApplePayTokenUseCaseUIOutputs { return self }
  public var dataOutputs: ApplePayTokenUseCaseDataOutputs { return self }
}
