import Foundation

protocol KeyValueStoreType {
  func setObject(object: AnyObject?, forKey key: String)

  func objectForKey(key: String) -> AnyObject?
  func stringForKey(key: String) -> String?
  func dictionaryForKey(key: String) -> [String:AnyObject]?

  func removeObjectForKey(key: String)

  func synchronize () -> Bool
}

extension NSUserDefaults : KeyValueStoreType {}
extension NSUbiquitousKeyValueStore : KeyValueStoreType {}
