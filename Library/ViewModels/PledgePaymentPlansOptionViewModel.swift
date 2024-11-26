import ReactiveSwift

public typealias PledgePaymentPlanOptionData = (
  type: PledgePaymentPlansType,
  selectedType: PledgePaymentPlansType
)

public protocol PledgePaymentPlansOptionViewModelInputs {
  func configureWith(data: PledgePaymentPlanOptionData)
  func optionTapped()
  func refreshSelectedType(_ selectedType: PledgePaymentPlansType)
}

public protocol PledgePaymentPlansOptionViewModelOutputs {
  var titleText: Signal<String?, Never> { get }
  var subtitleText: Signal<String?, Never> { get }
  var checkmarkImageName: Signal<String, Never> { get }
  var notifyDelegatePaymentPlanOptionSelected: Signal<PledgePaymentPlansType, Never> { get }
}

public protocol PledgePaymentPlansOptionViewModelType {
  var inputs: PledgePaymentPlansOptionViewModelInputs { get }
  var outputs: PledgePaymentPlansOptionViewModelOutputs { get }
}

public final class PledgePaymentPlansOptionViewModel:
  PledgePaymentPlansOptionViewModelType,
  PledgePaymentPlansOptionViewModelInputs,
  PledgePaymentPlansOptionViewModelOutputs {
  public init() {
    let configData = self.configData.signal.skipNil()

    let checkImageName = configData
      .map { $0.selectedType == $0.type ? "icon-payment-method-selected" : "icon-payment-method-unselected" }

    self.checkmarkImageName = checkImageName

    self.titleText = configData.map { getTitleText(by: $0.type) }
    self.subtitleText = configData.map { getSubtitleText(by: $0.type) }

    self.notifyDelegatePaymentPlanOptionSelected = self.optionTappedProperty
      .signal
      .withLatest(from: configData)
      .map { $1.type }
  }

  fileprivate let configData = MutableProperty<PledgePaymentPlanOptionData?>(nil)
  public func configureWith(data: PledgePaymentPlanOptionData) {
    self.configData.value = data
  }

  public func refreshSelectedType(_ selectedType: PledgePaymentPlansType) {
    self.configData.value?.selectedType = selectedType
  }

  private let optionTappedProperty = MutableProperty<Void>(())
  public func optionTapped() {
    self.optionTappedProperty.value = ()
  }

  public let checkmarkImageName: Signal<String, Never>
  public var titleText: ReactiveSwift.Signal<String?, Never>
  public var subtitleText: ReactiveSwift.Signal<String?, Never>
  public var notifyDelegatePaymentPlanOptionSelected: Signal<PledgePaymentPlansType, Never>

  public var inputs: PledgePaymentPlansOptionViewModelInputs { return self }
  public var outputs: PledgePaymentPlansOptionViewModelOutputs { return self }
}

// TODO: add strings translations [MBL-1860](https://kickstarter.atlassian.net/browse/MBL-1860)
private func getTitleText(by type: PledgePaymentPlansType) -> String {
  switch type {
  case .pledgeInFull: "Pledge in full"
  case .pledgeOverTime: "Pledge Over Time"
  }
}

// TODO: add strings translations [MBL-1860](https://kickstarter.atlassian.net/browse/MBL-1860)
private func getSubtitleText(by type: PledgePaymentPlansType) -> String? {
  switch type {
  case .pledgeInFull: nil
  case .pledgeOverTime: "You will be charged for your pledge over four payments, at no extra cost."
  }
}
