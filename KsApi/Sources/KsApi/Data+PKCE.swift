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
