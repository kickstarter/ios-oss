import Foundation

public struct AddUserToSecretRewardGroupInput: GraphMutationInput, Encodable {
  let projectId: String
  let secretRewardToken: String

  public init(
    projectId: String,
    secretRewardToken: String
  ) {
    self.projectId = projectId
    self.secretRewardToken = secretRewardToken
  }
}
