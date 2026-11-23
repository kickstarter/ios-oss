import Foundation
import GraphAPI

extension GraphAPI.CreateSetupIntentInput {
  static func from(_ input: CreateSetupIntentInput) -> GraphAPI.CreateSetupIntentInput {
    return GraphAPI.CreateSetupIntentInput(
      projectId: GraphQLNullable.someOrNil(input.projectId),
      setupIntentContext: GraphQLEnum.caseOrNil(input.setupIntentContext)
    )
  }
}
