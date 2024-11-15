import Foundation
import Prelude
import ReactiveSwift

public enum PledgePaymentPlansType: Int {
  case pledgeinFull
  case pledgeOverTime
}

public struct PledgePaymentPlansAndSelectionData: Equatable {
  public var selectedPlan: PledgePaymentPlansType
  /* TODO: add the necesary properties for the next states (PLOT Selected and Ineligible)
     - [MBL-1815](https://kickstarter.atlassian.net/browse/MBL-1815)
     - [MBL-1816](https://kickstarter.atlassian.net/browse/MBL-1816)
   */

  public init() {
    self.selectedPlan = .pledgeinFull
  }

  public init(selectedPlan: PledgePaymentPlansType) {
    self.selectedPlan = selectedPlan
  }
}

public protocol PledgePaymentPlansViewModelInputs {
  func viewDidLoad()
  func configure(with value: PledgePaymentPlansAndSelectionData)
  func didSelectRowAtIndexPath(_ indexPath: IndexPath, with data: PledgePaymentPlanCellData)
}

public protocol PledgePaymentPlansViewModelOutputs {
  var notifyDelegatePaymentPlanSelected: Signal<PledgePaymentPlansType, Never> { get }
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

    let selectedPlanType = self.didSelectRowAtIndexPathDataProperty.signal
      .map { $0.1 }
      .skipNil()
      .map { $0.type }

    self.reloadPaymentPlans = Signal.merge(
      planType,
      selectedPlanType
    ).map { PledgePaymentPlansAndSelectionData(selectedPlan: $0) }

    self.notifyDelegatePaymentPlanSelected = selectedPlanType.signal.skipRepeats()
  }

  private let configureWithValueProperty = MutableProperty<PledgePaymentPlansAndSelectionData?>(nil)
  public func configure(with value: PledgePaymentPlansAndSelectionData) {
    self.configureWithValueProperty.value = value
  }

  private let didSelectRowAtIndexPathDataProperty = MutableProperty<(
    IndexPath?,
    PledgePaymentPlanCellData?
  )>((nil, nil))
  public func didSelectRowAtIndexPath(_ indexPath: IndexPath, with data: PledgePaymentPlanCellData) {
    self.didSelectRowAtIndexPathDataProperty.value = (indexPath, data)
  }
}
