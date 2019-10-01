import KsApi
import PassKit
import Prelude
import ReactiveSwift
import UIKit

public typealias PledgePaymentMethodsValue = (user: User, project: Project, applePayCapable: Bool)

public protocol PledgePaymentMethodsViewModelInputs {
  func applePayButtonTapped()
  func configureWith(_ value: PledgePaymentMethodsValue)
  func creditCardSelected(paymentSourceId: String)
  func updatePledgeButtonEnabled(isEnabled: Bool)
  func addNewCardViewControllerDidAdd(newCard card: GraphUserCreditCard.CreditCard)
  func viewDidLoad()
  func addNewCardTapped(with intent: AddNewCardIntent)
}

public protocol PledgePaymentMethodsViewModelOutputs {
  var applePayButtonHidden: Signal<Bool, Never> { get }
  var notifyDelegateApplePayButtonTapped: Signal<Void, Never> { get }
  var notifyDelegateCreditCardSelected: Signal<String, Never> { get }
  var notifyDelegateLoadPaymentMethodsError: Signal<String, Never> { get }
  var pledgeButtonEnabled: Signal<Bool, Never> { get }
  var reloadPaymentMethods: Signal<[GraphUserCreditCard.CreditCard], Never> { get }
  var updateSelectedCreditCard: Signal<GraphUserCreditCard.CreditCard, Never> { get }
  var goToAddCardScreen: Signal<(AddNewCardIntent, Project), Never> { get }
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

    self.pledgeButtonEnabled = Signal.merge(
      configureWithValue.mapConst(false),
      self.pledgeButtonEnabledSignal
    )
    .skipRepeats()

    let storedCards = storedCardsEvent
      .values()
      .map { $0.me.storedCards.nodes }

    self.reloadPaymentMethods = Signal.merge(
      storedCards,
      self.newCreditCardProperty.signal.skipNil().map { card in [card] }
    )
    .scan([]) { current, new in new + current }

    self.notifyDelegateApplePayButtonTapped = self.applePayButtonTappedProperty.signal

    self.notifyDelegateLoadPaymentMethodsError = storedCardsEvent
      .errors()
      .map { $0.localizedDescription }

    self.notifyDelegateCreditCardSelected = self.creditCardSelectedSignal
      .skipRepeats()

    self.updateSelectedCreditCard = self.reloadPaymentMethods
      .takePairWhen(self.creditCardSelectedSignal)
      .map { cards, id in cards.filter { $0.id == id }.first }
      .skipNil()

    let project = configureWithValue.map { $0.project }

    self.goToAddCardScreen = Signal.combineLatest(self.addNewCardIntentProperty.signal.skipNil(), project)
  }

  private let applePayButtonTappedProperty = MutableProperty(())
  public func applePayButtonTapped() {
    self.applePayButtonTappedProperty.value = ()
  }

  private let configureWithValueProperty = MutableProperty<PledgePaymentMethodsValue?>(nil)
  public func configureWith(_ value: PledgePaymentMethodsValue) {
    self.configureWithValueProperty.value = value
  }

  private let (creditCardSelectedSignal, creditCardSelectedObserver) = Signal<String, Never>.pipe()
  public func creditCardSelected(paymentSourceId: String) {
    self.creditCardSelectedObserver.send(value: paymentSourceId)
  }

  private let (pledgeButtonEnabledSignal, pledgeButtonEnabledObserver) = Signal<Bool, Never>.pipe()
  public func updatePledgeButtonEnabled(isEnabled: Bool) {
    self.pledgeButtonEnabledObserver.send(value: isEnabled)
  }

  private let newCreditCardProperty = MutableProperty<GraphUserCreditCard.CreditCard?>(nil)
  public func addNewCardViewControllerDidAdd(newCard card: GraphUserCreditCard.CreditCard) {
    self.newCreditCardProperty.value = card
  }

  private let addNewCardIntentProperty = MutableProperty<AddNewCardIntent?>(nil)
  public func addNewCardTapped(with intent: AddNewCardIntent) {
    self.addNewCardIntentProperty.value = intent
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let notifyDelegateApplePayButtonTapped: Signal<Void, Never>
  public let applePayButtonHidden: Signal<Bool, Never>
  public let goToAddCardScreen: Signal<(AddNewCardIntent, Project), Never>
  public let notifyDelegateCreditCardSelected: Signal<String, Never>
  public let notifyDelegateLoadPaymentMethodsError: Signal<String, Never>
  public let pledgeButtonEnabled: Signal<Bool, Never>
  public let reloadPaymentMethods: Signal<[GraphUserCreditCard.CreditCard], Never>
  public let updateSelectedCreditCard: Signal<GraphUserCreditCard.CreditCard, Never>

  public var inputs: PledgePaymentMethodsViewModelInputs { return self }
  public var outputs: PledgePaymentMethodsViewModelOutputs { return self }
}

private func showApplePayButton(for project: Project, applePayCapable: Bool) -> Bool {
  return applePayCapable &&
    AppEnvironment.current.config?.applePayCountries.contains(project.country.countryCode) ?? false
}
