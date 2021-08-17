import Apollo
@testable import KsApi

public enum WatchProjectResponseMutationTemplate {
  case valid
  case errored

  var data: GraphAPI.WatchProjectMutation.Data {
    switch self {
    case .valid:
      return GraphAPI.WatchProjectMutation
        .Data(unsafeResultMap: self.watchProjectMutationResultMap)
    case .errored:
      return GraphAPI.WatchProjectMutation
        .Data(unsafeResultMap: self.watchProjectMutationErroredResultMap)
    }
  }

  // MARK: Private Properties

  private var watchProjectMutationResultMap: [String: Any?] {
    [
      "watchProject": [
        "clientMutationId": nil,
        "project": [
          "id": "id",
          "isWatched": true
        ]
      ]
    ]
  }

  private var watchProjectMutationErroredResultMap: [String: Any?] {
    let resultMap = self.watchProjectMutationResultMap

    let topLevelMap = resultMap["watchProject"] ?? [:]

    let erroredMap = ["wrongKey": topLevelMap]

    return erroredMap
  }
}
