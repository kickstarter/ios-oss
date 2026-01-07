import Foundation

public struct WatchProjectMutation<T: GraphMutationInput>: GraphMutation {
  var input: T

  public init(input: T) {
    self.input = input
  }

  public var description: String {
    let desc = """
    mutation watchProject($input: WatchProjectInput!) {
      watchProject(input: $input) {
        clientMutationId
        project {
          id
          isWatched
        }
      }
    }
    """

    return desc
  }
}
