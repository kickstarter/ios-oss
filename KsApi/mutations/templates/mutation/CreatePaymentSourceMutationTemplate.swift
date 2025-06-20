import Apollo
@testable import KsApi

public enum CreatePaymentSourceMutationTemplate {
  case valid
  case errored

  var data: GraphAPI.CreatePaymentSourceMutation.Data {
    switch self {
    case .valid:
      return testGraphObject<
        GraphAPI.CreatePaymentSourceMutation
          .Data
      >(data: self.createPaymentSourceMutationResultMap)
    case .errored:
      return testGraphObject<
        GraphAPI.CreatePaymentSourceMutation
          .Data
      >(data: self.createPaymentSourceMutationErroredResultMap)
    }
  }

  // MARK: Private Properties

  private var createPaymentSourceMutationResultMap: [String: Any?] {
    [
      "createPaymentSource": [
        "__typename": "CreatePaymentSourcePayload",
        "clientMutationId": nil,
        "isSuccessful": true,
        "paymentSource": [
          "__typename": "CreditCard",
          "expirationDate": "2032-02-01",
          "id": "69021299",
          "lastFour": "4242",
          "paymentType": GraphAPI.PaymentTypes.creditCard,
          "type": GraphAPI.CreditCardTypes.visa,
          "stripeCardId": "pm_1OtGFX4VvJ2PtfhK3Gp00SWK"
        ]
      ]
    ]
  }

  private var createPaymentSourceMutationErroredResultMap: [String: Any?] {
    guard var modifiedData = createPaymentSourceMutationResultMap["createPaymentSource"] as? [String: Any?]
    else {
      return self.createPaymentSourceMutationResultMap
    }

    modifiedData["isSuccessful"] = false
    let errorData = ["createPaymentSource": modifiedData]

    return errorData
  }
}
