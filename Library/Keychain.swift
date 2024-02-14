import Foundation
import Security

public enum KeychainError: Error {
  case unexpectedStatus(OSStatus)
  case unableToDecodePasswordData

  public var errorMessage: String {
    switch self {
    case let .unexpectedStatus(status):
      let errString = SecCopyErrorMessageString(status, nil) as String?
      return errString ?? "Unknown keychain error"
    case .unableToDecodePasswordData:
      return "Unable to decode password data from keychain."
    }
  }
}

public struct Keychain {
  private static var serviceName: String {
    return Bundle.main.bundleIdentifier ?? "com.kickstarter.kickstarter"
  }

  public static func deleteAllPasswords() throws {
    let query: [String: AnyObject] = [
      kSecAttrService as String: self.serviceName as AnyObject,
      kSecClass as String: kSecClassGenericPassword as AnyObject
    ]

    let status = SecItemDelete(query as CFDictionary)

    if status == errSecItemNotFound {
      return
    } else if status != errSecSuccess {
      throw KeychainError.unexpectedStatus(status)
    }
  }

  public static func deletePassword(forAccount account: String) throws {
    let query: [String: AnyObject] = [
      kSecAttrService as String: self.serviceName as AnyObject,
      kSecClass as String: kSecClassGenericPassword as AnyObject,
      kSecAttrAccount as String: account as AnyObject
    ]

    let status = SecItemDelete(query as CFDictionary)

    if status == errSecItemNotFound {
      return
    } else if status != errSecSuccess {
      throw KeychainError.unexpectedStatus(status)
    }
  }

  public static func storePassword(_ password: String, forAccount account: String) throws {
    var query: [String: AnyObject] = [
      kSecAttrService as String: self.serviceName as AnyObject,
      kSecAttrAccount as String: account as AnyObject,
      kSecClass as String: kSecClassGenericPassword as AnyObject
    ]

    let status: OSStatus
    let passwordData = password.data(using: .utf8)

    if self.hasPassword(forAccount: account) {
      // If the password already exists for the account, update it.
      let attributes: [String: AnyObject] = [
        kSecValueData as String: passwordData as AnyObject
      ]
      status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
    } else {
      // Otherwise, add it.
      query[kSecValueData as String] = passwordData as AnyObject
      status = SecItemAdd(query as CFDictionary, nil)
    }

    if status != errSecSuccess {
      throw KeychainError.unexpectedStatus(status)
    }
  }

  public static func hasPassword(forAccount account: String) -> Bool {
    do {
      return try self.fetchPassword(forAccount: account) != nil
    } catch {
      return false
    }
  }

  public static func fetchPassword(forAccount account: String) throws -> String? {
    let query: [String: AnyObject] = [
      kSecAttrService as String: self.serviceName as AnyObject,
      kSecAttrAccount as String: account as AnyObject,
      kSecClass as String: kSecClassGenericPassword as AnyObject,
      kSecMatchLimit as String: kSecMatchLimitOne,
      kSecReturnData as String: kCFBooleanTrue
    ]

    var passwordObject: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &passwordObject)

    if status == errSecItemNotFound {
      return nil
    } else if status != errSecSuccess {
      throw KeychainError.unexpectedStatus(status)
    }

    guard let passwordData = passwordObject as? Data else {
      throw KeychainError.unableToDecodePasswordData
    }

    let password = String(decoding: passwordData, as: UTF8.self)
    return password
  }
}
