import Apollo
@testable import KsApi

public enum WatchProjectResponseMutationTemplate {
  case valid(watched: Bool)
  case errored(watched: Bool)

  var watchData: GraphAPI.WatchProjectMutation.Data {
    switch self {
    case let .valid(watched):
      return testGraphObject<
        GraphAPI.WatchProjectMutation
          .Data
      >(data: self.watchProjectMutationResultMap(watched: watched))
    case let .errored(watched):
      return testGraphObject<
        GraphAPI.WatchProjectMutation
          .Data
      >(data: self.watchProjectMutationErroredResultMap(watched: watched))
    }
  }

  var unwatchData: GraphAPI.UnwatchProjectMutation.Data {
    switch self {
    case let .valid(watched):
      return testGraphObject<
        GraphAPI.UnwatchProjectMutation
          .Data
      >(data: self.watchProjectMutationResultMap(watched: watched))
    case let .errored(watched):
      return testGraphObject<
        GraphAPI.UnwatchProjectMutation
          .Data
      >(data: self.watchProjectMutationErroredResultMap(watched: watched))
    }
  }

  // MARK: Private Properties

  func watchProjectMutationResultMap(watched: Bool) -> [String: Any?] {
    [
      "watchProject": [
        "clientMutationId": nil,
        "project": [
          "id": "id",
          "isWatched": watched,
          "watchesCount": 100
        ]
      ]
    ]
  }

  func watchProjectMutationErroredResultMap(watched: Bool) -> [String: Any?] {
    [
      "wrongKey": [
        "clientMutationId": nil,
        "project": [
          "id": "id",
          "isWatched": watched,
          "watchesCount": 100
        ]
      ]
    ]
  }
}
