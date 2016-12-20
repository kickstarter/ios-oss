import Foundation

public final class KSCache {
  private let cache = NSCache<NSString, AnyObject>()

  public init() {
  }

  public subscript(key: String) -> AnyObject? {
    get {
      return self.cache.object(forKey: key as NSString)
    }
    set {
      if let newValue = newValue {
        self.cache.setObject(newValue, forKey: key as NSString)
      } else {
        self.cache.removeObject(forKey: key as NSString)
      }
    }
  }

  public func removeAllObjects() {
    self.cache.removeAllObjects()
  }
}
