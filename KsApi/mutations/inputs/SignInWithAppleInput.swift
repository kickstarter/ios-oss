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

  public func toInputDictionary() -> [String: Any] {
    return [
      "iosAppId": appId,
      "authCode": authCode,
      "firstName": firstName,
      "lastName": lastName
    ].compact()
  }
}
