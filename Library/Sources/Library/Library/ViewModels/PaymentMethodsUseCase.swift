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
  private var state: MutableProperty<PaymentMethodsUseCaseState?>

  init(initialData: Signal<PledgeViewData, Never>, isLoggedIn isLoggedInChanged: Signal<Bool, Never>) {
    self.state = MutableProperty(nil)

    self.state <~ Signal.combineLatest(
      initialData,
      Signal.merge(initialData.map { _ in AppEnvironment.current.currentUser != nil }, isLoggedInChanged),
      Signal.merge(initialData.mapConst(nil), self.paymentSourceProperty.signal)
    )
    .map { data, loggedIn, paymentSource in
      PaymentMethodsUseCaseState(
        data: data,
        isLoggedIn: loggedIn,
        paymentSourceSelected: paymentSource
      )
    }

    // This should really be bumped out elsewhere
    self.paymentMethodsViewHidden = self.state.signal
      .skipNil()
      .map { $0.isPaymentMethodViewHidden }
      .skipRepeats()

    // This isn't quite right with regards to logging in/logging out but
    // it works in practice (since you can only log in once without destroying the screen)
    self.configurePaymentMethodsViewControllerWithValue = self.state.signal
      .map { $0?.configurePaymentMethodsViewControllerValue }
      .skipNil()
      .take(first: 1)

    self.selectedPaymentSource = self.state.signal
      .map { $0?.paymentSourceSelected }
      .skipRepeats()

    self.paymentMethodChangedAndValid = self.state.signal
      .map { $0?.paymentMethodChangedAndValid }
      .skipNil()
  }

  public let paymentMethodsViewHidden: Signal<Bool, Never>
  public let configurePaymentMethodsViewControllerWithValue: Signal<PledgePaymentMethodsValue, Never>
  public let selectedPaymentSource: Signal<PaymentSourceSelected?, Never>
  public let paymentMethodChangedAndValid: Signal<Bool, Never>

  private let paymentSourceProperty = MutableProperty<PaymentSourceSelected?>(nil)
  public func creditCardSelected(with paymentSourceData: PaymentSourceSelected) {
    self.paymentSourceProperty.value = paymentSourceData
  }

  public var uiInputs: PaymentMethodsUseCaseUIInputs { return self }
  public var uiOutputs: PaymentMethodsUseCaseUIOutputs { return self }
  public var dataOutputs: PaymentMethodsUseCaseDataOutputs { return self }
}

private struct PaymentMethodsUseCaseState {
  let data: PledgeViewData
  var isLoggedIn: Bool
  var paymentSourceSelected: PaymentSourceSelected?

  var isPaymentMethodViewHidden: Bool {
    if !self.isLoggedIn {
      return true
    }

    return self.data.context.paymentMethodsViewHidden
  }

  var baseReward: Reward? {
    return self.data.rewards.first
  }

  var configurePaymentMethodsViewControllerValue: PledgePaymentMethodsValue? {
    if !self.isLoggedIn || self.isPaymentMethodViewHidden {
      return nil
    }

    guard let user = AppEnvironment.current.currentUser,
          let reward = self.baseReward else {
      return nil
    }

    return (user, self.data.project, "", reward, self.data.context, self.data.refTag)
  }

  var notChangingPaymentMethod: Bool {
    let context = self.data.context

    if context.isUpdating {
      return context == .updateReward || context == .editPledgeOverTime
    }

    return false
  }

  /// The `paymentMethodChangedAndValid` compares  against the existing backing payment source id.
  var paymentMethodChangedAndValid: Bool {
    guard let reward = self.baseReward,
          let source = self.paymentSourceSelected else { return self.notChangingPaymentMethod }

    return self.paymentMethodValid(
      project: self.data.project,
      reward: reward,
      paymentSource: source,
      context: self.data.context
    )
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
}
