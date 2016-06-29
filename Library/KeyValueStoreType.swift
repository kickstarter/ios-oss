import Foundation

internal enum AppKeys: String {
  case ClosedFacebookConnectInActivity = "com.kickstarter.KeyValueStoreType.closedFacebookConnectInActivity"
  case ClosedFindFriendsInActivity = "com.kickstarter.KeyValueStoreType.closedFindFriendsInActivity"
  case SeenAppRating = "com.kickstarter.KeyValueStoreType.hasSeenAppRating"
  case SeenGamesNewsletter = "com.kickstarter.KeyValueStoreType.hasSeenGamesNewsletter"
}

public protocol KeyValueStoreType: class {
  func setBool(bool: Bool, forKey key: String)
  func setObject(object: AnyObject?, forKey key: String)

  func boolForKey(key: String) -> Bool
  func dictionaryForKey(key: String) -> [String:AnyObject]?
  func objectForKey(key: String) -> AnyObject?
  func stringForKey(key: String) -> String?

  func removeObjectForKey(key: String)

  var hasClosedFacebookConnectInActivity: Bool { get set }
  var hasClosedFindFriendsInActivity: Bool { get set }
  var hasSeenAppRating: Bool { get set }
  var hasSeenGamesNewsletterPrompt: Bool { get set }
}

extension KeyValueStoreType {
  public var hasClosedFacebookConnectInActivity: Bool {
    get {
      return self.objectForKey(AppKeys.ClosedFacebookConnectInActivity.rawValue) as? Bool ?? false
    }
    set {
      self.setObject(newValue, forKey: AppKeys.ClosedFacebookConnectInActivity.rawValue)
    }
  }

  public var hasClosedFindFriendsInActivity: Bool {
    get {
      return self.objectForKey(AppKeys.ClosedFindFriendsInActivity.rawValue) as? Bool ?? false
    }
    set {
      self.setObject(newValue, forKey: AppKeys.ClosedFindFriendsInActivity.rawValue)
    }
  }

  public var hasSeenAppRating: Bool {
    get {
      return self.boolForKey(AppKeys.SeenAppRating.rawValue)
    }
    set {
      self.setBool(newValue, forKey: AppKeys.SeenAppRating.rawValue)
    }
  }

  public var hasSeenGamesNewsletterPrompt: Bool {
    get {
      return self.boolForKey(AppKeys.SeenGamesNewsletter.rawValue)
    }
    set {
      self.setBool(newValue, forKey: AppKeys.SeenGamesNewsletter.rawValue)
    }
  }
}

extension NSUserDefaults: KeyValueStoreType {
}

extension NSUbiquitousKeyValueStore: KeyValueStoreType {
}

internal class MockKeyValueStore: KeyValueStoreType {
  var store: [String:AnyObject] = [:]

  func setBool(bool: Bool, forKey key: String) {
    self.store[key] = bool
  }

  func setObject(object: AnyObject?, forKey key: String) {
    self.store[key] = object
  }

  func boolForKey(key: String) -> Bool {
    return self.store[key] as? Bool ?? false
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
}
