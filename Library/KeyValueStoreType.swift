import Foundation

public enum AppKeys: String {
  case closedFacebookConnectInActivity = "com.kickstarter.KeyValueStoreType.closedFacebookConnectInActivity"
  case closedFindFriendsInActivity = "com.kickstarter.KeyValueStoreType.closedFindFriendsInActivity"
  case favoriteCategoryIds = "favorite_category_ids"
  case hasSeenFavoriteCategoryAlert = "com.kickstarter.KeyValueStoreType.hasSeenFavoriteCategoryAlert"
  case lastSeenActivitySampleId = "com.kickstarter.KeyValueStoreType.lastSeenActivitySampleId"
  case seenAppRating = "com.kickstarter.KeyValueStoreType.hasSeenAppRating"
  case seenGamesNewsletter = "com.kickstarter.KeyValueStoreType.hasSeenGamesNewsletter"
  case hasSeenSaveProjectAlert = "com.kickstarter.KeyValueStoreType.hasSeenSaveProjectAlert"
}

public protocol KeyValueStoreType: class {
  func set(_ value: Bool, forKey defaultName: String)
  func set(_ value: Int, forKey defaultName: String)
  func set(_ value: Any?, forKey defaultName: String)

  func bool(forKey defaultName: String) -> Bool
  func dictionary(forKey defaultName: String) -> [String: Any]?
  func integer(forKey defaultName: String) -> Int
  func object(forKey defaultName: String) -> Any?
  func string(forKey defaultName: String) -> String?
  func synchronize() -> Bool

  func removeObject(forKey defaultName: String)

  var favoriteCategoryIds: [Int] { get set }
  var hasClosedFacebookConnectInActivity: Bool { get set }
  var hasClosedFindFriendsInActivity: Bool { get set }
  var hasSeenAppRating: Bool { get set }
  var hasSeenFavoriteCategoryAlert: Bool { get set }
  var hasSeenGamesNewsletterPrompt: Bool { get set }
  var hasSeenSaveProjectAlert: Bool { get set }
  var lastSeenActivitySampleId: Int { get set }
}

extension KeyValueStoreType {
  public var favoriteCategoryIds: [Int] {
    get {
      return self.object(forKey: AppKeys.favoriteCategoryIds.rawValue) as? [Int] ?? []
    }
    set {
      self.set(newValue, forKey: AppKeys.favoriteCategoryIds.rawValue)
    }
  }

  public var hasClosedFacebookConnectInActivity: Bool {
    get {
      return self.object(forKey: AppKeys.closedFacebookConnectInActivity.rawValue) as? Bool ?? false
    }
    set {
      self.set(newValue, forKey: AppKeys.closedFacebookConnectInActivity.rawValue)
    }
  }

  public var hasClosedFindFriendsInActivity: Bool {
    get {
      return self.object(forKey: AppKeys.closedFindFriendsInActivity.rawValue) as? Bool ?? false
    }
    set {
      self.set(newValue, forKey: AppKeys.closedFindFriendsInActivity.rawValue)
    }
  }

  public var hasSeenAppRating: Bool {
    get {
      return self.bool(forKey: AppKeys.seenAppRating.rawValue)
    }
    set {
      self.set(newValue, forKey: AppKeys.seenAppRating.rawValue)
    }
  }

  public var hasSeenFavoriteCategoryAlert: Bool {
    get {
      return self.bool(forKey: AppKeys.hasSeenFavoriteCategoryAlert.rawValue)
    }
    set {
      self.set(newValue, forKey: AppKeys.hasSeenFavoriteCategoryAlert.rawValue)
    }
  }

  public var hasSeenGamesNewsletterPrompt: Bool {
    get {
      return self.bool(forKey: AppKeys.seenGamesNewsletter.rawValue)
    }
    set {
      self.set(newValue, forKey: AppKeys.seenGamesNewsletter.rawValue)
    }
  }

  public var hasSeenSaveProjectAlert: Bool {
    get {
      return self.bool(forKey: AppKeys.hasSeenSaveProjectAlert.rawValue)
    }
    set {
      self.set(newValue, forKey: AppKeys.hasSeenSaveProjectAlert.rawValue)
    }
  }

  public var lastSeenActivitySampleId: Int {
    get {
      return self.integer(forKey: AppKeys.lastSeenActivitySampleId.rawValue)
    }
    set {
      self.set(newValue, forKey: AppKeys.lastSeenActivitySampleId.rawValue)
    }
  }
}

extension UserDefaults: KeyValueStoreType {
}

extension NSUbiquitousKeyValueStore: KeyValueStoreType {
  public func integer(forKey defaultName: String) -> Int {
    return Int(longLong(forKey: defaultName))
  }

  public func set(_ value: Int, forKey defaultName: String) {
    return set(Int64(value), forKey: defaultName)
  }
}

internal class MockKeyValueStore: KeyValueStoreType {
  var store: [String: Any] = [:]

  func set(_ value: Bool, forKey defaultName: String) {
    self.store[defaultName] = value
  }

  func set(_ value: Int, forKey defaultName: String) {
    self.store[defaultName] = value
  }

  func set(_ value: Any?, forKey key: String) {
    self.store[key] = value
  }

  func bool(forKey defaultName: String) -> Bool {
    return self.store[defaultName] as? Bool ?? false
  }

  func dictionary(forKey key: String) -> [String: Any]? {
    return self.object(forKey: key) as? [String: Any]
  }

  func integer(forKey defaultName: String) -> Int {
    return self.store[defaultName] as? Int ?? 0
  }

  func object(forKey key: String) -> Any? {
    return self.store[key]
  }

  func string(forKey defaultName: String) -> String? {
    return self.store[defaultName] as? String
  }

  func removeObject(forKey defaultName: String) {
    self.set(nil, forKey: defaultName)
  }

  func synchronize() -> Bool {
    return true
  }
}
