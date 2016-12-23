import Foundation

/**
 *  A type that behaves like a NSHTTPCookieStorage.
 */
public protocol HTTPCookieStorageProtocol {
  var cookies: [HTTPCookie]? { get }
  func deleteCookie(_ cookie: HTTPCookie)
  func setCookie(_ cookie: HTTPCookie)
}

extension HTTPCookieStorage: HTTPCookieStorageProtocol {
}

internal final class MockCookieStorage: HTTPCookieStorageProtocol {
  fileprivate var storage: Set<HTTPCookie> = []

  internal var cookies: [HTTPCookie]? {
    return Array(self.storage)
  }

  internal func deleteCookie(_ cookie: HTTPCookie) {
    if let idx = self.storage.index(of: cookie) {
      self.storage.remove(at: idx)
    }
  }

  internal func setCookie(_ cookie: HTTPCookie) {
    self.storage.insert(cookie)
  }
}
