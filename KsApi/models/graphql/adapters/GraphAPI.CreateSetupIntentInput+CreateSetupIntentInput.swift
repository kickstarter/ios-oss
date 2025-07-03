import Foundation

extension GraphAPI.CreateSetupIntentInput {
  static func from(_ input: CreateSetupIntentInput) -> GraphAPI.CreateSetupIntentInput {
    return GraphAPI.CreateSetupIntentInput(
      setupIntentContext: GraphQLNullable.caseOrNil(input.setupIntentContext),
      projectId: GraphQLNullable.someOrNil(input.projectId)
    )
  }
}
