import KsApi
import PassKit
import Prelude
import ReactiveSwift

public typealias PledgePaymentMethodsValue = (user: User, project: Project, applePayCapable: Bool)

public protocol PledgePaymentMethodsViewModelInputs {
  func addNewCardSucceeded()
  func configureWith(_ value: PledgePaymentMethodsValue)
  func viewDidLoad()
}

public protocol PledgePaymentMethodsViewModelOutputs {
  var applePayButtonHidden: Signal<Bool, Never> { get }
  var notifyDelegateLoadPaymentMethodsError: Signal<String, Never> { get }
  var reloadPaymentMethods: Signal<[GraphUserCreditCard.CreditCard], Never> { get }
  var notifyDelegateNewCardAdded: Signal<Void, Never> { get }
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

    let storedCardsEvent = Signal.merge(
      configureWithValue.ignoreValues(),
      self.addNewCardSucceededProperty.signal
    )
    .switchMap {
      AppEnvironment.current.apiService
        .fetchGraphCreditCards(query: UserQueries.storedCards.query)
        .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
        .materialize()
    }

    self.applePayButtonHidden = configureWithValue
      .map { ($0.project, $0.applePayCapable) }
      .map(showApplePayButton(for:applePayCapable:))
      .negate()

    self.reloadPaymentMethods = storedCardsEvent
      .values()
      .map { $0.me.storedCards.nodes }

    self.notifyDelegateNewCardAdded = self.addNewCardSucceededProperty.signal

    self.notifyDelegateLoadPaymentMethodsError = storedCardsEvent
      .errors()
      .map { $0.localizedDescription }
  }

  fileprivate let addNewCardSucceededProperty = MutableProperty(())
  public func addNewCardSucceeded() {
    self.addNewCardSucceededProperty.value = ()
  }

  private let configureWithValueProperty = MutableProperty<PledgePaymentMethodsValue?>(nil)
  public func configureWith(_ value: PledgePaymentMethodsValue) {
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
  public let notifyDelegateNewCardAdded: Signal<Void, Never>
}

private func showApplePayButton(for project: Project, applePayCapable: Bool) -> Bool {
  return applePayCapable &&
    AppEnvironment.current.config?.applePayCountries.contains(project.country.countryCode) ?? false
}
