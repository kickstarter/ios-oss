import Foundation

public struct CreateSetupIntentInput: GraphMutationInput, Encodable {
  let projectId: String?
  let setupIntentContext: GraphAPI.StripeIntentContextTypes?

  /**
   An input object for the CreateSetupIntentMutation
   - parameter projectId: A project id that is needed by GraphQL to generate a client secret.
   */
  public init(projectId: String?, context: GraphAPI.StripeIntentContextTypes?) {
    self.projectId = projectId
    self.setupIntentContext = context
  }

  public func toInputDictionary() -> [String: Any?] {
    return [
      "projectId": self.projectId,
      "setupIntentContext": self.setupIntentContext
    ]
  }
}

extension GraphAPI.StripeIntentContextTypes: Encodable {}
