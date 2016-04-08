import Foundation

/**
 *  A type that behaves like a NSHTTPCookieStorage.
 */
public protocol NSHTTPCookieStorageType {
  var cookies: [NSHTTPCookie]? { get }
  func deleteCookie(cookie: NSHTTPCookie)
  func setCookie(cookie: NSHTTPCookie)
}

extension NSHTTPCookieStorage: NSHTTPCookieStorageType {
}

internal final class MockCookieStorage: NSHTTPCookieStorageType {
  private var storage: Set<NSHTTPCookie> = []

  internal var cookies: [NSHTTPCookie]? {
    return Array(self.storage)
  }

  internal func deleteCookie(cookie: NSHTTPCookie) {
    if let idx = self.storage.indexOf(cookie) {
      self.storage.removeAtIndex(idx)
    }
  }

  internal func setCookie(cookie: NSHTTPCookie) {
    self.storage.insert(cookie)
  }
}
