@testable import KsApi
@testable import Library
import XCTest

final class PledgePaymentPlansAndSelectionDataGraphAPITests: TestCase {
  func testPaymentPlanViewModel_fromValidQuery_isCorrect() {
    let jsonString = """
    {
        "project": {
          "__typename": "Project",
          "paymentPlan": {
            "__typename": "PaymentPlan",
            "projectIsPledgeOverTimeAllowed": true,
            "amountIsPledgeOverTimeEligible": true,
            "paymentIncrements": [
              {
                "__typename": "PaymentIncrement",
                "amount": {
                  "__typename": "Money",
                  "amount": "974",
                  "currency": "JPY"
                },
                "scheduledCollection": "2025-03-31T10:29:19-04:00",
                "state": "some state",
              }
            ]
          }
        }
    }
    """

    let mockGraphData = try! GraphAPI.BuildPaymentPlanQuery.Data(jsonString: jsonString)
    guard let paymentPlan = mockGraphData.project?.paymentPlan else {
      XCTFail("Unable to create mock GraphQL fragment to test with")
      return
    }

    let selectionData = PledgePaymentPlansAndSelectionData(
      withPaymentPlanFragment: paymentPlan,
      selectedPlan: .pledgeInFull,
      project: Project.template,
      thresholdAmount: 125
    )

    XCTAssertFalse(selectionData.ineligible)
    XCTAssertEqual(selectionData.paymentIncrements.count, 1)
    XCTAssertEqual(selectionData.paymentIncrements.first!.amount.currency, "JPY")
    XCTAssertEqual(selectionData.paymentIncrements.first!.amount.amount, Double(974))
    XCTAssertEqual(selectionData.paymentIncrements.first!.scheduledCollection, 1_743_431_359.0)
  }
}
