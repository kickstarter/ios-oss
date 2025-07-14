import Apollo
import GraphAPI
@testable import KsApi

public enum SignInWithAppleMutationTemplate {
  case valid
  case errored

  var data: GraphAPI.SignInWithAppleMutation.Data {
    switch self {
    case .valid:
      return try! testGraphObject(data: self.signInWithAppleMutationResultMap)
    case .errored:
      return try! testGraphObject(data: self.signInWithAppleMutationErroredResultMap)
    }
  }

  // MARK: Private Properties

  private var signInWithAppleMutationResultMap: [String: Any] {
    [
      "signInWithApple": [
        "apiAccessToken": "foobar",
        "user": [
          "uid": "deadbeef"
        ]
      ]
    ]
  }

  private var signInWithAppleMutationErroredResultMap: [String: Any] {
    let resultMap = self.signInWithAppleMutationResultMap

    let topLevelMap = resultMap["signInWithApple"] ?? [:]

    let erroredMap = ["wrongKey": topLevelMap]

    return erroredMap
  }
}
