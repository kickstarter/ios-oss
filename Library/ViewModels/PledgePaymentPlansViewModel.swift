import Foundation
import Prelude
import ReactiveSwift

public enum PledgePaymentPlansType: Equatable {
  case pledgeInFull
  case pledgeOverTime
}

public struct PledgePaymentPlansAndSelectionData {
  public var selectedPlan: PledgePaymentPlansType
  public var paymentIncrements: [PledgePaymentIncrement]
  /* TODO: add the necesary properties for the next states (PLOT Selected and Ineligible)
     - [MBL-1815](https://kickstarter.atlassian.net/browse/MBL-1815)
     - [MBL-1816](https://kickstarter.atlassian.net/browse/MBL-1816)
   */

  public init() {
    self.selectedPlan = .pledgeInFull
    self.paymentIncrements = []
  }

  public init(
    selectedPlan: PledgePaymentPlansType,
    increments paymentIncrements: [PledgePaymentIncrement] = []
  ) {
    self.selectedPlan = selectedPlan
    self.paymentIncrements = paymentIncrements
  }
}

public protocol PledgePaymentPlansViewModelInputs {
  func viewDidLoad()
  func configure(with value: PledgePaymentPlansAndSelectionData)
  func didSelectPlanType(_ planType: PledgePaymentPlansType)
  func didTapTermsOfUse(with helpType: HelpType)
}

public protocol PledgePaymentPlansViewModelOutputs {
  var notifyDelegatePaymentPlanSelected: Signal<PledgePaymentPlansType, Never> { get }
  var notifyDelegateTermsOfUseTapped: Signal<HelpType, Never> { get }
  var reloadPaymentPlans: Signal<PledgePaymentPlansAndSelectionData, Never> { get }
}

public protocol PledgePaymentPlansViewModelType {
  var inputs: PledgePaymentPlansViewModelInputs { get }
  var outputs: PledgePaymentPlansViewModelOutputs { get }
}

public final class PledgePaymentPlansViewModel: PledgePaymentPlansViewModelType,
  PledgePaymentPlansViewModelInputs,
  PledgePaymentPlansViewModelOutputs {
  public var reloadPaymentPlans: Signal<PledgePaymentPlansAndSelectionData, Never>
  public var notifyDelegatePaymentPlanSelected: Signal<PledgePaymentPlansType, Never>
  public var notifyDelegateTermsOfUseTapped: Signal<HelpType, Never>

  public var inputs: PledgePaymentPlansViewModelInputs { return self }
  public var outputs: PledgePaymentPlansViewModelOutputs { return self }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public init() {
    let configureWithValue = Signal.combineLatest(
      self.viewDidLoadProperty.signal,
      self.configureWithValueProperty.signal.skipNil()
    )
    .map(second)

    let planType = configureWithValue.map { $0.selectedPlan }

    let selectedPlanType = self.didSelectPlanTypeProperty.signal
      .skipNil()

    self.reloadPaymentPlans = Signal.merge(
      planType,
      selectedPlanType
    ).combineLatest(with: configureWithValue)
      .map { selectedPlan, data in
        PledgePaymentPlansAndSelectionData(selectedPlan: selectedPlan, increments: data.paymentIncrements)
      }

    self.notifyDelegatePaymentPlanSelected = selectedPlanType.signal.skipRepeats()

    self.notifyDelegateTermsOfUseTapped = self.didTermsOfUseTappedProperty.signal.skipNil()
  }

  private let configureWithValueProperty = MutableProperty<PledgePaymentPlansAndSelectionData?>(nil)
  public func configure(with value: PledgePaymentPlansAndSelectionData) {
    self.configureWithValueProperty.value = value
  }

  private let didSelectPlanTypeProperty = MutableProperty<PledgePaymentPlansType?>(nil)
  public func didSelectPlanType(_ planType: PledgePaymentPlansType) {
    self.didSelectPlanTypeProperty.value = planType
  }

  private let didTermsOfUseTappedProperty = MutableProperty<HelpType?>(nil)
  public func didTapTermsOfUse(with helpType: HelpType) {
    self.didTermsOfUseTappedProperty.value = helpType
  }
}
