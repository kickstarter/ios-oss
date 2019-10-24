import KsApi
import PassKit
import Prelude
import ReactiveSwift
import UIKit

public typealias PledgePaymentMethodsValue = (user: User, project: Project, applePayCapable: Bool)
public typealias CardViewValues = (
  cardAndIsAvailableCardType: [(card: GraphUserCreditCard.CreditCard, cardTypeIsAvailable: Bool)],
  projectCountry: String
)

public protocol PledgePaymentMethodsViewModelInputs {
  func applePayButtonTapped()
  func configureWith(_ value: PledgePaymentMethodsValue)
  func creditCardSelected(paymentSourceId: String)
  func addNewCardViewControllerDidAdd(newCard card: GraphUserCreditCard.CreditCard)
  func viewDidLoad()
  func addNewCardTapped(with intent: AddNewCardIntent)
}

public protocol PledgePaymentMethodsViewModelOutputs {
  var applePayButtonHidden: Signal<Bool, Never> { get }
  var goToAddCardScreen: Signal<(AddNewCardIntent, Project), Never> { get }
  var notifyDelegateApplePayButtonTapped: Signal<Void, Never> { get }
  var notifyDelegateCreditCardSelected: Signal<String, Never> { get }
  var notifyDelegateLoadPaymentMethodsError: Signal<String, Never> { get }
  var reloadPaymentMethods: Signal<CardViewValues, Never> { get }
  var updateSelectedCreditCard: Signal<GraphUserCreditCard.CreditCard, Never> { get }
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
    )
    .map(second)

    let project = configureWithValue.map { $0.project }

    let availableCardTypes = project.map { $0.availableCardTypes }.skipNil()

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

    let storedCards = storedCardsEvent
      .values()
      .map { $0.me.storedCards.nodes }

    let cards = Signal.merge(
      storedCards,
      self.newCreditCardProperty.signal.skipNil().map { card in [card] }
    )
    .scan([]) { current, new in new + current }

    let cardsAndAvailable = Signal.combineLatest(cards, availableCardTypes)
      .map(cardTypeAvailable(cards:availableCardTypes:))

    let cardValues = Signal.combineLatest(
      cardsAndAvailable,
      project.map { $0.location.displayableName }
    ).map { CardViewValues(cardAndIsAvailableCardType: $0, projectCountry: $1) }

    self.reloadPaymentMethods = cardValues

    self.notifyDelegateApplePayButtonTapped = self.applePayButtonTappedProperty.signal

    self.notifyDelegateLoadPaymentMethodsError = storedCardsEvent
      .errors()
      .map { $0.localizedDescription }

    self.notifyDelegateCreditCardSelected = self.creditCardSelectedSignal
      .skipRepeats()

    self.updateSelectedCreditCard = cards
      .takePairWhen(self.creditCardSelectedSignal)
      .map { cards, id in cards.filter { $0.id == id }.first }
      .skipNil()

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

  public let applePayButtonHidden: Signal<Bool, Never>
  public let goToAddCardScreen: Signal<(AddNewCardIntent, Project), Never>
  public let notifyDelegateApplePayButtonTapped: Signal<Void, Never>
  public let notifyDelegateCreditCardSelected: Signal<String, Never>
  public let notifyDelegateLoadPaymentMethodsError: Signal<String, Never>
  public let reloadPaymentMethods: Signal<CardViewValues, Never>

  public let updateSelectedCreditCard: Signal<GraphUserCreditCard.CreditCard, Never>

  public var inputs: PledgePaymentMethodsViewModelInputs { return self }
  public var outputs: PledgePaymentMethodsViewModelOutputs { return self }
}

private func cardTypeAvailable(cards: [GraphUserCreditCard.CreditCard], availableCardTypes: [String])
  -> [(card: GraphUserCreditCard.CreditCard, cardTypeIsAvailable: Bool)] {
  var cardsWithIsAvailableCardType: [(GraphUserCreditCard.CreditCard, Bool)] = []

  cards.forEach { card in
    guard let cardBrand = card.type?.rawValue else { return }
    let isAvailableCardType = availableCardTypes.contains(cardBrand)
    cardsWithIsAvailableCardType.append((card, isAvailableCardType))
  }

  return cardsWithIsAvailableCardType
}

private func showApplePayButton(for project: Project, applePayCapable: Bool) -> Bool {
  return applePayCapable &&
    AppEnvironment.current.config?.applePayCountries.contains(project.country.countryCode) ?? false
}
