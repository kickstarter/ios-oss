import KsApi
import PassKit
import Prelude
import ReactiveSwift
import Stripe
import UIKit

public enum PaymentMethodsTableViewSection: Int {
  case paymentMethods
  case addNewCard
  case loading
}

public typealias PledgePaymentMethodsValue = (
  user: User,
  project: Project,
  reward: Reward,
  context: PledgeViewContext,
  refTag: RefTag?
)

public typealias PaymentSheetSetupData = (
  clientSecret: String,
  configuration: PaymentSheet.Configuration
)

public typealias PledgePaymentMethodsAndSelectionData = (
  paymentMethodsCellData: [PledgePaymentMethodCellData],
  paymentSheetPaymentMethodsCellData: PaymentSheetPaymentMethodCellData?,
  selectedCard: UserCreditCards.CreditCard?,
  shouldReload: Bool,
  isLoading: Bool
)

public protocol PledgePaymentMethodsViewModelInputs {
  func addNewCardViewControllerDidAdd(newCard card: UserCreditCards.CreditCard)
  func configure(with value: PledgePaymentMethodsValue)
  func didSelectRowAtIndexPath(_ indexPath: IndexPath)
  func paymentSheetDidAdd(newCard card: PaymentSheet.FlowController.PaymentOptionDisplayData)
  func viewDidLoad()
  func willSelectRowAtIndexPath(_ indexPath: IndexPath) -> IndexPath?
}

public protocol PledgePaymentMethodsViewModelOutputs {
  var goToAddCardScreen: Signal<(AddNewCardIntent, Project), Never> { get }
  var goToAddCardViaStripeScreen: Signal<PaymentSheetSetupData, Never> { get }
  var notifyDelegateCreditCardSelected: Signal<String, Never> { get }
  var notifyDelegateLoadPaymentMethodsError: Signal<String, Never> { get }
  var reloadPaymentMethods: Signal<PledgePaymentMethodsAndSelectionData, Never> { get }
  var showLoadingIndicatorView: Signal<Bool, Never> { get }
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
          .fetchGraphUser(withStoredCards: true)
          .ksr_debounce(.seconds(1), on: AppEnvironment.current.scheduler)
          .map { envelope in (envelope, false) }
          .prefix(value: (nil, true))
          .materialize()
      }

    let storedCardsValues = storedCardsEvent.values()
      .filter(second >>> isFalse)
      .map(first)
      .skipNil()
      .map { $0.me.storedCards.storedCards }

    let backing = configureWithValue
      .map { $0.project.personalization.backing }

    let storedCards = Signal.combineLatest(storedCardsValues, backing)
      .map(cards(_:orderedBy:))

    let initialCardData = Signal.combineLatest(
      storedCards,
      availableCardTypes,
      project
    )
    .map { ($0.0, $0.1, $0.2, false) }

    let newSetupIntentCard = self.newSetupIntentCreditCardProperty.signal.skipNil()
      .map { (image: $0.image, redactedCardNumber: $0.label) }

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

    let cards = Signal.merge(
      initialCardData,
      newCardAdded
    )
    .map(pledgePaymentMethodCellDataAndSelectedCard)

    let updatedCards = cards
      .takePairWhen(self.didSelectRowAtIndexPathProperty.signal.skipNil())
      .map(unpack)
      .filter { _, _, indexPath in
        indexPath.section == PaymentMethodsTableViewSection.paymentMethods.rawValue
      }
      .map { data, _, indexPath -> PledgePaymentMethodsAndSelectionData? in
        guard data.count > indexPath.row else { return nil }
        let card = data[indexPath.row].card

        return (
          paymentMethodsCellData: cellData(data, selecting: card),
          paymentSheetPaymentMethodsCellData: nil,
          selectedCard: card,
          shouldReload: false,
          isLoading: false
        )
      }
      .skipNil()

    let configuredCards: Signal<PledgePaymentMethodsAndSelectionData, Never> = cards
      .map { cellData, selectedCard -> PledgePaymentMethodsAndSelectionData in
        PledgePaymentMethodsAndSelectionData(
          paymentMethodsCellData: cellData,
          paymentSheetPaymentMethodsCellData: nil,
          selectedCard: selectedCard,
          shouldReload: true,
          isLoading: false
        )
      }

    let reloadWithLoadingCell: Signal<PledgePaymentMethodsAndSelectionData, Never> = storedCardsEvent.values()
      .filter(second >>> isTrue)
      .map { _ in (
        paymentMethodsCellData: [],
        paymentSheetPaymentMethodsCellData: nil,
        selectedCard: nil,
        shouldReload: true,
        isLoading: true
      ) }

    self.reloadPaymentMethods = Signal.merge(
      reloadWithLoadingCell,
      configuredCards,
      updatedCards
    )

    self.notifyDelegateCreditCardSelected = self.reloadPaymentMethods
      .map { $0.selectedCard?.id }
      .skipNil()
      .skipRepeats()

    let didTapToAddNewCard = self.didSelectRowAtIndexPathProperty.signal.skipNil()
      .filter { $0.section == PaymentMethodsTableViewSection.addNewCard.rawValue }

    // TODO: Hook into Optimizely flag here (either go the `goToAddCardScreen` or `goToAddCardViaStripeScreen` route.). Ie. Only create a setup intent when the add new card button is tapped and the optimizely flag allows showing the payment sheet.

    self.goToAddCardScreen = project
      .takeWhen(didTapToAddNewCard)
      .map { project in (.pledge, project) }

    let createSetupIntentEvent = project
      .takeWhen(didTapToAddNewCard)
      .switchMap { project in
        AppEnvironment.current.apiService
          .createStripeSetupIntent(input: CreateSetupIntentInput(projectId: project.graphID))
          .ksr_debounce(.seconds(1), on: AppEnvironment.current.scheduler)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .switchMap { envelope -> SignalProducer<PaymentSheetSetupData, ErrorEnvelope> in
            var configuration = PaymentSheet.Configuration()
            configuration.merchantDisplayName = Strings.general_accessibility_kickstarter()
            configuration.allowsDelayedPaymentMethods = true

            let data = PaymentSheetSetupData(
              clientSecret: envelope.clientSecret,
              configuration: configuration
            )

            return SignalProducer(value: data)
          }
          .materialize()
      }

    self.goToAddCardViaStripeScreen = createSetupIntentEvent.values()

    self.notifyDelegateLoadPaymentMethodsError = Signal
      .merge(storedCardsEvent.errors(), createSetupIntentEvent.errors())
      .map { $0.localizedDescription }

    self.showLoadingIndicatorView = Signal.merge(
      project.takeWhen(didTapToAddNewCard).mapConst(true),
      createSetupIntentEvent.errors().mapConst(false)
    )

    self.willSelectRowAtIndexPathReturnProperty <~ self.reloadPaymentMethods
      .map { $0.paymentMethodsCellData }
      .takePairWhen(self.willSelectRowAtIndexPathProperty.signal.skipNil())
      .map { cellData, indexPath -> IndexPath? in
        guard
          // the cell is in the payment methods or add new card section.
          [
            PaymentMethodsTableViewSection.paymentMethods.rawValue,
            PaymentMethodsTableViewSection.addNewCard.rawValue
          ]
          .contains(indexPath.section),
          // the row is within bounds and the card is enabled,
          (cellData.count > indexPath.row && cellData[indexPath.row].isEnabled) ||
          // or we're adding a new card.
          indexPath.section == PaymentMethodsTableViewSection.addNewCard.rawValue
        else { return nil }

        return indexPath
      }
  }

  private let configureWithValueProperty = MutableProperty<PledgePaymentMethodsValue?>(nil)
  public func configure(with value: PledgePaymentMethodsValue) {
    self.configureWithValueProperty.value = value
  }

  private let newCreditCardProperty = MutableProperty<UserCreditCards.CreditCard?>(nil)
  public func addNewCardViewControllerDidAdd(newCard card: UserCreditCards.CreditCard) {
    self.newCreditCardProperty.value = card
  }

  private let newSetupIntentCreditCardProperty =
    MutableProperty<PaymentSheet.FlowController.PaymentOptionDisplayData?>(nil)
  public func paymentSheetDidAdd(newCard card: PaymentSheet.FlowController.PaymentOptionDisplayData) {
    self.newSetupIntentCreditCardProperty.value = card
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  private let didSelectRowAtIndexPathProperty = MutableProperty<IndexPath?>(nil)
  public func didSelectRowAtIndexPath(_ indexPath: IndexPath) {
    self.didSelectRowAtIndexPathProperty.value = indexPath
  }

  private let willSelectRowAtIndexPathProperty = MutableProperty<IndexPath?>(nil)
  private let willSelectRowAtIndexPathReturnProperty = MutableProperty<IndexPath?>(nil)
  public func willSelectRowAtIndexPath(_ indexPath: IndexPath) -> IndexPath? {
    self.willSelectRowAtIndexPathProperty.value = indexPath
    return self.willSelectRowAtIndexPathReturnProperty.value
  }

  public let goToAddCardScreen: Signal<(AddNewCardIntent, Project), Never>
  public let goToAddCardViaStripeScreen: Signal<PaymentSheetSetupData, Never>
  public let notifyDelegateCreditCardSelected: Signal<String, Never>
  public let notifyDelegateLoadPaymentMethodsError: Signal<String, Never>
  public let reloadPaymentMethods: Signal<PledgePaymentMethodsAndSelectionData, Never>
  public let showLoadingIndicatorView: Signal<Bool, Never>

  public var inputs: PledgePaymentMethodsViewModelInputs { return self }
  public var outputs: PledgePaymentMethodsViewModelOutputs { return self }
}

private func pledgePaymentMethodCellDataAndSelectedCard(
  with cards: [UserCreditCards.CreditCard],
  availableCardTypes: [String],
  project: Project,
  newCardAdded: Bool
) -> ([PledgePaymentMethodCellData], UserCreditCards.CreditCard?) {
  let data = cards.compactMap { card -> PledgePaymentMethodCellData? in
    guard let cardBrand = card.type?.rawValue else { return nil }

    let backing = project.personalization.backing
    let isAvailableCardType = availableCardTypes.contains(cardBrand)

    let isErroredPaymentMethod = card.id == backing?.paymentSource?.id && backing?.status == .errored

    return (
      card: card,
      isEnabled: isAvailableCardType,
      isSelected: false,
      projectCountry: project.location.displayableName,
      isErroredPaymentMethod: isErroredPaymentMethod
    )
  }
  // Position unavailable cards last
  .sorted { data1, data2 -> Bool in data1.isEnabled && !data2.isEnabled }

  let orderedCards = data.map { $0.card }

  // If there is no backing, simply select the first card in the list when it is an available card type.
  guard let backing = project.personalization.backing else {
    guard let cardData = data.first, cardData.isEnabled else {
      return (data, nil)
    }

    let selected = orderedCards.first

    return (cellData(data, selecting: selected), selected)
  }

  // If we're working with a backing, but we have a newly added card, select the newly added card.
  if newCardAdded {
    let selected = orderedCards.first

    return (cellData(data, selecting: selected), selected)
  }

  if cards.first(where: { $0.id == backing.paymentSource?.id }) != nil, backing.status == .errored {
    return (data, nil)
  }

  /*
   If we're working with a backing, and a new card hasn't been added,
   select the card that the backing is associated with.
   */
  let backedCard = orderedCards.first(where: { $0.id == backing.paymentSource?.id })

  return (cellData(data, selecting: backedCard), backedCard)
}

private func cellData(
  _ data: [PledgePaymentMethodCellData],
  selecting card: UserCreditCards.CreditCard?
) -> [PledgePaymentMethodCellData] {
  return data.map { value in
    (
      value.card,
      value.isEnabled,
      value.card == card,
      value.projectCountry,
      value.isErroredPaymentMethod
    )
  }
}

private func isCreatingPledge(_ project: Project) -> Bool {
  guard let isBacking = project.personalization.isBacking else { return true }

  return !isBacking
}

private func cards(
  _ cards: [UserCreditCards.CreditCard],
  orderedBy backing: Backing?
) -> [UserCreditCards.CreditCard] {
  return cards.sorted { card1, _ in card1.id == backing?.paymentSource?.id }
}
