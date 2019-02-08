import Foundation
import KsApi
import Prelude
import ReactiveSwift
import Result

public protocol PaymentMethodsViewModelInputs {
  func cardAddedSuccessfully(_ message: String)
  func didDelete(_ creditCard: GraphUserCreditCard.CreditCard)
  func editButtonTapped()
  func paymentMethodsFooterViewDidTapAddNewCardButton()
  func viewDidLoad()
  func viewWillAppear()
}

public protocol PaymentMethodsViewModelOutputs {
  /// Emits the user's stored cards
  var editButtonIsEnabled: Signal<Bool, NoError> { get }
  var goToAddCardScreen: Signal<Void, NoError> { get }
  var paymentMethods: Signal<[GraphUserCreditCard.CreditCard], NoError> { get }
  var presentBanner: Signal<String, NoError> { get }
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
    let paymentMethodsEvent = self.viewWillAppearProperty.signal
      .switchMap { _ in
        AppEnvironment.current.apiService.fetchGraphCreditCards(query: UserQueries.storedCards.query)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .materialize()
    }

    let deletePaymentMethodEvents = self.didDeleteCreditCardSignal.switchMap { creditCard in
      AppEnvironment.current.apiService.deletePaymentMethod(input: .init(paymentSourceId: creditCard.id))
        .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
        .materialize()
    }

    let deletePaymentMethodEventsErrors = deletePaymentMethodEvents.errors()

    self.showAlert = deletePaymentMethodEventsErrors
      .ignoreValues()
      .map {
        localizedString(
          key: "Something_went_wrong_and_we_were_unable_to_remove_your_payment_method_please_try_again",
          //swiftlint:disable:next line_length
          defaultValue: "Something went wrong and we were unable to remove your payment method, please try again."
        )
    }

    let paymentMethodsValues = paymentMethodsEvent.values().map { $0.me.storedCards.nodes }

    self.paymentMethods = Signal.merge(
      paymentMethodsValues,
      paymentMethodsValues.takeWhen(deletePaymentMethodEventsErrors)
    )

    self.editButtonIsEnabled = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst(false),
      paymentMethodsValues.map { $0.isEmpty }.mapConst(true)
    )

    self.goToAddCardScreen = self.didTapAddCardButtonProperty.signal

    self.presentBanner = self.presentMessageBannerProperty.signal

    self.tableViewIsEditing = Signal.merge(
      self.editButtonTappedSignal.scan(false) { current, _ in !current },
      self.didTapAddCardButtonProperty.signal.mapConst(false))

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

  fileprivate let (didDeleteCreditCardSignal, didDeleteCreditCardObserver) =
    Signal<GraphUserCreditCard.CreditCard,
    NoError>.pipe()
  public func didDelete(_ creditCard: GraphUserCreditCard.CreditCard) {
    self.didDeleteCreditCardObserver.send(value: creditCard)
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

  fileprivate let presentMessageBannerProperty = MutableProperty("")
  public func cardAddedSuccessfully(_ message: String) {
    self.presentMessageBannerProperty.value = message
  }

  public let editButtonIsEnabled: Signal<Bool, NoError>
  public let goToAddCardScreen: Signal<Void, NoError>
  public let paymentMethods: Signal<[GraphUserCreditCard.CreditCard], NoError>
  public let presentBanner: Signal<String, NoError>
  public let showAlert: Signal<String, NoError>
  public let tableViewIsEditing: Signal<Bool, NoError>

  public var inputs: PaymentMethodsViewModelInputs { return self }
  public var outputs: PaymentMethodsViewModelOutputs { return self }
}
