import Apollo
@testable import KsApi

public enum CreateSetupIntentMutationTemplate {
  case valid
  case errored

  var data: GraphAPI.CreateSetupIntentMutation.Data {
    switch self {
    case .valid:
      return GraphAPI.CreateSetupIntentMutation
        .Data(unsafeResultMap: self.createSetupIntentMutationResultMap)
    case .errored:
      return GraphAPI.CreateSetupIntentMutation
        .Data(unsafeResultMap: self.createSetupIntentMutationErroredResultMap)
    }
  }

  // MARK: Private Properties

  private var createSetupIntentMutationResultMap: [String: Any?] {
    [
      "createSetupIntent": [
        "clientSecret": "seti_1LO1Om4VvJ2PtfhKrNizQefl_secret_M6DqtRtur5tF3z0LRyh15x5VuHjFPQK"
      ]
    ]
  }

  private var createSetupIntentMutationErroredResultMap: [String: Any?] {
    return [:]
  }
}
