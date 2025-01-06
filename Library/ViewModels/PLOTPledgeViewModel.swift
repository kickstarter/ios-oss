import Foundation
import KsApi
import ReactiveSwift

public protocol PLOTPledgeViewModelInputs {
  func paymentPlanSelected(_ paymentPlan: PledgePaymentPlansType)
}

public protocol PLOTPledgeViewModelOutputs {
  var showPledgeOverTimeUI: Signal<Bool, Never> { get }
  var pledgeOverTimeConfigData: Signal<PledgePaymentPlansAndSelectionData?, Never> { get }
  var pledgeOverTimeIsLoading: Signal<Bool, Never> { get }

  // Visible only for testing
  var buildPaymentPlanInputs: Signal<(String, String), Never> { get }
}

/**
 A component view model for Pledge Over Time in the pledge checkout flow.
 Creates one BuildPaymentPlanQuery and uses those results to create data for the UI.

 Inputs:
  - `project`: A project.
  - `pledgeTotal`: Total amount to pledge, a double.
  - `paymentPlanSelected:`: The payment plan selected by the user.

 A `project` and `pledgeTotal` are required before `showPledgeOverTimeUI` or `pledgeOverTimeIsLoading` will send.

 If `showPledgeOverTimeUI` is false, or if a server error occurs, the model will immediately send `nil` for `pledgeOverTimeConfigData`.
 Otherwise, `pledgeOverTimeConfigData` send after the BuildPaymentPlanQuery loads. It will also send again each time `paymentPlanSelected:` is called.

 Outputs:
  - `showPledgeOverTimeUI`:  Whether the PLOT module should be shown. Sends one or more events. The PLOT module should disappear if an error occurs in the BuildPaymentPlanQuery.
  - `pledgeOverTimeConfigData`: Info needed to display the PLOT module. Sends one or more events.
  - `pledgeOverTimeIsLoading`: Whether the PLOT module is loading. Sends one or more events.
 */

public final class PLOTPledgeViewModel: PLOTPledgeViewModelInputs, PLOTPledgeViewModelOutputs {
  init(project: Signal<Project, Never>, pledgeTotal: Signal<Double, Never>) {
    let pledgeOverTimeUIEnabled = project.signal
      .map { ($0.isPledgeOverTimeAllowed ?? false) && featurePledgeOverTimeEnabled() }

    self.buildPaymentPlanInputs = Signal.combineLatest(project, pledgeTotal)
      // Only call the query once
      .take(first: 1)
      .map { (project: Project, pledgeTotal: Double) -> (
        String,
        String
      ) in
        let amountFormatter = NumberFormatter()
        amountFormatter.minimumFractionDigits = 2
        amountFormatter.maximumFractionDigits = 2
        let amount = amountFormatter.string(from: NSNumber(value: pledgeTotal)) ?? ""

        return (project.slug, amount)
      }

    let pledgeOverTimeQuery = self.buildPaymentPlanInputs
      .switchMap { (
        paymentPlanInputs: (slug: String, amount: String)
      ) -> SignalProducer<
        Signal<GraphAPI.BuildPaymentPlanQuery.Data?, ErrorEnvelope>.Event,
        Never
      > in
        AppEnvironment.current.apiService.buildPaymentPlan(
          projectSlug: paymentPlanInputs.slug,
          pledgeAmount: paymentPlanInputs.amount
        )
        // Wrap the response in an optional and convert the SignalProducer events into materialized values
        // to handle success or error scenarios downstream.
        .wrapInOptional()
        .materialize()
      }

    self.showPledgeOverTimeUI = Signal.merge(
      // Hide PLOT if the feature flag is off on either client or server
      pledgeOverTimeUIEnabled,
      // Hide PLOT if an error occurs
      pledgeOverTimeQuery.errors().map(value: false)
    )

    self.pledgeOverTimeIsLoading = Signal.merge(
      pledgeOverTimeUIEnabled,
      pledgeOverTimeQuery.values().map(value: false),
      pledgeOverTimeQuery.errors().map(value: false)
    )
    .skipRepeats()

    let pledgeOverTimeApiValues = pledgeOverTimeQuery
      .values()
      // Emit a default `nil` value to ensure the Signal pipeline remains active
      // and `combineLatest` in `pledgeOverTimeConfigData` emits a value even when errors occur.
      .demoteErrors(replaceErrorWith: nil)

    // Send an empty config when the view model is initialized
    let emptyConfigData: Signal<PledgePaymentPlansAndSelectionData?, Never> = self.showPledgeOverTimeUI
      .filter { $0 == false }
      .mapConst(nil)

    // Send a config once the query loads, defaulting to .pledgeInFull
    let configDataAfterQueryLoads: Signal<PledgePaymentPlansAndSelectionData?, Never> = Signal
      .combineLatest(project, pledgeOverTimeApiValues)
      .map { (
        project: Project,
        pledgeOverTimeApiValues: GraphAPI.BuildPaymentPlanQuery.Data?
      ) -> PledgePaymentPlansAndSelectionData? in

        // Wrap the value in `nil` to ensure the Signal emits consistently,
        // even when the API request fails or Pledge Over Time is disabled.
        guard let paymentPlan = pledgeOverTimeApiValues?.project?.paymentPlan else { return nil }

        // TODO: Temporary placeholder to simulate the ineligible state for plans.
        // The `thresholdAmount` will be retrieved from the API in the future.
        // See [MBL-1838](https://kickstarter.atlassian.net/browse/MBL-1838) for implementation details.
        let thresholdAmount = 125.0
        let defaultPlan = PledgePaymentPlansType.pledgeInFull

        return PledgePaymentPlansAndSelectionData(
          withPaymentPlanFragment: paymentPlan,
          selectedPlan: defaultPlan,
          project: project,
          thresholdAmount: thresholdAmount
        )
      }

    // Send an updated config after changing the plan
    let configDataAfterChangingPlan: Signal<PledgePaymentPlansAndSelectionData?, Never> = Signal
      .combineLatest(configDataAfterQueryLoads.skipNil(), self.paymentPlanSelectedProperty.signal)
      .map { data, selectedPlan in
        PledgePaymentPlansAndSelectionData(
          selectedPlan: selectedPlan,
          increments: data.paymentIncrements,
          ineligible: data.ineligible,
          project: data.project,
          thresholdAmount: data.thresholdAmount
        )
      }

    self.pledgeOverTimeConfigData = Signal.merge(
      emptyConfigData,
      configDataAfterQueryLoads,
      configDataAfterChangingPlan
    )
    .skipRepeats { a, b in
      if a.isNil && b.isNil {
        return true
      }

      return false
    }
  }

  public let showPledgeOverTimeUI: Signal<Bool, Never>
  public let pledgeOverTimeConfigData: Signal<PledgePaymentPlansAndSelectionData?, Never>
  public let pledgeOverTimeIsLoading: Signal<Bool, Never>
  public let buildPaymentPlanInputs: Signal<(String, String), Never>

  public var outputs: PLOTPledgeViewModelOutputs { return self }
  public var inputs: PLOTPledgeViewModelInputs { return self }

  // MARK: - Inputs

  private let paymentPlanSelectedProperty = MutableProperty<PledgePaymentPlansType>(.pledgeInFull)
  public func paymentPlanSelected(_ paymentPlan: PledgePaymentPlansType) {
    self.paymentPlanSelectedProperty.value = paymentPlan
  }

  // MARK: - Outputs
}
