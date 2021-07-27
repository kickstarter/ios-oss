import Foundation

extension GraphAPI.WatchProjectInput {
  static func from(_ input: WatchProjectInput) -> GraphAPI.WatchProjectInput {
    return GraphAPI.WatchProjectInput(
      id: input.id,
      trackingContext: input.trackingContext,
      clientMutationId: input.clientMutationId
    )
  }
}
