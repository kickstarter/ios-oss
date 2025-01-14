// Some data for mocking a BuildPaymentPlanQuery response.
public func buildPaymentPlanQueryJson(eligible: Bool) -> String {
  return """
  {
      "project": {
        "__typename": "Project",
        "paymentPlan": {
          "__typename": "PaymentPlan",
          "projectIsPledgeOverTimeAllowed": true,
          "amountIsPledgeOverTimeEligible": \(eligible ? "true" : "false"),
          "paymentIncrements": [
            {
              "__typename": "PaymentIncrement",
              "amount": {
                "__typename": "PaymentIncrementAmount",
                "amountAsFloat": "933.23",
                "amountFormattedInProjectNativeCurrency": "$933.23",
                "currency": "USD"
              },
              "scheduledCollection": "2025-03-31T10:29:19-04:00",
              "state": "some state",
            }
          ],
        }
      }
  }
  """
}
