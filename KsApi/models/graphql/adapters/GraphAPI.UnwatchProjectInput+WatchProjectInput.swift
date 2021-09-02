import Foundation

extension GraphAPI.UnwatchProjectInput {
  static func from(_ input: WatchProjectInput) -> GraphAPI.UnwatchProjectInput {
    return GraphAPI.UnwatchProjectInput(
      id: input.id,
      trackingContext: input.trackingContext,
      clientMutationId: input.clientMutationId
    )
  }
}
