import Foundation
import GraphAPI

extension GraphAPI.UnwatchProjectInput {
  static func from(_ input: WatchProjectInput) -> GraphAPI.UnwatchProjectInput {
    return GraphAPI.UnwatchProjectInput(
      id: input.id,
      trackingContext: GraphQLNullable.someOrNil(input.trackingContext),
      clientMutationId: GraphQLNullable.someOrNil(input.clientMutationId)
    )
  }
}
