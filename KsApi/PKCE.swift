import CryptoKit
import Foundation

/// PKCE stands for Proof Key for Code Exchange.
/// The code verifier, and its associated challenge, are used to ensure that an oAuth request is valid.
/// See this documentation for more details: https://www.oauth.com/oauth2-servers/mobile-and-native-apps/authorization/
public struct PKCE {
  /// Creates a random alphanumeric string of the specified length
  static func createCodeVerifier(ofLength length: Int) throws -> String {
    let uppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    let lowercase = "abcdefghijklmnopqrstuvwxyz"
    let numbers = "0123456789"
    let specials = "-._~"

    let validCharacters = uppercase + lowercase + numbers + specials

    var codeVerifier = ""

    for _ in 0..<length {
      guard let character = validCharacters.randomElement() else {
        throw ErrorType.UnableToCreateCodeVerifier
      }

      codeVerifier += String(character)
    }

    return codeVerifier
  }

  /// Creates a base-64 encoded SHA256 hash of the given string.
  static func createCodeChallenge(fromVerifier verifier: String) throws -> String {
    guard let stringData = verifier.data(using: .utf8) else {
      throw ErrorType.UnableToCreateCodeChallenge
    }

    let hash = SHA256.hash(data: stringData)
    var hashData: Data?

    hash.withUnsafeBytes { pointer in
      let dataPointer = pointer.bindMemory(to: UInt8.self)
      hashData = Data(buffer: dataPointer)
    }

    guard let unwrappedData = hashData else {
      throw ErrorType.UnableToCreateCodeChallenge
    }

    return unwrappedData.base64EncodedString()
  }

  /// Errors that can occur in the PKCE flow.
  /// Note that these are exceptional errors - effectively run time errors that we don't ever expect to happen.
  /// However, because PKCE is a critical part of auth, it's worthwhile to be explicit if the unexpected ever *did* happen.
  public enum ErrorType: Error {
    case UnableToCreateCodeChallenge
    case UnableToCreateCodeVerifier
  }
}
