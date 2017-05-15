import Foundation

public final class KSCache {
  private let cache = NSCache<NSString, AnyObject>()

  public static let ksr_activityFriendsFollowing = "activity_friend_follow_view_model"
  public static let ksr_discoveryFiltersCategories = "discovery_filters_view_model_categories"
  public static let ksr_findFriendsFollowing = "find_friends_follow_view_model"
  public static let ksr_messageThreadHasUnreadMessages = "message_thread_has_unread_messages"

  public init() {
  }

  public subscript(key: String) -> Any? {
    get {
      return self.cache.object(forKey: key as NSString)
    }
    set {
      if let newValue = newValue {
        self.cache.setObject(newValue as AnyObject, forKey: key as NSString)
      } else {
        self.cache.removeObject(forKey: key as NSString)
      }
    }
  }

  public func removeAllObjects() {
    self.cache.removeAllObjects()
  }
}
