@testable import KsApi
@testable import Library
import XCTest

final class PledgePaymentIncrementGraphAPITests: TestCase {
  func testPaymentIncrementViewModel_fromValidFragment_isCorrect() {
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
                  "amount": "99.75",
                  "currency": "USD"
                },
                "scheduledCollection": "2025-03-31T10:29:19-04:00",
              }
            ]
          }
        }
    }
    """

    let mockGraphData = try! GraphAPI.BuildPaymentPlanQuery.Data(jsonString: jsonString)
    guard let fragment = mockGraphData.project?.paymentPlan?.paymentIncrements?.first else {
      XCTFail("Unable to create mock GraphQL fragment to test with")
      return
    }

    let increment = PledgePaymentIncrement(withGraphQLFragment: fragment)
    XCTAssertNotNil(increment)
    XCTAssertEqual(increment!.amount.currency, "USD")
    XCTAssertEqual(increment!.amount.amount, Double(99.75))
    XCTAssertEqual(increment!.scheduledCollection, 1_743_431_359.0)
  }

  func testPaymentIncrementViewModel_fromInvalidFragment_isNil() {
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
                  "amount": "99.75",
                  "currency": "USD"
                },
                "scheduledCollection": "not a date :(",
              }
            ]
          }
        }
    }
    """

    let mockGraphData = try! GraphAPI.BuildPaymentPlanQuery.Data(jsonString: jsonString)
    guard let fragment = mockGraphData.project?.paymentPlan?.paymentIncrements?.first else {
      XCTFail("Unable to create mock GraphQL fragment to test with")
      return
    }

    let increment = PledgePaymentIncrement(withGraphQLFragment: fragment)
    XCTAssertNil(increment)
  }
}
