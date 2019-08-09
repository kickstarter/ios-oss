import KsApi
import Prelude
import ReactiveSwift

public protocol PledgePaymentMethodsViewModelInputs {
  func configureWith(_ user: User)
  func viewDidLoad()
}

public protocol PledgePaymentMethodsViewModelOutputs {
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
    let storedCardsEvent = Signal.combineLatest(
      self.viewDidLoadProperty.signal,
      self.configureWithUserProperty.signal.skipNil()
    )
    .switchMap { _ in
      AppEnvironment.current.apiService
        .fetchGraphCreditCards(query: UserQueries.storedCards.query)
        .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
        .materialize()
    }

    self.reloadPaymentMethods = storedCardsEvent
      .values()
      .map { $0.me.storedCards.nodes }

    self.notifyDelegateLoadPaymentMethodsError = storedCardsEvent
      .errors()
      .map { $0.localizedDescription }
  }

  private let configureWithUserProperty = MutableProperty<User?>(nil)
  public func configureWith(_ user: User) {
    self.configureWithUserProperty.value = user
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public var inputs: PledgePaymentMethodsViewModelInputs { return self }
  public var outputs: PledgePaymentMethodsViewModelOutputs { return self }

  public let notifyDelegateLoadPaymentMethodsError: Signal<String, Never>
  public let reloadPaymentMethods: Signal<[GraphUserCreditCard.CreditCard], Never>
}
