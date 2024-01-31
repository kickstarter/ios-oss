import CryptoKit
import Foundation
import Security

enum PKCEError: Error {
  case UnexpectedRuntimeError
}

public extension Data {
  func base64URLEncodedStringWithNoPadding() -> String {
    var encodedString = self.base64EncodedString()

    // Convert base64 to base64url
    encodedString = encodedString.replacingOccurrences(of: "+", with: "-")
    encodedString = encodedString.replacingOccurrences(of: "/", with: "_")
    // Strip padding
    encodedString = encodedString.replacingOccurrences(of: "=", with: "")

    return encodedString
  }

  mutating func fillWithRandomSecureBytes() throws {
    do {
      let numBytes = self.count
      try self.withUnsafeMutableBytes { rawPointer in
        let pointer = rawPointer.bindMemory(to: UInt8.self)
        guard let address = pointer.baseAddress else {
          throw PKCEError.UnexpectedRuntimeError
        }

        let result = SecRandomCopyBytes(kSecRandomDefault, numBytes, address)

        if result != errSecSuccess {
          throw PKCEError.UnexpectedRuntimeError
        }
      }
    } catch {
      throw error
    }
  }

  func sha256Hash() throws -> Data {
    let hash = SHA256.hash(data: self)
    var hashData: Data?

    hash.withUnsafeBytes { pointer in
      let dataPointer = pointer.bindMemory(to: UInt8.self)
      hashData = Data(buffer: dataPointer)
    }

    guard let unwrappedData = hashData else {
      throw PKCEError.UnexpectedRuntimeError
    }

    return unwrappedData
  }
}

/// PKCE stands for Proof Key for Code Exchange.
/// The code verifier, and its associated challenge, are used to ensure that an oAuth request is valid.
/// See this documentation for more details: https://www.oauth.com/oauth2-servers/mobile-and-native-apps/authorization/
public struct PKCE {
  /// Creates a random alphanumeric string of the specified length
  static func createCodeVerifier(byteLength length: Int) throws -> String {
    do {
      var buffer = Data(count: length)
      try buffer.fillWithRandomSecureBytes()
      return buffer.base64URLEncodedStringWithNoPadding()
    } catch _ {
      throw PKCEError.UnexpectedRuntimeError
    }
  }

  /// Creates a base-64 encoded SHA256 hash of the given string.
  static func createCodeChallenge(fromVerifier verifier: String) throws -> String {
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
}
