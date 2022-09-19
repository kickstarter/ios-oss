import Foundation

public struct CreateSetupIntentInput: GraphMutationInput, Encodable {
  let projectId: String?

  /**
   An input object for the CreateSetupIntentMutation
   - parameter projectId: A project id that is needed by GraphQL to generate a client secret.
   */
  public init(projectId: String?) {
    self.projectId = projectId
  }

  public func toInputDictionary() -> [String: Any?] {
    return [
      "projectId": self.projectId
    ]
  }
}
