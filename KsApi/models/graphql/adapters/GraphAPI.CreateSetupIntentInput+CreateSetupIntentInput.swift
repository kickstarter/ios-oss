import Foundation

extension GraphAPI.CreateSetupIntentInput {
  static func from(_ input: CreateSetupIntentInput) -> GraphAPI.CreateSetupIntentInput {
    return GraphAPI.CreateSetupIntentInput(
      setupIntentContext: .caseOrNil(input.setupIntentContext),
      projectId: .someOrNil(input.projectId)
    )
  }
}
