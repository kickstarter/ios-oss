import Apollo
import GraphAPI
@testable import KsApi

public enum ClearUserUnseenActivityMutationTemplate {
  case valid
  case errored

  var data: GraphAPI.ClearUserUnseenActivityMutation.Data {
    switch self {
    case .valid:
      return try! testGraphObject(
        data: self.createClearUserUnseenActivityMutationResultMap
      )
    case .errored:
      return try! testGraphObject(
        data: self.createClearUserUnseenActivityMutationErroredResultMap
      )
    }
  }

  // MARK: Private Properties

  private var createClearUserUnseenActivityMutationResultMap: [String: Any] {
    [
      "clearUserUnseenActivity": [
        "__typename": "ClearUserUnseenActivityPayload",
        "activityIndicatorCount": 3
      ]
    ]
  }

  private var createClearUserUnseenActivityMutationErroredResultMap: [String: Any] {
    return [:]
  }
}
