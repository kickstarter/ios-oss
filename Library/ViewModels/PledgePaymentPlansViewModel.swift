import Foundation
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
  func didSelectRowAtIndexPath(_ indexPath: IndexPath)
}

public protocol PledgePaymentPlansViewModelOutputs {
  var notifyDelegatePaymentPlanSelected: Signal<PledgePaymentPlansType, Never> { get }
  var reloadPaymentPlans: SignalProducer<PledgePaymentPlansAndSelectionData, Never> { get }
}

public protocol PledgePaymentPlansViewModelType {
  var inputs: PledgePaymentPlansViewModelInputs { get }
  var outputs: PledgePaymentPlansViewModelOutputs { get }
}

public final class PledgePaymentPlansViewModel: PledgePaymentPlansViewModelType,
                                                PledgePaymentPlansViewModelInputs, PledgePaymentPlansViewModelOutputs {
  
  public var reloadPaymentPlans: SignalProducer<PledgePaymentPlansAndSelectionData, Never>
  public var notifyDelegatePaymentPlanSelected: Signal<PledgePaymentPlansType, Never>
  
  public var inputs: PledgePaymentPlansViewModelInputs { return self }
  public var outputs: PledgePaymentPlansViewModelOutputs { return self }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public init() {
    
    let initialIndexPath = MutableProperty<PledgePaymentPlansType>(.pledgeinFull)
    
    let selectedPlanType = self.didSelectRowAtIndexPathProperty.signal
      .skipNil()
      .map { PledgePaymentPlansType(rawValue: $0.section) }
      .skipNil()
    
    self.reloadPaymentPlans = SignalProducer.merge(
      initialIndexPath.producer,
      selectedPlanType.producer
    ).map { PledgePaymentPlansAndSelectionData(selectedPlan: $0) }
    
    self.notifyDelegatePaymentPlanSelected = selectedPlanType.signal.skipRepeats()
  }
  
  private let didSelectRowAtIndexPathProperty = MutableProperty<IndexPath?>(nil)
  public func didSelectRowAtIndexPath(_ indexPath: IndexPath) {
    self.didSelectRowAtIndexPathProperty.value = indexPath
  }
}
