import Apollo
@testable import KsApi

public enum UpdateBackingMutationTemplate {
  case valid(checkoutState: GraphAPI.CheckoutState, sca: Bool)
  case errored

  var data: GraphAPI.UpdateBackingMutation.Data {
    switch self {
    case let .valid(checkoutState, sca):
      let resultMap = self.updateBackingMutationResultMap(checkoutState: checkoutState, sca: sca)

      return GraphAPI.UpdateBackingMutation
        .Data(unsafeResultMap: resultMap)
    case .errored:
      return GraphAPI.UpdateBackingMutation
        .Data(unsafeResultMap: self.updateBackingMutationErroredResultMap)
    }
  }

  // MARK: Private Properties

  private func updateBackingMutationResultMap(checkoutState: GraphAPI.CheckoutState,
                                              sca: Bool) -> [String: Any?] {
    [
      "updateBacking": [
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

  private var updateBackingMutationErroredResultMap: [String: Any?] {
    return [:]
  }
}
