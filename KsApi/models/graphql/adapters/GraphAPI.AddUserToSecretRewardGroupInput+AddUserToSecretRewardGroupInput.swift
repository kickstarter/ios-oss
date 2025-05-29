import Foundation

extension GraphAPI.AddUserToSecretRewardGroupInput {
  static func from(_ input: AddUserToSecretRewardGroupInput) -> GraphAPI.AddUserToSecretRewardGroupInput {
    return GraphAPI.AddUserToSecretRewardGroupInput(
      projectId: input.projectId,
      secretRewardToken: input.secretRewardToken
    )
  }
}
