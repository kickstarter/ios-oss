import Foundation

extension GraphAPI.WatchProjectInput {
  static func from(_ input: WatchProjectInput) -> GraphAPI.WatchProjectInput {
    return GraphAPI.WatchProjectInput(
      id: input.id,
      trackingContext: GraphQLInput.someOrNil(input.trackingContext),
      clientMutationId: GraphQLInput.someOrNil(input.clientMutationId)
    )
  }
}
