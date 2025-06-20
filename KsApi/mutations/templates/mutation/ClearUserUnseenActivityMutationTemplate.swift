import Apollo
@testable import KsApi

public enum ClearUserUnseenActivityMutationTemplate {
  case valid
  case errored

  var data: GraphAPI.ClearUserUnseenActivityMutation.Data {
    let type = GraphAPI.ClearUserUnseenActivityMutation.Data.self
    switch self {
    case .valid:
      return testGraphObject<type>(
        data: self.createClearUserUnseenActivityMutationResultMap
      )
    case .errored:
      return testGraphObject<type>(
        data: self.createClearUserUnseenActivityMutationErroredResultMap
      )
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
