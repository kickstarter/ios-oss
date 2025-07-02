import Foundation

extension GraphAPI.CreateSetupIntentInput {
  static func from(_ input: CreateSetupIntentInput) -> GraphAPI.CreateSetupIntentInput {
    return GraphAPI.CreateSetupIntentInput(
      setupIntentContext: GraphQLInput.caseOrNil(input.setupIntentContext),
      projectId: GraphQLInput.someOrNil(input.projectId)
    )
  }
}
