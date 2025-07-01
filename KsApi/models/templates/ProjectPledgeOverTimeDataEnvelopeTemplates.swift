extension RewardsAndPledgeOverTimeEnvelope {
  public static let template = RewardsAndPledgeOverTimeEnvelope(
    rewards: [Reward.template],
    isPledgeOverTimeAllowed: true,
    pledgeOverTimeCollectionPlanChargeExplanation: "The first charge will occur when the project ends successfully, then every month until fully paid.",
    pledgeOverTimeCollectionPlanChargedAsNPayments: "charged as 3 payments",
    pledgeOverTimeCollectionPlanShortPitch: "You will be charged for your pledge over three payments, at no extra cost.",
    pledgeOverTimeMinimumExplanation: "Available for pledges over $125.00"
  )
}
