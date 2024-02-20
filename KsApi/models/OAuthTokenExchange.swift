import Foundation

public struct OAuthTokenExchangeParams {
  public init(temporaryToken: String, codeVerifier: String) {
    self.temporaryToken = temporaryToken
    self.codeVerifier = codeVerifier
  }

  let temporaryToken: String
  let codeVerifier: String

  var queryParams: [String: String] {
    return [
      "code": self.temporaryToken,
      "code_verifier": self.codeVerifier
    ]
  }
}

public struct OAuthTokenExchangeResponse: Decodable {
  public let token: String

  public init(token: String) {
    self.token = token
  }
}
