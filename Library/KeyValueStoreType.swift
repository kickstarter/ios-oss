import Foundation

public enum AppKeys: String {
  case closedFacebookConnectInActivity = "com.kickstarter.KeyValueStoreType.closedFacebookConnectInActivity"
  case closedFindFriendsInActivity = "com.kickstarter.KeyValueStoreType.closedFindFriendsInActivity"
  case favoriteCategoryIds = "favorite_category_ids"
  case hasSeenFavoriteCategoryAlert = "com.kickstarter.KeyValueStoreType.hasSeenFavoriteCategoryAlert"
  case lastSeenActivitySampleId = "com.kickstarter.KeyValueStoreType.lastSeenActivitySampleId"
  case seenAppRating = "com.kickstarter.KeyValueStoreType.hasSeenAppRating"
  case seenGamesNewsletter = "com.kickstarter.KeyValueStoreType.hasSeenGamesNewsletter"
}

public protocol KeyValueStoreType: class {
  func setBool(_ bool: Bool, forKey key: String)
  func setInteger(_ int: Int, forKey key: String)
  func setObject(_ object: AnyObject?, forKey key: String)

  func boolForKey(_ key: String) -> Bool
  func dictionaryForKey(_ key: String) -> [String:AnyObject]?
  func integerForKey(_ key: String) -> Int
  func objectForKey(_ key: String) -> AnyObject?
  func stringForKey(_ key: String) -> String?
  func synchronize() -> Bool

  func removeObjectForKey(_ key: String)

  var favoriteCategoryIds: [Int] { get set }
  var hasClosedFacebookConnectInActivity: Bool { get set }
  var hasClosedFindFriendsInActivity: Bool { get set }
  var hasSeenAppRating: Bool { get set }
  var hasSeenFavoriteCategoryAlert: Bool { get set }
  var hasSeenGamesNewsletterPrompt: Bool { get set }
  var lastSeenActivitySampleId: Int { get set }
}

extension KeyValueStoreType {
  public var favoriteCategoryIds: [Int] {
    get {
      return self.objectForKey(AppKeys.favoriteCategoryIds.rawValue) as? [Int] ?? []
    }
    set {
      self.setObject(newValue as AnyObject?, forKey: AppKeys.favoriteCategoryIds.rawValue)
    }
  }

  public var hasClosedFacebookConnectInActivity: Bool {
    get {
      return self.objectForKey(AppKeys.closedFacebookConnectInActivity.rawValue) as? Bool ?? false
    }
    set {
      self.setObject(newValue as AnyObject?, forKey: AppKeys.closedFacebookConnectInActivity.rawValue)
    }
  }

  public var hasClosedFindFriendsInActivity: Bool {
    get {
      return self.objectForKey(AppKeys.closedFindFriendsInActivity.rawValue) as? Bool ?? false
    }
    set {
      self.setObject(newValue as AnyObject?, forKey: AppKeys.closedFindFriendsInActivity.rawValue)
    }
  }

  public var hasSeenAppRating: Bool {
    get {
      return self.boolForKey(AppKeys.seenAppRating.rawValue)
    }
    set {
      self.setBool(newValue, forKey: AppKeys.seenAppRating.rawValue)
    }
  }

  public var hasSeenFavoriteCategoryAlert: Bool {
    get {
      return self.boolForKey(AppKeys.hasSeenFavoriteCategoryAlert.rawValue)
    }
    set {
      self.setBool(newValue, forKey: AppKeys.hasSeenFavoriteCategoryAlert.rawValue)
    }
  }

  public var hasSeenGamesNewsletterPrompt: Bool {
    get {
      return self.boolForKey(AppKeys.seenGamesNewsletter.rawValue)
    }
    set {
      self.setBool(newValue, forKey: AppKeys.seenGamesNewsletter.rawValue)
    }
  }

  public var lastSeenActivitySampleId: Int {
    get {
      return self.integerForKey(AppKeys.lastSeenActivitySampleId.rawValue)
    }
    set {
      self.setInteger(newValue, forKey: AppKeys.lastSeenActivitySampleId.rawValue)
    }
  }
}

extension UserDefaults: KeyValueStoreType {
}

extension NSUbiquitousKeyValueStore: KeyValueStoreType {
  public func integerForKey(_ key: String) -> Int {
    return Int(longLong(forKey: key))
  }

  public func setInteger(_ int: Int, forKey key: String) {
    return set(Int64(int), forKey: key)
  }
}

internal class MockKeyValueStore: KeyValueStoreType {
  var store: [String:AnyObject] = [:]

  func setBool(_ bool: Bool, forKey key: String) {
    self.store[key] = bool as AnyObject?
  }

  func setInteger(_ int: Int, forKey key: String) {
    self.store[key] = int as AnyObject?
  }

  func setObject(_ object: AnyObject?, forKey key: String) {
    self.store[key] = object
  }

  func boolForKey(_ key: String) -> Bool {
    return self.store[key] as? Bool ?? false
  }

  func integerForKey(_ key: String) -> Int {
    return self.store[key] as? Int ?? 0
  }

  func objectForKey(_ key: String) -> AnyObject? {
    return self.store[key]
  }

  func stringForKey(_ key: String) -> String? {
    return self.objectForKey(key) as? String
  }

  func dictionaryForKey(_ key: String) -> [String:AnyObject]? {
    return self.objectForKey(key) as? [String:AnyObject]
  }

  func removeObjectForKey(_ key: String) {
    self.setObject(nil, forKey: key)
  }

  func synchronize() -> Bool {
    return true
  }
}
