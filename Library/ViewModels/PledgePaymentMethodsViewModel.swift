import KsApi
import Prelude
import ReactiveSwift
import PassKit

public protocol PledgePaymentMethodsViewModelInputs {
  func configureWith(_ value: (User, Project))
  func viewDidLoad()
}

public protocol PledgePaymentMethodsViewModelOutputs {
  var applePayButtonHidden: Signal<Bool, Never> { get }
  var notifyDelegateLoadPaymentMethodsError: Signal<String, Never> { get }
  var reloadPaymentMethods: Signal<[GraphUserCreditCard.CreditCard], Never> { get }
}

public protocol PledgePaymentMethodsViewModelType {
  var inputs: PledgePaymentMethodsViewModelInputs { get }
  var outputs: PledgePaymentMethodsViewModelOutputs { get }
}

public final class PledgePaymentMethodsViewModel: PledgePaymentMethodsViewModelType,
  PledgePaymentMethodsViewModelInputs, PledgePaymentMethodsViewModelOutputs {
  public init() {
    let configureWithValue = Signal.combineLatest(
      self.viewDidLoadProperty.signal,
      self.configureWithValueProperty.signal.skipNil()
    ).map(second)

    let project = configureWithValue.map(second)

    let storedCardsEvent = configureWithValue
    .switchMap { _ in
      AppEnvironment.current.apiService
        .fetchGraphCreditCards(query: UserQueries.storedCards.query)
        .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
        .materialize()
    }

    self.applePayButtonHidden = project
      .map(PKPaymentAuthorizationViewController.applePayCapable(for:))

    self.reloadPaymentMethods = storedCardsEvent
      .values()
      .map { $0.me.storedCards.nodes }

    self.notifyDelegateLoadPaymentMethodsError = storedCardsEvent
      .errors()
      .map { $0.localizedDescription }
  }

  private let configureWithValueProperty = MutableProperty<(User, Project)?>(nil)
  public func configureWith(_ value: (User, Project)) {
    self.configureWithValueProperty.value = value
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public var inputs: PledgePaymentMethodsViewModelInputs { return self }
  public var outputs: PledgePaymentMethodsViewModelOutputs { return self }

  public let applePayButtonHidden: Signal<Bool, Never>
  public let notifyDelegateLoadPaymentMethodsError: Signal<String, Never>
  public let reloadPaymentMethods: Signal<[GraphUserCreditCard.CreditCard], Never>
}
