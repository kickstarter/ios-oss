import Foundation

public struct SignInWithAppleInput: GraphMutationInput {
  public let appId: String
  public let authCode: String
  public let firstName: String?
  public let lastName: String?

  public init(appId: String, authCode: String, firstName: String?, lastName: String?) {
    self.appId = appId
    self.authCode = authCode
    self.firstName = firstName
    self.lastName = lastName
  }
}

extension SignInWithAppleInput: Encodable {
  enum CodingKeys: String, CodingKey {
    case appId = "iosAppId"
    case authCode
    case firstName
    case lastName
  }
}
