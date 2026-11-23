import Foundation
import GraphAPI

extension GraphAPI.WatchProjectInput {
  static func from(_ input: WatchProjectInput) -> GraphAPI.WatchProjectInput {
    return GraphAPI.WatchProjectInput(
      clientMutationId: GraphQLNullable.someOrNil(input.clientMutationId),
      id: input.id,
      trackingContext: GraphQLNullable.someOrNil(input.trackingContext)
    )
  }
}
