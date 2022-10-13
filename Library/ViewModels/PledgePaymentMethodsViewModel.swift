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
  paymentSheetPaymentMethodsCellData: [PaymentSheetPaymentMethodCellData],
  selectedCard: UserCreditCards.CreditCard?,
  selectedSetupIntent: String?,
  shouldReload: Bool,
  isLoading: Bool
)

public protocol PledgePaymentMethodsViewModelInputs {
  func addNewCardViewControllerDidAdd(newCard card: UserCreditCards.CreditCard)
  func shouldCancelPaymentSheetAppearance(state: Bool)
  func configure(with value: PledgePaymentMethodsValue)
  func didSelectRowAtIndexPath(_ indexPath: IndexPath)
  func paymentSheetDidAdd(newCard card: PaymentSheet.FlowController.PaymentOptionDisplayData,
                          setupIntent: String)
  func viewDidLoad()
  func willSelectRowAtIndexPath(_ indexPath: IndexPath) -> IndexPath?
}

public protocol PledgePaymentMethodsViewModelOutputs {
  var goToAddCardScreen: Signal<(AddNewCardIntent, Project), Never> { get }
  var goToAddCardViaStripeScreen: Signal<PaymentSheetSetupData, Never> { get }
  var notifyDelegateCreditCardSelected: Signal<PaymentSourceSelected, Never> { get }
  var notifyDelegateLoadPaymentMethodsError: Signal<String, Never> { get }
  var reloadPaymentMethods: Signal<PledgePaymentMethodsAndSelectionData, Never> { get }
  var updateAddNewCardLoading: Signal<Bool, Never> { get }
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
    let context = configureWithValue.map { $0.context }
    let availableCardTypes = project.map { $0.availableCardTypes }.skipNil()

    lazy var paymentSheetEnabled: Bool = {
      featurePaymentSheetEnabled()
    }()

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

    let newSetupIntentCards = self.newSetupIntentCreditCardProperty.signal.skipNil()
      .map { data -> [PaymentSheetPaymentMethodCellData] in
        let (displayData, setupIntent) = data

        return [(
          image: displayData.image,
          redactedCardNumber: displayData.label,
          setupIntent: setupIntent,
          isSelected: false,
          isEnabled: true
        )]
      }
      .scan([]) { current, new in new + current }

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

    let reloadWithLoadingCell: Signal<PledgePaymentMethodsAndSelectionData, Never> = storedCardsEvent.values()
      .filter(second >>> isTrue)
      .map { _ in (
        paymentMethodsCellData: [],
        paymentSheetPaymentMethodsCellData: [],
        selectedCard: nil,
        selectedSetupIntent: nil,
        shouldReload: true,
        isLoading: true
      ) }

    let configuredCards: Signal<PledgePaymentMethodsAndSelectionData, Never> = cards
      .map { cellData, selectedCard -> PledgePaymentMethodsAndSelectionData in
        PledgePaymentMethodsAndSelectionData(
          paymentMethodsCellData: cellData,
          paymentSheetPaymentMethodsCellData: [],
          selectedCard: selectedCard,
          selectedSetupIntent: nil,
          shouldReload: true,
          isLoading: false
        )
      }

    let configuredCardsWithNewSetupIntentCards = Signal.combineLatest(configuredCards, project)
      .takePairWhen(newSetupIntentCards)
      .map { cardsAndProject, setupIntentCards -> PledgePaymentMethodsAndSelectionData in
        let (cards, project) = cardsAndProject
        let updatedCardData = cards
          |> \.paymentSheetPaymentMethodsCellData .~ setupIntentCards

        let updatedPaymentMethodSelectionData =
          pledgePaymentSheetMethodCellDataAndSelectedCardSetupIntent(with: updatedCardData, project: project)

        return updatedPaymentMethodSelectionData
      }

    let updatedCardsWithNewSetupIntentCards = Signal.merge(
      configuredCards,
      configuredCardsWithNewSetupIntentCards
    )
    .map { pledgePaymentMethodsAndSelectionData -> PledgePaymentMethodsAndSelectionData in
      let updatedPledgePaymentMethodsAndSelectionData = pledgePaymentMethodsAndSelectionData
        |> \.shouldReload .~ false
        |> \.isLoading .~ false

      return updatedPledgePaymentMethodsAndSelectionData
    }

    let updatedCards = updatedCardsWithNewSetupIntentCards
      .takePairWhen(self.didSelectRowAtIndexPathProperty.signal.skipNil())
      .filter { _, indexPath in
        indexPath.section == PaymentMethodsTableViewSection.paymentMethods.rawValue
      }
      .map { data, indexPath -> PledgePaymentMethodsAndSelectionData? in
        let updatedData = data
          |> \.paymentMethodsCellData .~ []
          |> \.paymentSheetPaymentMethodsCellData .~ []
          |> \.selectedCard .~ nil
          |> \.selectedSetupIntent .~ nil
          |> \.isLoading .~ false
          |> \.shouldReload .~ true

        let paymentMethodCount = data.paymentMethodsCellData.count
        let paymentSheetPaymentMethodCount = data.paymentSheetPaymentMethodsCellData.count

        if indexPath.row < paymentSheetPaymentMethodCount {
          // we are selecting a new payment sheet card
          let setupIntent = data.paymentSheetPaymentMethodsCellData[indexPath.row].setupIntent

          let selectedAllSheetPaymentMethods = data.paymentSheetPaymentMethodsCellData.map { data in
            (
              image: data.image,
              redactedCardNumber: data.redactedCardNumber,
              setupIntent: data.setupIntent,
              isSelected: setupIntent == data.setupIntent,
              isEnabled: true
            )
          }

          let selectionUpdatedData = updatedData
            |> \.paymentMethodsCellData .~ cellData(data.paymentMethodsCellData, selecting: nil)
            |> \.paymentSheetPaymentMethodsCellData .~ selectedAllSheetPaymentMethods
            |> \.selectedCard .~ nil
            |> \.selectedSetupIntent .~ setupIntent

          return selectionUpdatedData
        } else if indexPath.row < paymentSheetPaymentMethodCount + paymentMethodCount {
          // we are selecting an existing payment card
          let card = data.paymentMethodsCellData[indexPath.row - paymentSheetPaymentMethodCount].card

          let deselectAllSheetPaymentMethods = data.paymentSheetPaymentMethodsCellData.map { data in
            (
              image: data.image,
              redactedCardNumber: data.redactedCardNumber,
              setupIntent: data.setupIntent,
              isSelected: false,
              isEnabled: data.isEnabled
            )
          }

          let selectionUpdatedData = updatedData
            |> \.paymentMethodsCellData .~ cellData(data.paymentMethodsCellData, selecting: card)
            |> \.paymentSheetPaymentMethodsCellData .~ deselectAllSheetPaymentMethods
            |> \.selectedCard .~ card

          return selectionUpdatedData
        }

        return nil
      }
      .skipNil()

    let configuredPaymentMethodsIncludingSetupIntentCards = Signal.merge(
      configuredCards,
      configuredCardsWithNewSetupIntentCards
    )

    self.reloadPaymentMethods = Signal.merge(
      reloadWithLoadingCell,
      configuredPaymentMethodsIncludingSetupIntentCards,
      updatedCards
    )

    self.notifyDelegateCreditCardSelected = self.reloadPaymentMethods
      .map { paymentMethodData -> PaymentSourceSelected? in
        let selectedPaymentMethodCardId = paymentMethodData.selectedCard?.id
        let selectedPaymentSheetPaymentMethodCardId = paymentMethodData.selectedSetupIntent

        switch (selectedPaymentMethodCardId, selectedPaymentSheetPaymentMethodCardId) {
        case let (.none, .some(selectedPaymentSheetPaymentMethodCardId)):
          return PaymentSourceSelected(
            paymentSourceId: selectedPaymentSheetPaymentMethodCardId,
            isSetupIntentClientSecret: true
          )
        case let (.some(selectedPaymentMethodCardId), .none):
          return PaymentSourceSelected(
            paymentSourceId: selectedPaymentMethodCardId,
            isSetupIntentClientSecret: false
          )
        default:
          return nil
        }
      }
      .skipNil()
      .skipRepeats()

    let didTapToAddNewCard = self.didSelectRowAtIndexPathProperty.signal.skipNil()
      .filter { $0.section == PaymentMethodsTableViewSection.addNewCard.rawValue }

    let paymentSheetOnPledgeContext = context.map { _ in paymentSheetEnabled }

    self.goToAddCardScreen = Signal.combineLatest(
      project,
      paymentSheetOnPledgeContext.filter(isFalse)
    )
    .takeWhen(didTapToAddNewCard)
    .map { project, _ in
      (.pledge, project)
    }

    let showLoadingIndicator = Signal.combineLatest(project, paymentSheetOnPledgeContext.filter(isTrue))
      .takeWhen(didTapToAddNewCard)
      .mapConst(true)

    self.shouldCancelPaymentSheetAppearance <~ showLoadingIndicator.mapConst(false)

    self.shouldCancelPaymentSheetAppearance <~ updatedCards.signal
      .mapConst(true)

    let createSetupIntentEvent = Signal.combineLatest(
      project,
      paymentSheetOnPledgeContext.filter(isTrue)
    )
    .takeWhen(didTapToAddNewCard)
    .switchMap { (project, _) -> SignalProducer<Signal<PaymentSheetSetupData, ErrorEnvelope>.Event, Never> in
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
      .withLatestFrom(self.shouldCancelPaymentSheetAppearance.signal)
      .map { (data, shouldCancel) -> PaymentSheetSetupData? in
        shouldCancel ? nil : data
      }
      .skipNil()

    self.notifyDelegateLoadPaymentMethodsError = Signal
      .merge(storedCardsEvent.errors(), createSetupIntentEvent.errors())
      .map { $0.localizedDescription }

    self.updateAddNewCardLoading = Signal.merge(
      createSetupIntentEvent.errors().mapConst(false),
      self.shouldCancelPaymentSheetAppearance.signal.negate()
    )

    self.willSelectRowAtIndexPathReturnProperty <~ self.reloadPaymentMethods
      .map { ($0.paymentMethodsCellData, $0.paymentSheetPaymentMethodsCellData) }
      .takePairWhen(self.willSelectRowAtIndexPathProperty.signal.skipNil())
      .map { cellData, indexPath -> IndexPath? in
        let enabledPaymentMethodCells = cellData.0.map { $0.isEnabled }
        let enabledPaymentSheetPaymentMethodCells = cellData.1.map { $0.isEnabled }
        // order is important here, because payment sheet method cells are always displayed before payment method cells and we check select them from top (0) onward... (1,2,3, etc)
        let allEnabledPaymentMethodCells = enabledPaymentSheetPaymentMethodCells + enabledPaymentMethodCells

        guard
          // the cell is in the payment methods or add new card section.
          [
            PaymentMethodsTableViewSection.paymentMethods.rawValue,
            PaymentMethodsTableViewSection.addNewCard.rawValue
          ]
          .contains(indexPath.section),
          // the row is within bounds and the card is enabled,
          (allEnabledPaymentMethodCells.count > indexPath
            .row && allEnabledPaymentMethodCells[indexPath.row]) ||
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
    MutableProperty<(PaymentSheet.FlowController.PaymentOptionDisplayData, String)?>(nil)
  public func paymentSheetDidAdd(
    newCard card: PaymentSheet.FlowController.PaymentOptionDisplayData,
    setupIntent: String
  ) {
    self.newSetupIntentCreditCardProperty.value = (card, setupIntent)
  }

  private let shouldCancelPaymentSheetAppearance = MutableProperty<Bool>(true)
  public func shouldCancelPaymentSheetAppearance(state: Bool) {
    self.shouldCancelPaymentSheetAppearance.value = state
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
  public let notifyDelegateCreditCardSelected: Signal<PaymentSourceSelected, Never>
  public let notifyDelegateLoadPaymentMethodsError: Signal<String, Never>
  public let reloadPaymentMethods: Signal<PledgePaymentMethodsAndSelectionData, Never>
  public let updateAddNewCardLoading: Signal<Bool, Never>

  public var inputs: PledgePaymentMethodsViewModelInputs { return self }
  public var outputs: PledgePaymentMethodsViewModelOutputs { return self }
}

private func pledgePaymentSheetMethodCellDataAndSelectedCardSetupIntent(
  with paymentMethodData: PledgePaymentMethodsAndSelectionData,
  project _: Project
) -> PledgePaymentMethodsAndSelectionData {
  // We know we have a new payment sheet card, so de-select all existing non-payment sheet cards.
  let preexistingCardDataUnselected: [PledgePaymentMethodCellData] = {
    paymentMethodData.paymentMethodsCellData
      .compactMap { data -> PledgePaymentMethodCellData? in

        (
          card: data.card,
          isEnabled: data.isEnabled,
          isSelected: false,
          projectCountry: data.projectCountry,
          isErroredPaymentMethod: data.isErroredPaymentMethod
        )
      }
  }()

  // First ensure all existing payment sheet payment methods are not selected.
  let preexistingPaymentSheetCardDataUnselected: [PaymentSheetPaymentMethodCellData] = {
    var updatedPaymentSheetPaymentMethodData = paymentMethodData.paymentSheetPaymentMethodsCellData

    updatedPaymentSheetPaymentMethodData = updatedPaymentSheetPaymentMethodData.map { data in
      (
        image: data.image,
        redactedCardNumber: data.redactedCardNumber,
        setupIntent: data.setupIntent,
        isSelected: false,
        isEnabled: true
      )
    }

    return updatedPaymentSheetPaymentMethodData
  }()

  let updatedDataWithSelection: PledgePaymentMethodsAndSelectionData = {
    guard let newestPaymentSheetPaymentMethod = paymentMethodData.paymentSheetPaymentMethodsCellData.first
    else {
      return paymentMethodData
    }

    // We know the first new payment sheet card added is the newest one, so by default select it.
    var data = preexistingPaymentSheetCardDataUnselected

    let updatedSelectedPaymentSheetPaymentMethod = data[0]
      |> \.isSelected .~ true

    data[0] = updatedSelectedPaymentSheetPaymentMethod

    let updatePaymentMethodData = paymentMethodData
      |> \.paymentMethodsCellData .~ preexistingCardDataUnselected
      |> \.paymentSheetPaymentMethodsCellData .~ data
      |> \.selectedCard .~ nil
      |> \.selectedSetupIntent .~ newestPaymentSheetPaymentMethod.setupIntent

    return updatePaymentMethodData
  }()

  return updatedDataWithSelection

  /**
   Unlike the existing logic inside `pledgePaymentMethodCellDataAndSelectedCard`, we don't know the card id after its' been added, because new payment sheet cards only contain an image and a redacted card number. If we did we can ensure that an errored backing does not highlight the new card if it matches the payment source id on the backing. Right now this flow only handles the latest cards from the payment sheet, so we can simply select the first one added. If this code path is taken the method above is not called again for the same instance of this view controller, the flag is lazy initialized and doesn't change while this page is displayed.
   */
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
