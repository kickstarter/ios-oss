import Foundation
import KsApi
import Prelude
import ReactiveSwift
import Result

public protocol PaymentMethodsViewModelInputs {
  func viewDidLoad()
}

public protocol PaymentMethodsViewModelOutputs {
  /// Emits the user's stored cards
  var didFetchPaymentMethods: Signal<[GraphUserCreditCard.CreditCard], NoError> { get }
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
        AppEnvironment.current.apiService.fetchGraphCreditCards(query: UserQueries.email.query)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .materialize()
      }

    self.didFetchPaymentMethods = paymentMethodsEvent.values().map { $0.me.storedCards.nodes }
  }

  fileprivate let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let didFetchPaymentMethods: Signal<[GraphUserCreditCard.CreditCard], NoError>

  public var inputs: PaymentMethodsViewModelInputs { return self }
  public var outputs: PaymentMethodsViewModelOutputs { return self }
}
