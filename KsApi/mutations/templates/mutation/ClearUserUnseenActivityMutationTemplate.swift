import Apollo
@testable import KsApi

public enum ClearUserUnseenActivityMutationTemplate {
  case valid
  case errored

  var data: GraphAPI.ClearUserUnseenActivityMutation.Data {
    switch self {
    case .valid:
      return testGraphObject<
        GraphAPI.ClearUserUnseenActivityMutation
          .Data
      >(data: self.createClearUserUnseenActivityMutationResultMap)
    case .errored:
      return testGraphObject<
        GraphAPI.ClearUserUnseenActivityMutation
          .Data
      >(data: self.createClearUserUnseenActivityMutationErroredResultMap)
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
