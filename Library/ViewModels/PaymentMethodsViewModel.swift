import Foundation
import KsApi
import Prelude
import ReactiveSwift
import Result

public protocol PaymentMethodsViewModelInputs {
  func addNewCardSucceeded(with message: String)
  func addNewCardDismissed()
  func addNewCardPresented()
  func didDelete(_ creditCard: GraphUserCreditCard.CreditCard, visibleCellCount: Int)
  func editButtonTapped()
  func paymentMethodsFooterViewDidTapAddNewCardButton()
  func viewDidLoad()
  func viewWillAppear()
}

public protocol PaymentMethodsViewModelOutputs {
  var editButtonIsEnabled: Signal<Bool, NoError> { get }
  var editButtonTitle: Signal<String, NoError> { get }
  var errorLoadingPaymentMethods: Signal<String, NoError> { get }
  var goToAddCardScreen: Signal<Void, NoError> { get }
  var paymentMethods: Signal<[GraphUserCreditCard.CreditCard], NoError> { get }
  var presentBanner: Signal<String, NoError> { get }
  var reloadData: Signal<Void, NoError> { get }
  var showAlert: Signal<String, NoError> { get }
  var tableViewIsEditing: Signal<Bool, NoError> { get }
}

public protocol PaymentMethodsViewModelType {
  var inputs: PaymentMethodsViewModelInputs { get }
  var outputs: PaymentMethodsViewModelOutputs { get }
}

public final class PaymentMethodsViewModel: PaymentMethodsViewModelType,
PaymentMethodsViewModelInputs, PaymentMethodsViewModelOutputs {

  public init() {
    self.reloadData = self.viewDidLoadProperty.signal

    let paymentMethodsEvent = Signal.merge(
      self.viewDidLoadProperty.signal,
      self.addNewCardSucceededProperty.signal.ignoreValues(),
      self.addNewCardDismissedProperty.signal
    )
    .switchMap { _ in
      AppEnvironment.current.apiService.fetchGraphCreditCards(query: UserQueries.storedCards.query)
        .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
        .materialize()
    }

    let deletePaymentMethodEvents = self.didDeleteCreditCardSignal
      .map(first)
      .switchMap { creditCard in
        AppEnvironment.current.apiService.deletePaymentMethod(input: .init(paymentSourceId: creditCard.id))
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .materialize()
    }

    let deletePaymentMethodEventsErrors = deletePaymentMethodEvents.errors()

    self.showAlert = deletePaymentMethodEventsErrors
      .ignoreValues()
      .map {
        Strings.Something_went_wrong_and_we_were_unable_to_remove_your_payment_method_please_try_again()
    }

    let initialPaymentMethodsValues = paymentMethodsEvent
      .values().map { $0.me.storedCards.nodes }

    let deletePaymentMethodValues = deletePaymentMethodEvents.values()
      .map { $0.storedCards }

    let latestPaymentMethods = Signal.merge(
      initialPaymentMethodsValues,
      deletePaymentMethodValues
    )

    self.errorLoadingPaymentMethods = paymentMethodsEvent.errors().map { $0.localizedDescription }

    self.paymentMethods = Signal.merge(
      initialPaymentMethodsValues,
      deletePaymentMethodEventsErrors
        .withLatest(from: latestPaymentMethods)
        .map(second)
    )

    let hasAtLeastOneCard = Signal.merge(
      self.paymentMethods
        .map { !$0.isEmpty },
      deletePaymentMethodValues
        .map { !$0.isEmpty },
      self.didDeleteCreditCardSignal.map(second)
        .map { $0 > 0 }
    )

    self.editButtonIsEnabled = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst(false),
      hasAtLeastOneCard
    )
    .skipRepeats()

    self.goToAddCardScreen = self.didTapAddCardButtonProperty.signal

    self.presentBanner = self.addNewCardSucceededProperty.signal.skipNil()

    let stopEditing = Signal.merge(
      self.editButtonIsEnabled.filter(isFalse),
      self.addNewCardPresentedSignal.mapConst(false)
    )

    self.tableViewIsEditingProperty <~ Signal.merge(
      stopEditing,
      self.editButtonTappedSignal
        .withLatest(from: self.tableViewIsEditingProperty.signal)
        .map(second)
        .negate()
    )

    self.tableViewIsEditing = self.tableViewIsEditingProperty.signal

    self.editButtonTitle = self.tableViewIsEditing
      .map { $0 ? Strings.Done() : Strings.discovery_favorite_categories_buttons_edit() }

    // Koala:
    self.viewWillAppearProperty.signal
      .observeValues { _ in AppEnvironment.current.koala.trackViewedPaymentMethods() }

    deletePaymentMethodEvents.values()
      .ignoreValues()
      .observeValues { _ in AppEnvironment.current.koala.trackDeletedPaymentMethod() }

    deletePaymentMethodEventsErrors
      .ignoreValues()
      .observeValues { _ in AppEnvironment.current.koala.trackDeletePaymentMethodError() }
  }

  // Stores the table view's editing state as it is affected by multiple signals
  private let tableViewIsEditingProperty = MutableProperty<Bool>(false)

  fileprivate let (didDeleteCreditCardSignal, didDeleteCreditCardObserver) =
    Signal<(GraphUserCreditCard.CreditCard, Int),
    NoError>.pipe()
  public func didDelete(_ creditCard: GraphUserCreditCard.CreditCard, visibleCellCount: Int) {
    self.didDeleteCreditCardObserver.send(value: (creditCard, visibleCellCount))
  }

  fileprivate let (editButtonTappedSignal, editButtonTappedObserver) = Signal<(), NoError>.pipe()
  public func editButtonTapped() {
    self.editButtonTappedObserver.send(value: ())
  }

  fileprivate let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  fileprivate let viewWillAppearProperty = MutableProperty(())
  public func viewWillAppear() {
    self.viewWillAppearProperty.value = ()
  }

  fileprivate let didTapAddCardButtonProperty = MutableProperty(())
  public func paymentMethodsFooterViewDidTapAddNewCardButton() {
    self.didTapAddCardButtonProperty.value = ()
  }

  fileprivate let addNewCardSucceededProperty = MutableProperty<String?>(nil)
  public func addNewCardSucceeded(with message: String) {
    self.addNewCardSucceededProperty.value = message
  }

  fileprivate let addNewCardDismissedProperty = MutableProperty(())
  public func addNewCardDismissed() {
    self.addNewCardDismissedProperty.value = ()
  }

  fileprivate let (addNewCardPresentedSignal, addNewCardPresentedObserver) = Signal<(), NoError>.pipe()
  public func addNewCardPresented() {
    self.addNewCardPresentedObserver.send(value: ())
  }

  public let editButtonIsEnabled: Signal<Bool, NoError>
  public let editButtonTitle: Signal<String, NoError>
  public let errorLoadingPaymentMethods: Signal<String, NoError>
  public let goToAddCardScreen: Signal<Void, NoError>
  public let paymentMethods: Signal<[GraphUserCreditCard.CreditCard], NoError>
  public let presentBanner: Signal<String, NoError>
  public let reloadData: Signal<Void, NoError>
  public let showAlert: Signal<String, NoError>
  public let tableViewIsEditing: Signal<Bool, NoError>

  public var inputs: PaymentMethodsViewModelInputs { return self }
  public var outputs: PaymentMethodsViewModelOutputs { return self }
}
