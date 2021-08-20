import Apollo
@testable import KsApi

public enum DeletePaymentSourceMutationTemplate {
  case valid
  case errored

  var data: GraphAPI.DeletePaymentSourceMutation.Data {
    switch self {
    case .valid:
      return GraphAPI.DeletePaymentSourceMutation
        .Data(unsafeResultMap: self.deletePaymentSourceMutationResultMap)
    case .errored:
      return GraphAPI.DeletePaymentSourceMutation
        .Data(unsafeResultMap: self.deletePaymentSourceMutationErroredResultMap)
    }
  }

  // MARK: Private Properties

  private var deletePaymentSourceMutationResultMap: [String: Any?] {
    [
      "paymentSourceDelete": [
        "user": [
          "storedCards": [
            "nodes": [
              [
                "expirationDate": "2023-02-01",
                "id": "69021326",
                "lastFour": "4242",
                "type": GraphAPI.CreditCardTypes.visa
              ],
              [
                "expirationDate": "2024-01-01",
                "id": "69021329",
                "lastFour": "4243",
                "type": GraphAPI.CreditCardTypes.discover
              ]
            ]
          ],
          "totalCount": 2
        ]
      ]
    ]
  }

  private var deletePaymentSourceMutationErroredResultMap: [String: Any?] {
    let resultMap = self.deletePaymentSourceMutationResultMap

    let topLevelMap = resultMap["paymentSourceDelete"] ?? [:]

    let erroredMap = ["wrongKey": topLevelMap]

    return erroredMap
  }
}
