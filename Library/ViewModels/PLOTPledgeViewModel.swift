import Foundation
import KsApi
import ReactiveSwift

public protocol PLOTPledgeViewModelInputs {
  func paymentPlanSelected(_ paymentPlan: PledgePaymentPlansType)
}

public protocol PLOTPledgeViewModelOutputs {
  var showPledgeOverTimeUI: Signal<Bool, Never> { get }
  var pledgeOverTimeConfigData: Signal<PledgePaymentPlansAndSelectionData?, Never> { get }

  // Visible only for testing
  var buildPaymentPlanInputs: Signal<(String, String), Never> { get }
}

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
      .combineLatest(with: pledgeOverTimeUIEnabled)
      .switchMap { (
        paymentPlanInputs: (slug: String, amount: String),
        pledgeOverTimeUIEnabled: Bool
      ) -> SignalProducer<
        Signal<GraphAPI.BuildPaymentPlanQuery.Data?, ErrorEnvelope>.Event,
        Never
      > in
        // Proceed with the query only if Pledge Over Time (PLOT) is enabled.
        // If PLOT is disabled, return nil to ensure that the `combineLatest` in `pledgeOverTimeConfigData`
        // emits a value, maintaining the Signal pipeline's flow.
        guard pledgeOverTimeUIEnabled else {
          return SignalProducer(value: .value(nil))
        }

        return AppEnvironment.current.apiService.buildPaymentPlan(
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

    let pledgeOverTimeApiValues = pledgeOverTimeQuery
      .values()
      // Emit a default `nil` value to ensure the Signal pipeline remains active
      // and `combineLatest` in `pledgeOverTimeConfigData` emits a value even when errors occur.
      .demoteErrors(replaceErrorWith: nil)

    self.pledgeOverTimeConfigData = Signal
      .combineLatest(project, pledgeOverTimeApiValues, self.paymentPlanSelectedProperty.signal)
      .map { project, pledgeOverTimeApiValues, paymentPlanSelected in

        // Wrap the value in `nil` to ensure the Signal emits consistently,
        // even when the API request fails or Pledge Over Time is disabled.
        guard let paymentPlan = pledgeOverTimeApiValues?.project?.paymentPlan else { return nil }

        // TODO: Temporary placeholder to simulate the ineligible state for plans.
        // The `thresholdAmount` will be retrieved from the API in the future.
        // See [MBL-1838](https://kickstarter.atlassian.net/browse/MBL-1838) for implementation details.
        let thresholdAmount = 125.0

        return PledgePaymentPlansAndSelectionData(
          withPaymentPlanFragment: paymentPlan,
          selectedPlan: paymentPlanSelected,
          project: project,
          thresholdAmount: thresholdAmount
        )
      }
  }

  public var outputs: PLOTPledgeViewModelOutputs { return self }
  public var inputs: PLOTPledgeViewModelInputs { return self }

  // MARK: - Inputs

  private let paymentPlanSelectedProperty = MutableProperty<PledgePaymentPlansType>(.pledgeInFull)
  public func paymentPlanSelected(_ paymentPlan: PledgePaymentPlansType) {
    self.paymentPlanSelectedProperty.value = paymentPlan
  }

  // MARK: - Outputs

  public let showPledgeOverTimeUI: Signal<Bool, Never>
  public let pledgeOverTimeConfigData: Signal<PledgePaymentPlansAndSelectionData?, Never>
  public let buildPaymentPlanInputs: Signal<(String, String), Never>
}
