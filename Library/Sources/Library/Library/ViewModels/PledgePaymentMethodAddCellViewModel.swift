import Foundation
import ReactiveSwift

public protocol PledgePaymentMethodAddCellViewModelInputs {
  /// Used to configure the cell with a loading state.
  func configureWith(value: Bool)
}

public protocol PledgePaymentMethodAddCellViewModelOutputs {
  var showLoading: Signal<Bool, Never> { get }
}

public protocol PledgePaymentMethodAddCellViewModelType {
  var inputs: PledgePaymentMethodAddCellViewModelInputs { get }
  var outputs: PledgePaymentMethodAddCellViewModelOutputs { get }
}

public final class PledgePaymentMethodAddCellViewModel: PledgePaymentMethodAddCellViewModelType,
  PledgePaymentMethodAddCellViewModelInputs, PledgePaymentMethodAddCellViewModelOutputs {
  public init() {
    self.showLoading = self.configData.signal
  }

  public let showLoading: Signal<Bool, Never>

  fileprivate let configData = MutableProperty<Bool>(false)
  public func configureWith(value: Bool) {
    self.configData.value = value
  }

  public var inputs: PledgePaymentMethodAddCellViewModelInputs { return self }
  public var outputs: PledgePaymentMethodAddCellViewModelOutputs { return self }
}
