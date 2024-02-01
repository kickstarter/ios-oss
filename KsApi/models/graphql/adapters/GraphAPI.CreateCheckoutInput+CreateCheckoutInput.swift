import Foundation
import ReactiveSwift

extension GraphAPI.CreateCheckoutInput {
  static func from(_ input: CreateCheckoutInput) -> GraphAPI.CreateCheckoutInput {
    return GraphAPI
      .CreateCheckoutInput(
        projectId: input.projectId,
        amount: input.amount,
        locationId: input.locationId,
        rewardIds: input.rewardIds,
        refParam: input.refParam,
        clientMutationId: input.clientMutationId
      )
  }
}
