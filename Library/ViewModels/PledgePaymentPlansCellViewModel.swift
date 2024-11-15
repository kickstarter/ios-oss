import ReactiveSwift

public typealias PledgePaymentPlanCellData = (
  type: PledgePaymentPlansType,
  isSelected: Bool
)

public protocol PledgePaymentPlansCellViewModelInputs {
  func configureWith(data: PledgePaymentPlanCellData)
}

public protocol PledgePaymentPlansCellViewModelOutputs {
  var titleText: Signal<String?, Never> { get }
  var subtitleText: Signal<String?, Never> { get }
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
      .map { $0?.isSelected ?? false ? "icon-payment-method-selected" : "icon-payment-method-unselected" }

    self.checkmarkImageName = checkImageName
    
    self.titleText = self.configData.signal.skipNil().map { getTitleText(by: $0.type) }
    self.subtitleText = self.configData.signal.skipNil().map { getSubtitleText(by: $0.type) }
    
  }

  fileprivate let configData = MutableProperty<PledgePaymentPlanCellData?>(nil)
  public func configureWith(data: PledgePaymentPlanCellData) {
    self.configData.value = data
  }

  public let checkmarkImageName: Signal<String, Never>
  public var titleText: ReactiveSwift.Signal<String?, Never>
  public var subtitleText: ReactiveSwift.Signal<String?, Never>

  public var inputs: PledgePaymentPlansCellViewModelInputs { return self }
  public var outputs: PledgePaymentPlansCellViewModelOutputs { return self }
}

// TODO: add strings translations [MBL-1860](https://kickstarter.atlassian.net/browse/MBL-1860)
private func getTitleText(by type: PledgePaymentPlansType) -> String {
  switch type {
  case .pledgeinFull: "Pledge in full"
  case .pledgeOverTime: "Pledge Over Time"
  }
}

// TODO: add strings translations [MBL-1860](https://kickstarter.atlassian.net/browse/MBL-1860)
private func getSubtitleText(by type: PledgePaymentPlansType) -> String? {
  switch type {
  case .pledgeinFull: nil
  case .pledgeOverTime: "You will be charged for your pledge over four payments, at no extra cost."
  }
}
