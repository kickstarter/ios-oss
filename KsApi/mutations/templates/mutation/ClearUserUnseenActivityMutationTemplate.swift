import Apollo
@testable import KsApi

public enum ClearUserUnseenActivityMutationTemplate {
  case valid
  case errored

  var data: GraphAPI.ClearUserUnseenActivityMutation.Data {
    switch self {
    case .valid:
      return GraphAPI.ClearUserUnseenActivityMutation
        .Data(unsafeResultMap: self.createClearUserUnseenActivityMutationResultMap)
    case .errored:
      return GraphAPI.ClearUserUnseenActivityMutation
        .Data(unsafeResultMap: self.createClearUserUnseenActivityMutationErroredResultMap)
    }
  }

  // MARK: Private Properties

  private var createClearUserUnseenActivityMutationResultMap: [String: Any?] {
    [
      "clearUserUnseenActivity": [
        "clientMutationId": nil,
        "activityIndicatorCount": 3
      ]
    ]
  }

  private var createClearUserUnseenActivityMutationErroredResultMap: [String: Any?] {
    return [:]
  }
}
