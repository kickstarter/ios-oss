import Foundation

internal enum AppKeys: String {
  case ClosedFacebookConnectInActivity = "com.kickstarter.KeyValueStoreType.closedFacebookConnectInActivity"
  case ClosedFindFriendsInActivity = "com.kickstarter.KeyValueStoreType.closedFindFriendsInActivity"
  case SeenAppRating = "com.kickstarter.KeyValueStoreType.hasSeenAppRating"
  case SeenGamesNewsletter = "com.kickstarter.KeyValueStoreType.hasSeenGamesNewsletter"
}

public protocol KeyValueStoreType: class {
  func setObject(object: AnyObject?, forKey key: String)

  func objectForKey(key: String) -> AnyObject?
  func stringForKey(key: String) -> String?
  func dictionaryForKey(key: String) -> [String:AnyObject]?

  func removeObjectForKey(key: String)

  func synchronize() -> Bool

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
      return self.objectForKey(AppKeys.SeenAppRating.rawValue) as? Bool ?? false
    }
    set {
      self.setObject(newValue, forKey: AppKeys.SeenAppRating.rawValue)
    }
  }

  public var hasSeenGamesNewsletterPrompt: Bool {
    get {
      return self.objectForKey(AppKeys.SeenGamesNewsletter.rawValue) as? Bool ?? false
    }
    set {
      self.setObject(newValue, forKey: AppKeys.SeenGamesNewsletter.rawValue)
    }
  }
}

extension NSUserDefaults: KeyValueStoreType {
}

extension NSUbiquitousKeyValueStore: KeyValueStoreType {
}

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
