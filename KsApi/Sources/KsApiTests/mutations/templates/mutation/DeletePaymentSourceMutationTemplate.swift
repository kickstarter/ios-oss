import Apollo
import GraphAPI
@testable import KsApi

public enum DeletePaymentSourceMutationTemplate {
  case valid
  case errored

  var data: GraphAPI.DeletePaymentSourceMutation.Data {
    switch self {
    case .valid:
      return try! testGraphObject(jsonString: self.deletePaymentSourceMutationResult)
    case .errored:
      return try! testGraphObject(jsonString: "{}")
    }
  }

  // MARK: Private Properties

  private var deletePaymentSourceMutationResult: String {
    """
        {
          "paymentSourceDelete": {
          "__typename": "PaymentSourceDelete",
            "user": {
              "__typename": "User",
              "storedCards": {
                "__typename": "UserCreditCardTypeConnection",
                "nodes": [
                  {
                    "__typename": "CreditCard",
                    "expirationDate": "2023-02-01",
                    "id": "69021326",
                    "lastFour": "4242",
                    "type": "VISA",
                    "stripeCardId": "pm_1OtGFX4VvJ2PtfhK3Gp00SWK"
                  },
                  {
                    "__typename": "CreditCard",
                    "expirationDate": "2024-01-01",
                    "id": "69021329",
                    "lastFour": "4243",
                    "type": "DISCOVER",
                    "stripeCardId": "pm_1OpDEC4VvJ2PtfhKftPrpgJ2"
                  }
                ],
                "totalCount": 2
              },
              "totalCount": 2
            }
          }
        }
    """
  }
}
