import KsApi
import PassKit
import Prelude
import ReactiveSwift
import UIKit

public typealias PledgePaymentMethodsValue = (user: User, project: Project, deviceIsApplePayCapable: Bool)

public protocol PledgePaymentMethodsViewModelInputs {
  func applePayButtonTapped()
  func configureWith(_ value: PledgePaymentMethodsValue)
  func creditCardSelected(paymentSourceId: String)
  func addNewCardViewControllerDidAdd(newCard card: GraphUserCreditCard.CreditCard)
  func viewDidLoad()
  func addNewCardTapped(with intent: AddNewCardIntent)
}

public protocol PledgePaymentMethodsViewModelOutputs {
  var applePayStackViewHidden: Signal<Bool, Never> { get }
  var goToAddCardScreen: Signal<(AddNewCardIntent, Project), Never> { get }
  var notifyDelegateApplePayButtonTapped: Signal<Void, Never> { get }
  var notifyDelegateCreditCardSelected: Signal<String, Never> { get }
  var notifyDelegateLoadPaymentMethodsError: Signal<String, Never> { get }
  var reloadPaymentMethodsAndSelectCard:
    Signal<([PledgeCreditCardViewData], GraphUserCreditCard.CreditCard?), Never> { get }
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

    self.applePayStackViewHidden = configureWithValue
      .map { ($0.project, $0.deviceIsApplePayCapable) }
      .map(showApplePayButton(for:applePayDevice:))
      .negate()

    let storedCardsValues = storedCardsEvent.values().map { $0.me.storedCards.nodes }
    let backing = configureWithValue.map { $0.project.personalization.backing }

    let storedCards = Signal.combineLatest(storedCardsValues, backing)
      .map(cards(_:orderedBy:))

    let initialCardData = Signal.combineLatest(
      storedCards,
      availableCardTypes,
      project
    )
    .map { ($0.0, $0.1, $0.2, false) }

    let newCard = self.newCreditCardProperty.signal.skipNil()

    let allCards = Signal.merge(
      storedCards,
      newCard.map { [$0] }
    )
    .scan([]) { current, new in new + current }

    let allCardData = Signal.combineLatest(
      allCards,
      availableCardTypes,
      project
    )

    let newCardAdded = allCardData
      .takePairWhen(newCard)
      .map { cardData, _ in (cardData.0, cardData.1, cardData.2, true) }

    self.reloadPaymentMethodsAndSelectCard = Signal.merge(
      initialCardData,
      newCardAdded
    )
    .map(pledgeCreditCardViewDataAndSelectedCard)

    self.notifyDelegateApplePayButtonTapped = self.applePayButtonTappedProperty.signal

    self.notifyDelegateLoadPaymentMethodsError = storedCardsEvent
      .errors()
      .map { $0.localizedDescription }

    self.notifyDelegateCreditCardSelected = self.creditCardSelectedSignal
      .skipRepeats()

    self.updateSelectedCreditCard = allCards
      .takePairWhen(self.creditCardSelectedSignal)
      .map { cards, id in cards.filter { $0.id == id }.first }
      .skipNil()

    self.goToAddCardScreen = Signal.combineLatest(self.addNewCardIntentProperty.signal.skipNil(), project)

    // Tracking

    project
      .filter { isCreatingPledge($0) }
      .takeWhen(self.goToAddCardScreen)
      .observeValues {
        AppEnvironment.current.koala.trackAddNewCardButtonClicked(
          project: $0
        )
      }
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

  public let applePayStackViewHidden: Signal<Bool, Never>
  public let goToAddCardScreen: Signal<(AddNewCardIntent, Project), Never>
  public let notifyDelegateApplePayButtonTapped: Signal<Void, Never>
  public let notifyDelegateCreditCardSelected: Signal<String, Never>
  public let notifyDelegateLoadPaymentMethodsError: Signal<String, Never>
  public let reloadPaymentMethodsAndSelectCard:
    Signal<([PledgeCreditCardViewData], GraphUserCreditCard.CreditCard?), Never>
  public let updateSelectedCreditCard: Signal<GraphUserCreditCard.CreditCard, Never>

  public var inputs: PledgePaymentMethodsViewModelInputs { return self }
  public var outputs: PledgePaymentMethodsViewModelOutputs { return self }
}

private func pledgeCreditCardViewDataAndSelectedCard(
  with cards: [GraphUserCreditCard.CreditCard],
  availableCardTypes: [String],
  project: Project,
  newCardAdded: Bool
) -> ([PledgeCreditCardViewData], GraphUserCreditCard.CreditCard?) {
  let data = cards.compactMap { card -> PledgeCreditCardViewData? in
    guard let cardBrand = card.type?.rawValue else { return nil }

    let isAvailableCardType = availableCardTypes.contains(cardBrand)

    return (card, isAvailableCardType, project.location.displayableName)
  }

  // If there is no backing, simply select the first card in the list when it is an available card type.
  guard let backing = project.personalization.backing else {
    guard let cardData = data.first, cardData.isEnabled else {
      return (data, nil)
    }

    return (data, cards.first)
  }

  // If we're working with a backing, but we have a newly added card, select the newly added card.
  if newCardAdded {
    return (data, cards.first)
  }

  /*
   If we're working with a backing, and a new card hasn't been added,
   select the card that the backing is associated with.
   */
  let backedCard = cards.first(where: { $0.id == backing.paymentSource?.id })

  return (data, backedCard)
}

private func showApplePayButton(for project: Project, applePayDevice: Bool) -> Bool {
  return applePayDevice &&
    AppEnvironment.current.config?.applePayCountries.contains(project.country.countryCode) ?? false
}

private func isCreatingPledge(_ project: Project) -> Bool {
  guard let isBacking = project.personalization.isBacking else { return true }

  return !isBacking
}

private func cards(
  _ cards: [GraphUserCreditCard.CreditCard],
  orderedBy backing: Backing?
) -> [GraphUserCreditCard.CreditCard] {
  return cards.sorted { card1, _ in card1.id == backing?.paymentSource?.id }
}
