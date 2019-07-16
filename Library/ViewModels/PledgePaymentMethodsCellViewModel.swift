import KsApi
import Prelude
import ReactiveSwift

public protocol PledgePaymentMethodsCellViewModelInputs {
  func configureWith(_ value: [GraphUserCreditCard.CreditCard])
  func didUpdateContentSize(_ size: CGSize)
}

public protocol PledgePaymentMethodsCellViewModelOutputs {
  var reloadData: Signal<[GraphUserCreditCard.CreditCard], Never> { get }
  var updateConstraints: Signal<CGSize, Never> { get }
}

public protocol PledgePaymentMethodsCellViewModelType {
  var inputs: PledgePaymentMethodsCellViewModelInputs { get }
  var outputs: PledgePaymentMethodsCellViewModelOutputs { get }
}

public final class PledgePaymentMethodsCellViewModel: PledgePaymentMethodsCellViewModelType,
PledgePaymentMethodsCellViewModelInputs, PledgePaymentMethodsCellViewModelOutputs {
  public init() {
    self.reloadData = configureWithSignal
      .map { $0 }

    self.updateConstraints = self.contentSizeSignal
      .skipRepeats()
      .map { $0 }
  }

  fileprivate let (configureWithSignal, configureWithObserver) =
    Signal<[GraphUserCreditCard.CreditCard], Never>.pipe()
  public func configureWith(_ value: [GraphUserCreditCard.CreditCard]) {
    self.configureWithObserver.send(value: value)
  }

  fileprivate let (contentSizeSignal, contentSizeObserver) = Signal<CGSize, Never>.pipe()
  public func didUpdateContentSize(_ size: CGSize) {
    self.contentSizeObserver.send(value: size)
  }

  public var inputs: PledgePaymentMethodsCellViewModelInputs { return self }
  public var outputs: PledgePaymentMethodsCellViewModelOutputs { return self }

  public let reloadData: Signal<[GraphUserCreditCard.CreditCard], Never>
  public let updateConstraints: Signal<CGSize, Never>
}
