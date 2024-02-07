import Foundation

/// PKCE stands for Proof Key for Code Exchange.
/// The code verifier, and its associated challenge, are used to ensure that an oAuth request is valid.
/// See this documentation for more details: https://www.oauth.com/oauth2-servers/mobile-and-native-apps/authorization/
public struct PKCE {
  public static let minCodeVerifierLength = 43
  public static let maxCodeVerifierLength = 128
  public static let codeVerifierRegexPattern = "^[0-9a-zA-Z\\-._~]{43,128}$"

  /// Creates a random alphanumeric string of the specified length
  public static func createCodeVerifier(byteLength length: Int) throws -> String {
    do {
      var buffer = Data(count: length)
      try buffer.fillWithRandomSecureBytes()
      return buffer.base64URLEncodedStringWithNoPadding()
    } catch _ {
      throw PKCEError.UnexpectedRuntimeError
    }
  }

  /// Creates a base-64 encoded SHA256 hash of the given string.
  public static func createCodeChallenge(fromVerifier verifier: String) throws -> String {
    guard let stringData = verifier.data(using: .utf8) else {
      throw PKCEError.UnexpectedRuntimeError
    }

    do {
      let hash = try stringData.sha256Hash()
      return hash.base64URLEncodedStringWithNoPadding()
    } catch {
      throw PKCEError.UnexpectedRuntimeError
    }
  }

  public static func checkCodeVerifier(_ codeVerifier: String) -> Bool {
    if codeVerifier.count < self.minCodeVerifierLength {
      return false
    }

    if codeVerifier.count > self.maxCodeVerifierLength {
      return false
    }

    do {
      let regex = try NSRegularExpression(pattern: codeVerifierRegexPattern)
      let matches = regex
        .numberOfMatches(in: codeVerifier, range: NSRange(location: 0, length: codeVerifier.count))
      if matches == 0 {
        return false
      }
    } catch {
      return false
    }

    return true
  }
}
