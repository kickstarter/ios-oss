import Foundation

public protocol KeyValueStoreType {
  func setObject(object: AnyObject?, forKey key: String)

  func objectForKey(key: String) -> AnyObject?
  func stringForKey(key: String) -> String?
  func dictionaryForKey(key: String) -> [String:AnyObject]?

  func removeObjectForKey(key: String)

  func synchronize() -> Bool
}

extension NSUserDefaults : KeyValueStoreType {}
extension NSUbiquitousKeyValueStore : KeyValueStoreType {}

internal class MockKeyValueStore: KeyValueStoreType {
  var store: [String:AnyObject] = [:]

  func setObject(object: AnyObject?, forKey key: String) {
    self.store[key] = object
  }

  func objectForKey(key: String) -> AnyObject? {
    return self.store[key]
  }

  func stringForKey(key: String) -> String? {
    return self.objectForKey(key) as? String
  }

  func dictionaryForKey(key: String) -> [String:AnyObject]? {
    return self.objectForKey(key) as? [String:AnyObject]
  }

  func removeObjectForKey(key: String) {
    self.setObject(nil, forKey: key)
  }

  func synchronize() -> Bool {
    return true
  }
}
