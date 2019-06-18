public struct ClearUserUnseenActivityMutation<T: GraphMutationInput>: GraphMutation {
  var input: T

  public init(input: T) {
    self.input = input
  }

  public var description: String {
    return """
    mutation clearUserUnseenActivity($input: ClearUserUnseenActivityInput!) {
      clearUserUnseenActivity(input: $input) {
        clientMutationId
        activityIndicatorCount
      }
    }
    """
  }
}
