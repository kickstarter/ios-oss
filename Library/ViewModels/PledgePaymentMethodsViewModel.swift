import KsApi
import Prelude
import ReactiveSwift

public protocol PledgePaymentMethodsViewModelInputs {
  func configureWith(_ value: [GraphUserCreditCard.CreditCard])
}

public protocol PledgePaymentMethodsViewModelOutputs {
  var reloadData: Signal<[GraphUserCreditCard.CreditCard], Never> { get }
}

public protocol PledgePaymentMethodsViewModelType {
  var inputs: PledgePaymentMethodsViewModelInputs { get }
  var outputs: PledgePaymentMethodsViewModelOutputs { get }
}

public final class PledgePaymentMethodsViewModel: PledgePaymentMethodsViewModelType,
PledgePaymentMethodsViewModelInputs, PledgePaymentMethodsViewModelOutputs {
  public init() {
    self.reloadData = self.configureWithSignal
      .map { $0 }
  }

  fileprivate let (configureWithSignal, configureWithObserver) =
    Signal<[GraphUserCreditCard.CreditCard], Never>.pipe()
  public func configureWith(_ value: [GraphUserCreditCard.CreditCard]) {
    self.configureWithObserver.send(value: value)
  }

  public var inputs: PledgePaymentMethodsViewModelInputs { return self }
  public var outputs: PledgePaymentMethodsViewModelOutputs { return self }

  public let reloadData: Signal<[GraphUserCreditCard.CreditCard], Never>
}
