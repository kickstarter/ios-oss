import KsApi
import PassKit
import Prelude
import ReactiveSwift
import StripePaymentSheet
import UIKit

public enum PaymentMethodsTableViewSection: Int {
  case paymentMethods
  case addNewCard
  case loading
}

public typealias PledgePaymentMethodsValue = (
  user: User,
  project: Project,
  checkoutId: String, /// Used for creating Payment Intents in the Late Pledge flow.
  reward: Reward,
  context: PledgeViewContext,
  refTag: RefTag?
)

public typealias PaymentSheetSetupData = (
  clientSecret: String,
  configuration: PaymentSheet.Configuration
)

public protocol PledgePaymentMethodsViewModelInputs {
  func shouldCancelPaymentSheetAppearance(state: Bool)
  func stripePaymentSheetDidAppear()
  func configure(with value: PledgePaymentMethodsValue)
  func didSelectRowAtIndexPath(_ indexPath: IndexPath)
  func paymentSheetDidAdd(
    clientSecret: String,
    paymentMethod: String?
  )
  func viewDidLoad()
  func willSelectRowAtIndexPath(_ indexPath: IndexPath) -> IndexPath?
}

public protocol PledgePaymentMethodsViewModelOutputs {
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
  let stripeIntentService: StripeIntentServiceType

  public init(stripeIntentService: StripeIntentServiceType) {
    self.stripeIntentService = stripeIntentService

    let configureWithValue = Signal.combineLatest(
      self.viewDidLoadProperty.signal,
      self.configureWithValueProperty.signal.skipNil()
    )
    .map(second)

    let project = configureWithValue.map { $0.project }
    let context = configureWithValue.map { $0.context }
    let checkoutId = configureWithValue.map { $0.checkoutId }
    let availableCardTypes = project.map { $0.availableCardTypes }.skipNil()

    let paymentSheetEnabled = true

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

    let newlyAddedCardProducer = self.newStripeIntentCreditCardProperty.signal.skipNil()
      .switchMap { setupIntent, paymentMethodId -> SignalProducer<
        Signal<UserCreditCards.CreditCard, ErrorEnvelope>.Event,
        Never
      > in
        let input = CreatePaymentSourceSetupIntentInput.init(intentClientSecret: setupIntent, reuseable: true)
        return AppEnvironment.current.apiService.addPaymentSheetPaymentSource(input: input)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .map { (envelope: CreatePaymentSourceEnvelope) -> UserCreditCards.CreditCard? in
            guard envelope.createPaymentSource.isSuccessful else {
              return nil
            }

            // There is a backend bug (PAY-2911) where the stripeCardId isn't being refreshed
            // after the add card mutation is called. This adds it back in.
            var card = envelope.createPaymentSource.paymentSource
            if card.stripeCardId == nil {
              card.stripeCardId = paymentMethodId
            }

            return card
          }
          .skipNil()
          .materialize()
      }

    let allNewlyAddedCards: Signal<[UserCreditCards.CreditCard], Never> = newlyAddedCardProducer.values()
      .scan(into: []) { array, card in
        array.insert(card, at: 0)
      }

    let newCardsData: Signal<([PledgePaymentMethodCellData], UserCreditCards.CreditCard?), Never> = Signal
      .combineLatest(
        allNewlyAddedCards,
        availableCardTypes,
        project
      )
      .map { cards, availableCardTypes, project in
        pledgePaymentMethodCellDataAndSelectedCard(
          with: cards,
          availableCardTypes: availableCardTypes,
          project: project,
          newCardAdded: true
        )
      }

    let allCards = Signal.merge(
      storedCards
    )
    .scan([]) { current, new in new + current }

    let cards = initialCardData
      .map(pledgePaymentMethodCellDataAndSelectedCard)

    let reloadWithLoadingCell: Signal<PledgePaymentMethodsAndSelectionData, Never> = storedCardsEvent.values()
      .filter(second >>> isTrue)
      .map { _ in PledgePaymentMethodsAndSelectionData(
        existingPaymentMethods: [],
        newPaymentMethods: [],
        selectedPaymentMethod: nil,
        isLoading: true,
        shouldReload: true
      ) }

    let configuredCards: Signal<PledgePaymentMethodsAndSelectionData, Never> = cards
      .map { cellData, selectedCard -> PledgePaymentMethodsAndSelectionData in

        var selectedPaymentMethod: PaymentSourceSelected?
        if let card = selectedCard {
          selectedPaymentMethod = createSelectedPaymentMethod(from: card)
        }

        return PledgePaymentMethodsAndSelectionData(
          existingPaymentMethods: cellData,
          newPaymentMethods: [],
          selectedPaymentMethod: selectedPaymentMethod,
          isLoading: false,
          shouldReload: true
        )
      }

    let configuredCardsWithNewSetupIntentCards = configuredCards
      .takePairWhen(newCardsData)
      .map { cards, setupIntentCards -> PledgePaymentMethodsAndSelectionData in
        let (newCards, newSelectedCard) = setupIntentCards

        var updatedCardData = cards
        updatedCardData.newPaymentMethods = newCards

        if let selectedCard = newSelectedCard {
          updatedCardData.selectedPaymentMethod = createSelectedPaymentMethod(from: selectedCard)
        }

        let updatedPaymentMethodSelectionData =
          pledgePaymentSheetMethodCellDataAndSelectedCardSetupIntent(
            with: updatedCardData
          )

        return updatedPaymentMethodSelectionData
      }

    let updatedCardsWithNewSetupIntentCards = Signal.merge(
      configuredCards,
      configuredCardsWithNewSetupIntentCards
    )
    .map { pledgePaymentMethodsAndSelectionData -> PledgePaymentMethodsAndSelectionData in
      var updatedData = pledgePaymentMethodsAndSelectionData
      updatedData.isLoading = false
      updatedData.shouldReload = false
      return updatedData
    }

    let updatedCards = updatedCardsWithNewSetupIntentCards
      .takePairWhen(self.didSelectRowAtIndexPathProperty.signal.skipNil())
      .filter { _, indexPath in
        indexPath.section == PaymentMethodsTableViewSection.paymentMethods.rawValue
      }
      .map { (
        data: PledgePaymentMethodsAndSelectionData,
        indexPath: IndexPath
      ) -> PledgePaymentMethodsAndSelectionData? in
        let updatedData = PledgePaymentMethodsAndSelectionData(
          existingPaymentMethods: [],
          newPaymentMethods: [],
          selectedPaymentMethod: nil,
          isLoading: false,
          shouldReload: true
        )

        let paymentMethodCount = data.existingPaymentMethods.count
        let paymentSheetPaymentMethodCount = data.newPaymentMethods.count

        if indexPath.row < paymentSheetPaymentMethodCount {
          // we are selecting a new payment sheet card
          let card = data.newPaymentMethods[indexPath.row].card

          var selectionUpdatedData = updatedData
          selectionUpdatedData.existingPaymentMethods = cellData(data.existingPaymentMethods, selecting: nil)
          selectionUpdatedData.newPaymentMethods = cellData(data.newPaymentMethods, selecting: card)
          selectionUpdatedData.selectedPaymentMethod = createSelectedPaymentMethod(from: card)

          return selectionUpdatedData
        } else if indexPath.row < paymentSheetPaymentMethodCount + paymentMethodCount {
          // we are selecting an existing payment card
          let card = data.existingPaymentMethods[indexPath.row - paymentSheetPaymentMethodCount].card

          var selectionUpdatedData = updatedData
          selectionUpdatedData.existingPaymentMethods = cellData(data.existingPaymentMethods, selecting: card)
          selectionUpdatedData.newPaymentMethods = cellData(data.newPaymentMethods, selecting: nil)
          selectionUpdatedData.selectedPaymentMethod = createSelectedPaymentMethod(from: card)
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
      .map { $0.selectedPaymentMethod }
      .skipNil()
      .skipRepeats()

    let didTapToAddNewCard = self.didSelectRowAtIndexPathProperty.signal.skipNil()
      .filter { $0.section == PaymentMethodsTableViewSection.addNewCard.rawValue }

    let paymentSheetOnPledgeContext = context.map { _ in paymentSheetEnabled }

    let showLoadingIndicator = Signal.combineLatest(project, paymentSheetOnPledgeContext.filter(isTrue))
      .takeWhen(didTapToAddNewCard)
      .mapConst(true)

    self.shouldCancelPaymentSheetAppearance <~ showLoadingIndicator.mapConst(false)

    self.shouldCancelPaymentSheetAppearance <~ updatedCards.signal
      .mapConst(true)

    // Only ever use the value if the view model is configured and the payment sheet could exist.
    // In the logged out state, the payment sheet is part of the view without being configured,
    // so this is a real risk.
    let safeShouldCancelPaymentSheet = Signal.combineLatest(
      self.shouldCancelPaymentSheetAppearance.signal,
      configureWithValue
    )
    .map(first)

    let createSetupIntentEvent = Signal.combineLatest(
      project,
      checkoutId,
      context
    )
    .takeWhen(didTapToAddNewCard)
    .switchMap { project, _, pledgeContext -> SignalProducer<
      Signal<PaymentSheetSetupData, ErrorEnvelope>.Event,
      Never
    > in

      let setupIntentContext = pledgeContext == .latePledge
        ? GraphAPI.StripeIntentContextTypes.postCampaignCheckout
        : GraphAPI.StripeIntentContextTypes.crowdfundingCheckout
      let clientSecretSignal: SignalProducer<String, ErrorEnvelope> = stripeIntentService.createSetupIntent(
        for: project.graphID,
        context: setupIntentContext
      )
      .map { $0.clientSecret }

      return clientSecretSignal
        .ksr_debounce(.seconds(1), on: AppEnvironment.current.scheduler)
        .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
        .switchMap { clientSecret -> SignalProducer<PaymentSheetSetupData, ErrorEnvelope> in

          var configuration = PaymentSheet.Configuration()
          configuration.merchantDisplayName = Strings.general_accessibility_kickstarter()
          configuration.allowsDelayedPaymentMethods = true

          // Log in to Stripe Link
          configuration.defaultBillingDetails.email = AppEnvironment.current.currentUserEmail

          let data = PaymentSheetSetupData(
            clientSecret: clientSecret,
            configuration: configuration
          )

          return SignalProducer(value: data)
        }
        .materialize()
    }

    self.goToAddCardViaStripeScreen = createSetupIntentEvent.values()
      .withLatestFrom(safeShouldCancelPaymentSheet)
      .map { data, shouldCancel -> PaymentSheetSetupData? in
        shouldCancel ? nil : data
      }
      .skipNil()

    self.notifyDelegateLoadPaymentMethodsError = Signal
      .merge(storedCardsEvent.errors(), createSetupIntentEvent.errors(), newlyAddedCardProducer.errors())
      .map { $0.localizedDescription }

    self.updateAddNewCardLoading = Signal.merge(
      createSetupIntentEvent.errors().mapConst(false),
      safeShouldCancelPaymentSheet.negate()
    )

    self.willSelectRowAtIndexPathReturnProperty <~ self.reloadPaymentMethods
      .map { ($0.existingPaymentMethods, $0.newPaymentMethods) }
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
          (
            allEnabledPaymentMethodCells.count > indexPath
              .row && allEnabledPaymentMethodCells[indexPath.row]
          ) ||
          // or we're adding a new card.
          indexPath.section == PaymentMethodsTableViewSection.addNewCard.rawValue
        else { return nil }

        return indexPath
      }

    // Facebook CAPI + Google Analytics
    let stripePaymentSheetDidAppear = self.stripePaymentSheetDidAppearProperty.signal

    _ = Signal.combineLatest(project, self.viewDidLoadProperty.signal)
      .takeWhen(stripePaymentSheetDidAppear)
      .observeValues { project, _ in

        AppEnvironment.current.appTrackingTransparency.updateAdvertisingIdentifier()

        guard let externalId = AppEnvironment.current.appTrackingTransparency.advertisingIdentifier
        else { return }

        var userId = ""

        if let userValue = AppEnvironment.current.currentUser {
          userId = "\(userValue.id)"
        }

        let projectId = "\(project.id)"

        var extInfo = Array(repeating: "", count: 16)
        extInfo[0] = "i2"
        extInfo[4] = AppEnvironment.current.mainBundle.platformVersion

        _ = AppEnvironment
          .current
          .apiService
          .triggerThirdPartyEventInput(
            input: .init(
              deviceId: externalId,
              eventName: ThirdPartyEventInputName.AddNewPaymentMethod.rawValue,
              projectId: projectId,
              pledgeAmount: nil,
              shipping: nil,
              transactionId: nil,
              userId: userId,
              appData: .init(
                advertiserTrackingEnabled: true,
                applicationTrackingEnabled: true,
                extinfo: extInfo
              ),
              clientMutationId: ""
            )
          )
      }
  }

  private let configureWithValueProperty = MutableProperty<PledgePaymentMethodsValue?>(nil)
  public func configure(with value: PledgePaymentMethodsValue) {
    self.configureWithValueProperty.value = value
  }

  private let newStripeIntentCreditCardProperty =
    MutableProperty<(String, String?)?>(nil)
  public func paymentSheetDidAdd(
    clientSecret: String,
    paymentMethod: String?
  ) {
    self.newStripeIntentCreditCardProperty.value = (clientSecret, paymentMethod)
  }

  private let shouldCancelPaymentSheetAppearance = MutableProperty<Bool>(true)
  public func shouldCancelPaymentSheetAppearance(state: Bool) {
    self.shouldCancelPaymentSheetAppearance.value = state
  }

  private let stripePaymentSheetDidAppearProperty = MutableProperty(())
  public func stripePaymentSheetDidAppear() {
    self.stripePaymentSheetDidAppearProperty.value = ()
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

  public let goToAddCardViaStripeScreen: Signal<PaymentSheetSetupData, Never>
  public let notifyDelegateCreditCardSelected: Signal<PaymentSourceSelected, Never>
  public let notifyDelegateLoadPaymentMethodsError: Signal<String, Never>
  public let reloadPaymentMethods: Signal<PledgePaymentMethodsAndSelectionData, Never>
  public let updateAddNewCardLoading: Signal<Bool, Never>

  public var inputs: PledgePaymentMethodsViewModelInputs { return self }
  public var outputs: PledgePaymentMethodsViewModelOutputs { return self }
}

private func pledgePaymentSheetMethodCellDataAndSelectedCardSetupIntent(
  with paymentMethodData: PledgePaymentMethodsAndSelectionData
) -> PledgePaymentMethodsAndSelectionData {
  // We know we have a new payment sheet card, so de-select all existing non-payment sheet cards.
  let preexistingCardDataUnselected: [PledgePaymentMethodCellData] = {
    paymentMethodData.existingPaymentMethods
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
  let newCardDataUnselected: [PledgePaymentMethodCellData] = {
    var updatedNewPaymentMethodData = paymentMethodData.newPaymentMethods

    updatedNewPaymentMethodData = updatedNewPaymentMethodData.map { data in
      (
        card: data.card,
        isEnabled: data.isEnabled,
        isSelected: false,
        projectCountry: data.projectCountry,
        isErroredPaymentMethod: data.isErroredPaymentMethod
      )
    }

    return updatedNewPaymentMethodData
  }()

  let updatedDataWithSelection: PledgePaymentMethodsAndSelectionData = {
    guard let newestPaymentSheetPaymentMethod = paymentMethodData.newPaymentMethods.first
    else {
      return paymentMethodData
    }

    // We know the first new payment sheet card added is the newest one, so by default select it.
    var data = newCardDataUnselected

    var updatedSelectedPaymentSheetPaymentMethod = data[0]

    if updatedSelectedPaymentSheetPaymentMethod.isEnabled {
      updatedSelectedPaymentSheetPaymentMethod.isSelected = true
    }

    data[0] = updatedSelectedPaymentSheetPaymentMethod

    var updatePaymentMethodData = paymentMethodData
    updatePaymentMethodData.existingPaymentMethods = preexistingCardDataUnselected
    updatePaymentMethodData.newPaymentMethods = data

    if newestPaymentSheetPaymentMethod.isEnabled {
      updatePaymentMethodData
        .selectedPaymentMethod = createSelectedPaymentMethod(from: newestPaymentSheetPaymentMethod.card)
    }

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

private func createSelectedPaymentMethod(from card: UserCreditCards.CreditCard) -> PaymentSourceSelected {
  guard let stripeCardId = card.stripeCardId, !stripeCardId.isEmpty else {
    assert(false, "Expected stripeCardId to be set. Late pledges may fail if this value is missing.")
    return .savedCreditCard(card.id, nil)
  }

  return .savedCreditCard(card.id, stripeCardId)
}
