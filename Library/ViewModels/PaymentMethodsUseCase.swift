import KsApi
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
  var paymentMethodChangedAndValid: Signal<Bool, Never> { get }
}

/**
 A use case for turning `PledgeViewData` into `PledgePaymentMethodsValue`. Used to configure `PledgePaymentMethodsViewController` in the late or live pledge flows.

 UI Inputs:
  * `creditCardSelected(with:)` - Call this when the user selects a new card.

 Data Inputs:
  * `initialData` - Pledge configuration data. Must send at least one event for any outputs to send.
  * `isLoggedIn` - Boolean signal that indicates whether or not the user is logged in.

 UI Outputs:
  * `configurePaymentMethodsViewControllerWithValue` - Configuration data for `PledgePaymentMethodsViewController`. May be sent never (if payment methods are disabled, or if the user is logged out), once, or many times (if the user logs out and in again.)
  * `paymentMethodsViewHidden` - Whether or not to show the payment methods view. Sent at least once after `initialData` is sent.

 Data Outputs:
  * `selectedPaymentSource` - The currently selected credit card, or `nil` if no card is selected. Sent at least once after   `initialData` is sent.
  * `paymentMethodChangedAndValid` - Whether or not the payment method is valid for the current pledge type. Sends an event after `initialData` and potentially more after `creditCardSelected(with:)` has happened.
  */
public final class PaymentMethodsUseCase: PaymentMethodsUseCaseType, PaymentMethodsUseCaseUIInputs,
  PaymentMethodsUseCaseUIOutputs, PaymentMethodsUseCaseDataOutputs {
  init(initialData: Signal<PledgeViewData, Never>, isLoggedIn isLoggedInChanged: Signal<Bool, Never>) {
    let project = initialData.map(\.project)
    let baseReward = initialData.map(\.rewards).map(\.first).skipNil()
    let refTag = initialData.map(\.refTag)
    let context = initialData.map(\.context)

    let initialDataUnpacked = Signal.zip(project, baseReward, refTag, context)
    let initialLoggedIn = initialData.map { _ in AppEnvironment.current.currentUser != nil }

    let isLoggedIn = Signal.merge(
      initialLoggedIn,
      isLoggedInChanged
    ).skipRepeats()

    let configurePaymentMethodsViewController = Signal.merge(
      initialDataUnpacked,
      initialDataUnpacked.takeWhen(isLoggedIn.filter { $0 == true })
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

    let notChangingPaymentMethod = context.map { context in
      if context.isUpdating {
        return context == .updateReward
      }

      return false
    }

    /// The `paymentMethodChangedAndValid` compares  against the existing backing payment source id.
    self.paymentMethodChangedAndValid = Signal.merge(
      notChangingPaymentMethod,
      Signal.combineLatest(
        project,
        baseReward,
        self.creditCardSelectedSignal,
        context
      )
      .map(paymentMethodValid)
    )
  }

  public let paymentMethodsViewHidden: Signal<Bool, Never>
  public let configurePaymentMethodsViewControllerWithValue: Signal<PledgePaymentMethodsValue, Never>
  public let selectedPaymentSource: Signal<PaymentSourceSelected?, Never>
  public let paymentMethodChangedAndValid: Signal<Bool, Never>

  private let (creditCardSelectedSignal, creditCardSelectedObserver) = Signal<PaymentSourceSelected, Never>
    .pipe()
  public func creditCardSelected(with paymentSourceData: PaymentSourceSelected) {
    self.creditCardSelectedObserver.send(value: paymentSourceData)
  }

  public var uiInputs: PaymentMethodsUseCaseUIInputs { return self }
  public var uiOutputs: PaymentMethodsUseCaseUIOutputs { return self }
  public var dataOutputs: PaymentMethodsUseCaseDataOutputs { return self }
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
