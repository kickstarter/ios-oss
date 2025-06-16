import Apollo
@testable import KsApi

public enum CreateBackingMutationTemplate {
  case valid(checkoutState: GraphAPI.CheckoutState, sca: Bool)
  case errored

  var data: GraphAPI.CreateBackingMutation.Data {
    switch self {
    case let .valid(checkoutState, sca):
      let resultMap = self.createBackingMutationResultMap(checkoutState: checkoutState, sca: sca)

      return testGraphObject<
        GraphAPI.CreateBackingMutation
          .Data
      >(data: resultMap)
    case .errored:
      return testGraphObject<
        GraphAPI.CreateBackingMutation
          .Data
      >(data: self.createBackingMutationErroredResultMap)
    }
  }

  // MARK: Private Properties

  private func createBackingMutationResultMap(
    checkoutState: GraphAPI.CheckoutState,
    sca: Bool
  ) -> [String: Any?] {
    [
      "createBacking": [
        "checkout": [
          "id": "id",
          "state": checkoutState,
          "backing": [
            "clientSecret": sca ? "client-secret" : nil,
            "requiresAction": sca
          ]
        ]
      ]
    ]
  }

  private var createBackingMutationErroredResultMap: [String: Any?] {
    return [:]
  }
}
