import Foundation
import KsApi
import ReactiveSwift

public struct PledgePaymentPlanOptionData: Equatable {
  public var ineligible: Bool = false
  public var type: PledgePaymentPlansType
  public var selectedType: PledgePaymentPlansType
  // TODO: replece with API model in [MBL-1838](https://kickstarter.atlassian.net/browse/MBL-1838)
  public var paymentIncrements: [PledgePaymentIncrement]
  public var project: Project

  public init(
    ineligible: Bool,
    type: PledgePaymentPlansType,
    selectedType: PledgePaymentPlansType,
    paymentIncrements: [PledgePaymentIncrement],
    project: Project
  ) {
    self.ineligible = ineligible
    self.type = type
    self.selectedType = selectedType
    self.paymentIncrements = paymentIncrements
    self.project = project
  }
}

public enum SelectionIndicatorImageName: String {
  case selected = "icon-payment-method-selected"
  case unselected = "icon-payment-method-unselected"
}

public protocol PledgePaymentPlansOptionViewModelInputs {
  func configureWith(data: PledgePaymentPlanOptionData)
  func optionTapped()
  func termsOfUseTapped()
  func refreshSelectedType(_ selectedType: PledgePaymentPlansType)
}

public protocol PledgePaymentPlansOptionViewModelOutputs {
  var titleText: Signal<String, Never> { get }
  var subtitleText: Signal<String, Never> { get }
  var subtitleLabelHidden: Signal<Bool, Never> { get }
  var selectionIndicatorImageName: Signal<String, Never> { get }
  var ineligibleBadgeHidden: Signal<Bool, Never> { get }
  var ineligibleBadgeText: Signal<String, Never> { get }
  var notifyDelegatePaymentPlanOptionSelected: Signal<PledgePaymentPlansType, Never> { get }
  var notifyDelegateTermsOfUseTapped: Signal<HelpType, Never> { get }
  var optionViewEnabled: Signal<Bool, Never> { get }
  var paymentIncrements: Signal<[PledgePaymentIncrementFormatted], Never> { get }
  var plotSelectedStackViewHidden: Signal<Bool, Never> { get }
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

    let ineligible: Signal<Bool, Never> = configData.map { $0.type == .pledgeOverTime && $0.ineligible }

    self.selectionIndicatorImageName = configData
      .map {
        $0.selectedType == $0.type ?
          SelectionIndicatorImageName.selected.rawValue : SelectionIndicatorImageName.unselected.rawValue
      }

    self.titleText = configData.map { getTitleText(by: $0.type) }
    self.subtitleText = configData
      .map { getSubtitleText(by: $0.type, isSelected: $0.selectedType == $0.type) }
    self.subtitleLabelHidden = self.subtitleText
      .combineLatest(with: ineligible)
      .map { subtitle, ineligible in
        ineligible || subtitle.isEmpty
      }

    self.notifyDelegatePaymentPlanOptionSelected = self.optionTappedProperty
      .signal
      .withLatest(from: configData)
      .map { $1.type }

    let isPledgeOverTimeAndSelected: Signal<Bool, Never> = configData.map {
      $0.type == .pledgeOverTime && $0.type == $0.selectedType
    }

    self.plotSelectedStackViewHidden = isPledgeOverTimeAndSelected.negate()

    self.paymentIncrements = configData
      .filter { !$0.ineligible && $0.type == .pledgeOverTime && $0.selectedType == $0.type }
      .map { data in
        data.paymentIncrements
          .enumerated()
          .map { index, increment in
            PledgePaymentIncrementFormatted(from: increment, index: index)
          }
      }
      .filter { !$0.isEmpty }
      .take(first: 1)

    self.ineligibleBadgeHidden = ineligible.negate()

    self.optionViewEnabled = self.ineligibleBadgeHidden

    self.notifyDelegateTermsOfUseTapped = self.termsOfUseTappedProperty.signal.skipNil()

    self.ineligibleBadgeText = configData
      .filterWhenLatestFrom(ineligible, satisfies: { $0 == true })
      .map { $0.project.pledgeOverTimeMinimumExplanation }
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

  private let termsOfUseTappedProperty = MutableProperty<HelpType?>(nil)
  public func termsOfUseTapped() {
    self.termsOfUseTappedProperty.value = .terms
  }

  public let selectionIndicatorImageName: Signal<String, Never>
  public var titleText: ReactiveSwift.Signal<String, Never>
  public var subtitleText: ReactiveSwift.Signal<String, Never>
  public var subtitleLabelHidden: Signal<Bool, Never>
  public var ineligibleBadgeHidden: Signal<Bool, Never>
  public var ineligibleBadgeText: Signal<String, Never>
  public var notifyDelegatePaymentPlanOptionSelected: Signal<PledgePaymentPlansType, Never>
  public var notifyDelegateTermsOfUseTapped: Signal<HelpType, Never>
  public var optionViewEnabled: Signal<Bool, Never>
  public var paymentIncrements: Signal<[PledgePaymentIncrementFormatted], Never>
  public var plotSelectedStackViewHidden: Signal<Bool, Never>

  public var inputs: PledgePaymentPlansOptionViewModelInputs { return self }
  public var outputs: PledgePaymentPlansOptionViewModelOutputs { return self }
}

private func getTitleText(by type: PledgePaymentPlansType) -> String {
  switch type {
  case .pledgeInFull: Strings.Pledge_in_full()
  case .pledgeOverTime: Strings.Pledge_Over_Time()
  }
}

private func getSubtitleText(by type: PledgePaymentPlansType, isSelected: Bool) -> String {
  switch type {
  case .pledgeInFull:
    return ""
  case .pledgeOverTime:
    return makePledgeOverTimeSubtitle(isSelected: isSelected)
  }
}

private func makePledgeOverTimeSubtitle(isSelected: Bool) -> String {
  let subtitle = Strings.You_will_be_charged_for_your_pledge_over_four_payments_collapsed_description()
  guard isSelected else {
    return subtitle
  }

  return """
  \(subtitle)

  \(Strings.The_first_charge_will_occur_when_the_project_ends_successfully())
  """
}
