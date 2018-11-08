import Foundation

public struct UnwatchProjectMutation<T: GraphMutationInput>: GraphMutation {
  var input: T

  public init(input: T) {
    self.input = input
  }

  public var description: String {
    let desc = """
    mutation unwatchProject($input: UnwatchProjectInput!) {
      watchProject: unwatchProject(input: $input) {
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
