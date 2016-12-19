import Foundation

public protocol CacheProtocol: class {
  subscript(key: String) -> AnyObject? { get set }
  init()
  func removeAllObjects()
}

extension CacheProtocol {
  subscript(key: String) -> Bool? {
    get {
      return self[key] as? Bool
    }
  }

  subscript(key: String) -> Int? {
    get {
      return self[key] as? Int
    }
  }

  subscript(key: String) -> String? {
    get {
      return self[key] as? String
    }
  }
}

extension NSCache: CacheProtocol {
  public subscript(key: String) -> AnyObject? {
    get {
      return object(forKey: key)
    }
    set {
      if let newValue = newValue {
        setObject(newValue, forKey: key)
      } else {
        removeObject(forKey: key)
      }
    }
  }
}

internal final class MockCache: CacheProtocol {
  fileprivate var cache: [String: AnyObject] = [:]

  subscript(key: String) -> AnyObject? {
    get {
      return self.cache[key]
    }
    set {
      self.cache[key] = newValue
    }
  }

  func removeAllObjects() {
    self.cache = [:]
  }
}
