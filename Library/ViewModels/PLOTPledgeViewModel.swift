import Foundation
import KsApi
import ReactiveSwift

public protocol PLOTPledgeViewModelOutputs {
  var showPledgeOverTimeUI: Signal<Bool, Never> { get }
  var pledgeOverTimeConfigData: Signal<PledgePaymentPlansAndSelectionData, Never> { get }
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

 Both inputs need to send at least one event for any outputs to send.

 Outputs:
  - `showPledgeOverTimeUI`:  Whether the PLOT module should be shown. Sends one or more events; the PLOT module should disappear if an error occurs in the BuildPaymentPlanQuery.
  - `pledgeOverTimeConfigData`: Info needed to display the PLOT module. Sends only _one_ event.
  - `pledgeOverTimeIsLoading`: Whether the PLOT module is loading. Sends one or more events, since loading can start and stop.
 */

public struct PLOTPledgeViewModel: PLOTPledgeViewModelOutputs {
  init(project: Signal<Project, Never>, pledgeTotal: Signal<Double, Never>) {
    let pledgeOverTimeUIEnabled = project.signal
      .map { ($0.isPledgeOverTimeAllowed ?? false) && featurePledgeOverTimeEnabled() }

    self.buildPaymentPlanInputs = Signal.combineLatest(project, pledgeTotal)
      // Only call the query once
      .take(first: 1)
      // Only make the query when PLOT is enabled
      .filterWhenLatestFrom(pledgeOverTimeUIEnabled, satisfies: {
        $0 == true
      })
      .map { (project: Project, pledgeTotal: Double) -> (String, String) in
        let amountFormatter = NumberFormatter()
        amountFormatter.minimumFractionDigits = 2
        amountFormatter.maximumFractionDigits = 2
        let amount = amountFormatter.string(from: NSNumber(value: pledgeTotal)) ?? ""

        return (project.slug, amount)
      }

    let pledgeOverTimeQuery = self.buildPaymentPlanInputs.switchMap { (slug: String, amount: String) in
      AppEnvironment.current.apiService.buildPaymentPlan(
        projectSlug: slug,
        pledgeAmount: amount
      ).materialize()
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

    self.pledgeOverTimeConfigData = pledgeOverTimeQuery
      .values()
      .compactMap { $0.project?.paymentPlan }
      .combineLatest(with: project)
      .map { paymentPlan, project in

        // TODO: Temporary placeholder to simulate the ineligible state for plans.
        // The `thresholdAmount` will be retrieved from the API in the future.
        // See [MBL-1838](https://kickstarter.atlassian.net/browse/MBL-1838) for implementation details.
        let thresholdAmount = 125.0

        return PledgePaymentPlansAndSelectionData(
          withPaymentPlanFragment: paymentPlan,
          selectedPlan: .pledgeInFull,
          project: project,
          thresholdAmount: thresholdAmount
        )
      }
  }

  public let showPledgeOverTimeUI: Signal<Bool, Never>
  public let pledgeOverTimeConfigData: Signal<PledgePaymentPlansAndSelectionData, Never>
  public let pledgeOverTimeIsLoading: Signal<Bool, Never>
  public let buildPaymentPlanInputs: Signal<(String, String), Never>

  public var outputs: PLOTPledgeViewModelOutputs { return self }
}
