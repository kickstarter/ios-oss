import ReactiveSwift

public protocol PaymentMethodsUseCaseType {
  var uiInputs: PaymentMethodsUseCaseUIInputs { get }
  var uiOutputs: PaymentMethodsUseCaseUIOutputs { get }
  var dataOutputs: PaymentMethodsUseCaseDataOutputs { get }
}

public protocol PaymentMethodsUseCaseUIInputs {
  func creditCardSelected(with paymentSourceData: PaymentSourceSelected)
}

public protocol PaymentMethodsUseCaseUIOutputs {
  var paymentMethodsViewHidden: Signal<Bool, Never> { get }
  var configurePaymentMethodsViewControllerWithValue: Signal<PledgePaymentMethodsValue, Never> { get }
}

public protocol PaymentMethodsUseCaseDataOutputs {
  var selectedPaymentSource: Signal<PaymentSourceSelected?, Never> { get }
}

/** A use case for turning `PledgeViewData` into `PledgePaymentMethodsValue`. Used to configure `PledgePaymentMethodsViewController` in the late or live pledge flows.

 Inputs:
  * `initialData` - Pledge configuration data. Must send at least one event for any uiOutputs to send.
  * `userSessionStarted` - Empty signal that indicates when a user logs in.
  * `creditCardSelected(with:)` - Call this when the user selects a new card.

 Outputs:
  * `configurePaymentMethodsViewControllerWithValue` - Configuration data for `PledgePaymentMethodsViewController`. May be sent never (if payment methods are disabled, or if the user is logged out), once, or many times (if the user logs out and in again.)
  * `paymentMethodsViewHidden` - Whether or not to show the payment methods view. Sent at least once after `initialData` is sent.
  * `selectedPaymentSource` - The currently selected credit card, or `nil` if no card is selected. Sent at least once after `initialData` is sent.
  */
public final class PaymentMethodsUseCase: PaymentMethodsUseCaseType, PaymentMethodsUseCaseUIInputs,
  PaymentMethodsUseCaseUIOutputs, PaymentMethodsUseCaseDataOutputs {
  init(initialData: Signal<PledgeViewData, Never>, userSessionStarted: Signal<(), Never>) {
    let project = initialData.map(\.project)
    let baseReward = initialData.map(\.rewards).map(\.first).skipNil()
    let refTag = initialData.map(\.refTag)
    let context = initialData.map(\.context)

    let isLoggedIn = Signal.merge(initialData.ignoreValues(), userSessionStarted)
      .map { _ in AppEnvironment.current.currentUser != nil }

    let initialDataUnpacked = Signal.zip(project, baseReward, refTag, context)

    let configurePaymentMethodsViewController = Signal.merge(
      initialDataUnpacked,
      initialDataUnpacked.takeWhen(userSessionStarted)
    )

    self.configurePaymentMethodsViewControllerWithValue = configurePaymentMethodsViewController
      .filter { !$3.paymentMethodsViewHidden }
      .compactMap { project, reward, refTag, context -> PledgePaymentMethodsValue? in
        guard let user = AppEnvironment.current.currentUser else { return nil }
        return (user, project, "", reward, context, refTag)
      }

    self.paymentMethodsViewHidden = Signal.combineLatest(isLoggedIn, context)
      .map { !$0 || $1.paymentMethodsViewHidden }

    self.selectedPaymentSource = Signal.merge(
      initialData.mapConst(nil),
      self.creditCardSelectedSignal.wrapInOptional()
    )
  }

  public let paymentMethodsViewHidden: Signal<Bool, Never>
  public let configurePaymentMethodsViewControllerWithValue: Signal<PledgePaymentMethodsValue, Never>
  public let selectedPaymentSource: Signal<PaymentSourceSelected?, Never>

  private let (creditCardSelectedSignal, creditCardSelectedObserver) = Signal<PaymentSourceSelected, Never>
    .pipe()
  public func creditCardSelected(with paymentSourceData: PaymentSourceSelected) {
    self.creditCardSelectedObserver.send(value: paymentSourceData)
  }

  public var uiInputs: PaymentMethodsUseCaseUIInputs { return self }
  public var uiOutputs: PaymentMethodsUseCaseUIOutputs { return self }
  public var dataOutputs: PaymentMethodsUseCaseDataOutputs { return self }
}
