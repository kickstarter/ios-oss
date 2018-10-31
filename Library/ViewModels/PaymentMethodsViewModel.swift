import Foundation
import KsApi
import Prelude
import ReactiveSwift
import Result

public protocol PaymentMethodsViewModelInputs {
  func viewDidLoad()
  func didTapAddNewCardButton()
}

public protocol PaymentMethodsViewModelOutputs {
  /// Emits the user's stored cards
  var paymentMethods: Signal<[GraphUserCreditCard.CreditCard], NoError> { get }
  var goToAddCardScreen: Signal<Void, NoError> { get }
}

public protocol PaymentMethodsViewModelType {
  var inputs: PaymentMethodsViewModelInputs { get }
  var outputs: PaymentMethodsViewModelOutputs { get }
}

public final class PaymentMethodsViewModel: PaymentMethodsViewModelType,
PaymentMethodsViewModelInputs, PaymentMethodsViewModelOutputs {

  public init() {

    let paymentMethodsEvent = self.viewDidLoadProperty.signal
      .switchMap { _ in
        AppEnvironment.current.apiService.fetchGraphCreditCards(query: UserQueries.storedCards.query)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .materialize()
      }

    self.paymentMethods = paymentMethodsEvent.values().map { $0.me.storedCards.nodes }

    self.goToAddCardScreen = self.didTapAddCardButtonProperty.signal
  }

  fileprivate let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  fileprivate let didTapAddCardButtonProperty = MutableProperty(())
  public func didTapAddNewCardButton() {
    self.didTapAddCardButtonProperty.value = ()
  }

  public let paymentMethods: Signal<[GraphUserCreditCard.CreditCard], NoError>
  public let goToAddCardScreen: Signal<Void, NoError>

  public var inputs: PaymentMethodsViewModelInputs { return self }
  public var outputs: PaymentMethodsViewModelOutputs { return self }
}
