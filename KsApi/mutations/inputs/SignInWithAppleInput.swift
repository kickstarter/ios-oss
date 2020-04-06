import Foundation

public struct SignInWithAppleInput: GraphMutationInput {
  public let authCode: String
  public let firstName: String
  public let lastName: String

  public init(authCode: String, firstName: String, lastName: String) {
    self.authCode = authCode
    self.firstName = firstName
    self.lastName = lastName
  }

  public func toInputDictionary() -> [String: Any] {
    return [
      "authCode": authCode,
      "firstName": firstName,
      "lastName": lastName
    ]
  }
}
