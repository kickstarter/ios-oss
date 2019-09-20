import KsApi
import PassKit
import Prelude
import ReactiveSwift
import UIKit

public typealias PledgePaymentMethodsValue = (user: User, project: Project, applePayCapable: Bool)

public protocol PledgePaymentMethodsViewModelInputs {
  func addNewCardSucceeded()
  func applePayButtonTapped()
  func configureWith(_ value: PledgePaymentMethodsValue)
  func didCreateCards(_ cards: [UIView])
  func successfullyAddedCard(newCard: GraphUserCreditCard.CreditCard)
  func viewDidLoad()
}

public protocol PledgePaymentMethodsViewModelOutputs {
  var applePayButtonHidden: Signal<Bool, Never> { get }
  var newCardAdded: Signal<GraphUserCreditCard.CreditCard, Never> { get }
  var notifyDelegateApplePayButtonTapped: Signal<Void, Never> { get }
  var notifyDelegateLoadPaymentMethodsError: Signal<String, Never> { get }
  var reloadPaymentMethods: Signal<[GraphUserCreditCard.CreditCard], Never> { get }
  func savedCards() -> [UIView]
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

    let storedCardsEvent = configureWithValue
      .switchMap { _ in
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

    self.notifyDelegateApplePayButtonTapped = self.applePayButtonTappedProperty.signal

    self.newCardAdded = self.creditCardProperty.signal.skipNil()

    self.notifyDelegateLoadPaymentMethodsError = storedCardsEvent
      .errors()
      .map { $0.localizedDescription }
  }

  private let applePayButtonTappedProperty = MutableProperty(())
  public func applePayButtonTapped() {
    self.applePayButtonTappedProperty.value = ()
  }

  fileprivate let addNewCardSucceededProperty = MutableProperty(())
  public func addNewCardSucceeded() {
    self.addNewCardSucceededProperty.value = ()
  }

  private let configureWithValueProperty = MutableProperty<PledgePaymentMethodsValue?>(nil)
  public func configureWith(_ value: PledgePaymentMethodsValue) {
    self.configureWithValueProperty.value = value
  }

  private let creditCardProperty = MutableProperty<GraphUserCreditCard.CreditCard?>(nil)
  public func successfullyAddedCard(newCard: GraphUserCreditCard.CreditCard) {
    self.creditCardProperty.value = newCard
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  private let savedCardsProperty = MutableProperty<[UIView]>([])
  public func didCreateCards(_ cards: [UIView]) {
    self.savedCardsProperty.value = cards
  }

  public func savedCards() -> [UIView] {
    return self.savedCardsProperty.value
  }

  public var inputs: PledgePaymentMethodsViewModelInputs { return self }
  public var outputs: PledgePaymentMethodsViewModelOutputs { return self }

  public let notifyDelegateApplePayButtonTapped: Signal<Void, Never>
  public let applePayButtonHidden: Signal<Bool, Never>
  public let notifyDelegateLoadPaymentMethodsError: Signal<String, Never>
  public let reloadPaymentMethods: Signal<[GraphUserCreditCard.CreditCard], Never>
  public let newCardAdded: Signal<GraphUserCreditCard.CreditCard, Never>
}

private func showApplePayButton(for project: Project, applePayCapable: Bool) -> Bool {
  return applePayCapable &&
    AppEnvironment.current.config?.applePayCountries.contains(project.country.countryCode) ?? false
}
