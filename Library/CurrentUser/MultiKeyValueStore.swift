import class Foundation.NSUserDefaults
import class Foundation.NSUbiquitousKeyValueStore

struct MultiKeyValueStore : KeyValueStoreType {
  let stores: [KeyValueStoreType] = [NSUbiquitousKeyValueStore.defaultStore(), NSUserDefaults.standardUserDefaults()]

  func setObject(object: AnyObject?, forKey key: String) {
    for store in stores {
      store.setObject(object, forKey: key)
    }
  }

  func objectForKey(key: String) -> AnyObject? {
    return stores.reduce(nil) { accum, store in
      return accum ?? store.objectForKey(key)
    }
  }

  func stringForKey(key: String) -> String? {
    return objectForKey(key) as? String
  }

  func dictionaryForKey(key: String) -> [String : AnyObject]? {
    return objectForKey(key) as? [String:AnyObject]
  }

  func removeObjectForKey(key: String) {
    for store in stores {
      store.removeObjectForKey(key)
    }
  }

  func synchronize() -> Bool {
    return stores.reduce(true) { accum, store in
      return accum && store.synchronize()
    }
  }
}
