import Apollo
import GraphAPI
@testable import KsApi

public enum CreatePaymentSourceMutationTemplate {
  case valid
  case errored

  var data: GraphAPI.CreatePaymentSourceMutation.Data {
    switch self {
    case .valid:
      return try! testGraphObject(
        jsonString: self.createPaymentSourceMutationResult(isSuccessful: true)
      )
    case .errored:
      return try! testGraphObject(
        jsonString: self.createPaymentSourceMutationResult(isSuccessful: false)
      )
    }
  }

  // MARK: Private Properties

  private func createPaymentSourceMutationResult(isSuccessful: Bool) -> String {
    """
        {
          "createPaymentSource": {
            "__typename": "CreatePaymentSourcePayload",
            "isSuccessful": \(isSuccessful),
            "paymentSource": {
              "__typename": "CreditCard",
              "expirationDate": "2032-02-01",
              "id": "69021299",
              "lastFour": "4242",
              "paymentType": "CREDIT_CARD",
              "type": "VISA",
              "stripeCardId": "pm_1OtGFX4VvJ2PtfhK3Gp00SWK"
            }
          }
        }
    """
  }
}
