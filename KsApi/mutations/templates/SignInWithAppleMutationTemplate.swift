import Apollo
@testable import KsApi

public enum SignInWithAppleMutationTemplate {
  case valid
  case errored

  var data: GraphAPI.SignInWithAppleMutation.Data {
    switch self {
    case .valid:
      return GraphAPI.SignInWithAppleMutation
        .Data(unsafeResultMap: self.signInWithAppleMutationResultMap)
    case .errored:
      return GraphAPI.SignInWithAppleMutation
        .Data(unsafeResultMap: self.signInWithAppleMutationErroredResultMap)
    }
  }

  // MARK: Private Properties

  private var signInWithAppleMutationResultMap: [String: Any?] {
    [
      "signInWithApple": [
        "apiAccessToken": "foobar",
        "user": [
          "uid": "deadbeef"
        ]
      ]
    ]
  }

  private var signInWithAppleMutationErroredResultMap: [String: Any?] {
    let resultMap = self.signInWithAppleMutationResultMap

    let topLevelMap = resultMap["signInWithApple"] ?? [:]

    let erroredMap = ["wrongKey": topLevelMap]

    return erroredMap
  }
}
