@testable import KsApi
import XCTest

final class NotificationsTests: XCTestCase {
  func testJsonEncoding() {
    let json: [String: Any] = [
      "notify_of_backings": false,
      "notify_of_comments": false,
      "notify_of_follower": false,
      "notify_of_friend_activity": false,
      "notify_of_post_likes": false,
      "notify_of_updates": false,
      "notify_mobile_of_backings": false,
      "notify_mobile_of_comments": false,
      "notify_mobile_of_follower": false,
      "notify_mobile_of_friend_activity": false,
      "notify_mobile_of_post_likes": false,
      "notify_mobile_of_updates": false
    ]

    let notification: User.Notifications = try! User.Notifications.decodeJSONDictionary(json)

    XCTAssertNotNil(notification)
    XCTAssertEqual(notification.encode() as NSDictionary?, json as NSDictionary?)

    XCTAssertEqual(false, notification.backings)
    XCTAssertEqual(false, notification.comments)
    XCTAssertEqual(false, notification.follower)
    XCTAssertEqual(false, notification.friendActivity)
    XCTAssertEqual(false, notification.postLikes)
    XCTAssertEqual(false, notification.updates)
    XCTAssertEqual(false, notification.mobileBackings)
    XCTAssertEqual(false, notification.mobileComments)
    XCTAssertEqual(false, notification.mobileFollower)
    XCTAssertEqual(false, notification.mobileFriendActivity)
    XCTAssertEqual(false, notification.mobilePostLikes)
    XCTAssertEqual(false, notification.mobileUpdates)
  }

  func testJsonEncoding_TrueValues() {
    let json: [String: Any] = [
      "notify_of_backings": true,
      "notify_of_comments": true,
      "notify_of_follower": true,
      "notify_of_friend_activity": true,
      "notify_of_post_likes": true,
      "notify_of_updates": true,
      "notify_mobile_of_backings": true,
      "notify_mobile_of_comments": true,
      "notify_mobile_of_follower": true,
      "notify_mobile_of_friend_activity": true,
      "notify_mobile_of_post_likes": true,
      "notify_mobile_of_updates": true
    ]

    let notification: User.Notifications = try! User.Notifications.decodeJSONDictionary(json)

    XCTAssertNotNil(notification)
    XCTAssertEqual(notification.encode() as NSDictionary?, json as NSDictionary?)

    XCTAssertEqual(true, notification.backings)
    XCTAssertEqual(true, notification.comments)
    XCTAssertEqual(true, notification.follower)
    XCTAssertEqual(true, notification.friendActivity)
    XCTAssertEqual(true, notification.postLikes)
    XCTAssertEqual(true, notification.updates)
    XCTAssertEqual(true, notification.mobileBackings)
    XCTAssertEqual(true, notification.mobileComments)
    XCTAssertEqual(true, notification.mobileFollower)
    XCTAssertEqual(true, notification.mobileFriendActivity)
    XCTAssertEqual(true, notification.mobilePostLikes)
    XCTAssertEqual(true, notification.mobileUpdates)
  }

  func testJsonDecoding() {
    let json: User.Notifications = try! User.Notifications.decodeJSONDictionary([
      "notify_of_backings": true,
      "notify_of_comments": false,
      "notify_of_follower": true,
      "notify_of_friend_activity": false,
      "notify_of_post_likes": true,
      "notify_of_updates": false,
      "notify_mobile_of_backings": true,
      "notify_mobile_of_comments": false,
      "notify_mobile_of_follower": true,
      "notify_mobile_of_friend_activity": false,
      "notify_mobile_of_post_likes": true,
      "notify_mobile_of_updates": false
    ])

    let notifications = json

    XCTAssertEqual(
      notifications,
      try! User.Notifications.decodeJSONDictionary(notifications.encode())
    )
  }
}
