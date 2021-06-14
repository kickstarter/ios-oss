import Foundation

public enum AppKeys: String {
  // swiftformat:disable wrap
  case closedFacebookConnectInActivity = "com.kickstarter.KeyValueStoreType.closedFacebookConnectInActivity"
  case closedFindFriendsInActivity = "com.kickstarter.KeyValueStoreType.closedFindFriendsInActivity"
  case deniedNotificationContexts = "com.kickstarter.KeyValueStoreType.deniedNotificationContexts"
  case favoriteCategoryIds = "favorite_category_ids"
  case hasCompletedCategoryPersonalizationFlow = "com.kickstarter.KeyValueStoreType.hasCompletedCategoryPersonalizationFlow"
  case hasSeenCategoryPersonalizationFlow = "com.kickstarter.KeyValueStoreType.hasSeenCategoryPersonalizationFlow"
  case hasDismissedPersonalizationCard = "com.kickstarter.KeyValueStoreType.hasDismissedPersonalizationCard"
  case hasSeenFavoriteCategoryAlert = "com.kickstarter.KeyValueStoreType.hasSeenFavoriteCategoryAlert"
  case hasSeenLandingPage = "com.kickstarter.KeyValueStoreType.hasSeenLandingPage"
  case hasSeenSaveProjectAlert = "com.kickstarter.KeyValueStoreType.hasSeenSaveProjectAlert"
  case lastSeenActivitySampleId = "com.kickstarter.KeyValueStoreType.lastSeenActivitySampleId"
  case onboardingCategories = "com.kickstarter.KeyValueStoreType.onboardingCategories"
  case seenAppRating = "com.kickstarter.KeyValueStoreType.hasSeenAppRating"
  case seenGamesNewsletter = "com.kickstarter.KeyValueStoreType.hasSeenGamesNewsletter"
  // swiftformat:enable wrap
}

public protocol KeyValueStoreType: AnyObject {
  func set(_ value: Bool, forKey defaultName: String)
  func set(_ value: Int, forKey defaultName: String)
  func set(_ value: Any?, forKey defaultName: String)

  func bool(forKey defaultName: String) -> Bool
  func data(forKey defaultName: String) -> Data?
  func dictionary(forKey defaultName: String) -> [String: Any]?
  func integer(forKey defaultName: String) -> Int
  func object(forKey defaultName: String) -> Any?
  func string(forKey defaultName: String) -> String?
  func synchronize() -> Bool

  func removeObject(forKey defaultName: String)
  var deniedNotificationContexts: [String] { get set }
  var favoriteCategoryIds: [Int] { get set }
  var hasClosedFacebookConnectInActivity: Bool { get set }
  var hasClosedFindFriendsInActivity: Bool { get set }
  var hasCompletedCategoryPersonalizationFlow: Bool { get set }
  var hasDismissedPersonalizationCard: Bool { get set }
  var hasSeenAppRating: Bool { get set }
  var hasSeenCategoryPersonalizationFlow: Bool { get set }
  var hasSeenFavoriteCategoryAlert: Bool { get set }
  var hasSeenLandingPage: Bool { get set }
  var hasSeenGamesNewsletterPrompt: Bool { get set }
  var hasSeenSaveProjectAlert: Bool { get set }
  var lastSeenActivitySampleId: Int { get set }
  var onboardingCategories: Data? { get set }
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

  public var deniedNotificationContexts: [String] {
    get {
      return self.object(forKey: AppKeys.deniedNotificationContexts.rawValue) as? [String] ?? []
    }
    set {
      self.set(newValue, forKey: AppKeys.deniedNotificationContexts.rawValue)
    }
  }

  public var hasSeenCategoryPersonalizationFlow: Bool {
    get {
      return self.bool(forKey: AppKeys.hasSeenCategoryPersonalizationFlow.rawValue)
    }
    set {
      self.set(newValue, forKey: AppKeys.hasSeenCategoryPersonalizationFlow.rawValue)
    }
  }

  public var hasDismissedPersonalizationCard: Bool {
    get {
      return self.bool(forKey: AppKeys.hasDismissedPersonalizationCard.rawValue)
    }
    set {
      self.set(newValue, forKey: AppKeys.hasDismissedPersonalizationCard.rawValue)
    }
  }

  public var hasCompletedCategoryPersonalizationFlow: Bool {
    get {
      return self.bool(forKey: AppKeys.hasCompletedCategoryPersonalizationFlow.rawValue)
    }
    set {
      self.set(newValue, forKey: AppKeys.hasCompletedCategoryPersonalizationFlow.rawValue)
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

  public var hasSeenLandingPage: Bool {
    get {
      return self.bool(forKey: AppKeys.hasSeenLandingPage.rawValue)
    }
    set {
      self.set(newValue, forKey: AppKeys.hasSeenLandingPage.rawValue)
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

  public var onboardingCategories: Data? {
    get {
      return self.data(forKey: AppKeys.onboardingCategories.rawValue)
    }

    set {
      self.set(newValue, forKey: AppKeys.onboardingCategories.rawValue)
    }
  }
}

extension UserDefaults: KeyValueStoreType {}

extension NSUbiquitousKeyValueStore: KeyValueStoreType {
  public func integer(forKey defaultName: String) -> Int {
    return Int(longLong(forKey: defaultName))
  }

  public func set(_ value: Int, forKey defaultName: String) {
    return self.set(Int64(value), forKey: defaultName)
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

  func data(forKey defaultName: String) -> Data? {
    return self.store[defaultName] as? Data
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
