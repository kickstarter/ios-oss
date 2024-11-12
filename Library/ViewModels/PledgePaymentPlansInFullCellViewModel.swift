import ReactiveSwift

public protocol PledgePaymentPlansInFullCellViewModelInputs {
  /// Used to configure the cell with selected state.
  func configureWith(value: Bool)
}

public protocol PledgePaymentPlansInFullCellViewModelOutputs {
  /// No outputs properties yet
  var checkmarkImageName: Signal<String, Never> { get }
}

public protocol PledgePaymentPlansInFullCellViewModelType {
  var inputs: PledgePaymentPlansInFullCellViewModelInputs { get }
  var outputs: PledgePaymentPlansInFullCellViewModelOutputs { get }
}

public final class PledgePaymentPlansInFullCellViewModel: PledgePaymentPlansInFullCellViewModelType, PledgePaymentPlansInFullCellViewModelInputs, PledgePaymentPlansInFullCellViewModelOutputs {
  
  public init() {
    let checkImageName = self.configData.signal
      .map { $0 ? "icon-payment-method-selected" : "icon-payment-method-unselected" }
    
    self.checkmarkImageName = checkImageName
  }
  
  fileprivate let configData = MutableProperty<Bool>(false)
  public func configureWith(value: Bool) {
    self.configData.value = value
  }
  
  public let checkmarkImageName: Signal<String, Never>
  
  public var inputs: PledgePaymentPlansInFullCellViewModelInputs { return self }
  public var outputs: PledgePaymentPlansInFullCellViewModelOutputs { return self }
}
