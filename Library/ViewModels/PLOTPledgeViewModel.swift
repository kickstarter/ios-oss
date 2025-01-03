import Foundation
import KsApi
import ReactiveSwift

public protocol PLOTPledgeViewModelOutputs {
  var showPledgeOverTimeUI: Signal<Bool, Never> { get }
  var pledgeOverTimeConfigData: Signal<PledgePaymentPlansAndSelectionData, Never> { get }

  // Visible only for testing
  var buildPaymentPlanInputs: Signal<(String, String), Never> { get }
}

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
  public let buildPaymentPlanInputs: Signal<(String, String), Never>

  public var outputs: PLOTPledgeViewModelOutputs { return self }
}
