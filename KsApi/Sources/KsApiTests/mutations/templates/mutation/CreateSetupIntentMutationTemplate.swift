import Apollo
import GraphAPI
@testable import KsApi

public enum CreateSetupIntentMutationTemplate {
  case valid
  case errored

  var data: GraphAPI.CreateSetupIntentMutation.Data {
    switch self {
    case .valid:
      return try! testGraphObject(data: self.createSetupIntentMutationResultMap)
    case .errored:
      return try! testGraphObject(data: self.createSetupIntentMutationErroredResultMap)
    }
  }

  // MARK: Private Properties

  private var createSetupIntentMutationResultMap: [String: Any] {
    [
      "createSetupIntent": [
        "__typename": "CreateSetupIntentMutationPayload",
        "clientSecret": "seti_1LO1Om4VvJ2PtfhKrNizQefl_secret_M6DqtRtur5tF3z0LRyh15x5VuHjFPQK"
      ]
    ]
  }

  private var createSetupIntentMutationErroredResultMap: [String: Any] {
    return [:]
  }
}
