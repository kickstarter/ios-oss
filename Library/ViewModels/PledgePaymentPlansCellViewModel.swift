import ReactiveSwift

public protocol PledgePaymentPlansCellViewModelInputs {
  func configureWith(value: Bool)
}

public protocol PledgePaymentPlansCellViewModelOutputs {
  var checkmarkImageName: Signal<String, Never> { get }
}

public protocol PledgePaymentPlansCellViewModelType {
  var inputs: PledgePaymentPlansCellViewModelInputs { get }
  var outputs: PledgePaymentPlansCellViewModelOutputs { get }
}

public final class PledgePaymentPlansCellViewModel: PledgePaymentPlansCellViewModelType,
  PledgePaymentPlansCellViewModelInputs,
  PledgePaymentPlansCellViewModelOutputs {
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

  public var inputs: PledgePaymentPlansCellViewModelInputs { return self }
  public var outputs: PledgePaymentPlansCellViewModelOutputs { return self }
}
