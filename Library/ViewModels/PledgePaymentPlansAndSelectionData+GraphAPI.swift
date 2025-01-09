import KsApi

extension PledgePaymentPlansAndSelectionData {
  public init(
    withPaymentPlanFragment paymentPlan: GraphAPI.BuildPaymentPlanQuery.Data.Project.PaymentPlan,
    selectedPlan: PledgePaymentPlansType,
    project: Project,
    thresholdAmount: Double
  ) {
    var increments: [PledgePaymentIncrement] = []

    if let fetchedIncrements = paymentPlan.paymentIncrements {
      increments = fetchedIncrements
        .compactMap { PledgePaymentIncrement(withGraphQLFragment: $0.fragments.paymentIncrementFragment) }
    }

    self.init(
      selectedPlan: selectedPlan,
      increments: increments,
      ineligible: !paymentPlan.amountIsPledgeOverTimeEligible,
      project: project,
      thresholdAmount: thresholdAmount
    )
  }
}
