import Foundation
import KsApi
import Prelude
import ReactiveSwift

public enum PledgePaymentPlansType: Equatable {
  case pledgeInFull
  case pledgeOverTime
}

public struct PledgePaymentPlansAndSelectionData {
  public var ineligible: Bool
  public var paymentIncrements: [PledgePaymentIncrement]
  public var project: Project
  public var selectedPlan: PledgePaymentPlansType
  public var thresholdAmount: Double

  public init(
    selectedPlan: PledgePaymentPlansType,
    increments paymentIncrements: [PledgePaymentIncrement] = [],
    ineligible: Bool = false,
    project: Project,
    thresholdAmount: Double
  ) {
    self.ineligible = ineligible
    self.paymentIncrements = paymentIncrements
    self.project = project
    self.selectedPlan = selectedPlan
    self.thresholdAmount = thresholdAmount
  }

  public var isPledgeOverTime: Bool {
    self.selectedPlan == .pledgeOverTime
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
  /// `true` when no payment plan data has been set. An single `isLoading` event is after `viewDidLoad()` is called; more events are sent whenever `configure(with:)` is called.
  var isLoading: Signal<Bool, Never> { get }
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

    let isLoadingAfterConfigData = self.configureWithValueProperty.signal.map { data in
      data == nil
    }

    let isLoadingAfterViewDidLoad = self.viewDidLoadProperty.signal.mapConst(true)
      .take(until: isLoadingAfterConfigData.mapConst(()))

    self.isLoading = Signal.merge(
      isLoadingAfterViewDidLoad,
      isLoadingAfterConfigData
    )

    let planType = configureWithValue.map { $0.selectedPlan }

    let selectedPlanType = self.didSelectPlanTypeProperty.signal
      .skipNil()

    self.reloadPaymentPlans = Signal.merge(
      planType,
      selectedPlanType
    ).combineLatest(with: configureWithValue)
      .map { selectedPlan, data in
        PledgePaymentPlansAndSelectionData(
          selectedPlan: selectedPlan,
          increments: data.paymentIncrements,
          ineligible: data.ineligible,
          project: data.project,
          thresholdAmount: data.thresholdAmount
        )
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

  public let isLoading: Signal<Bool, Never>
}
