@testable import KsApi
@testable import Library
import Prelude
import XCTest

final class KSRAnalyticsIdentityDataTests: XCTestCase {
  func testInitialization() {
    let user = User.template
      |> User.lens.name .~ "Test User"
      |> User.lens.notifications.mobileBackings .~ false
      |> User.lens.notifications.messages .~ true

    let data = KSRAnalyticsIdentityData(user)

    XCTAssertEqual(data.userId, 1)
    XCTAssertEqual(data.uniqueTraits(comparedTo: nil)["name"] as? String, "Test User")
    XCTAssertEqual(data.uniqueTraits(comparedTo: nil)["notify_mobile_of_backings"] as? Bool, false)
    XCTAssertEqual(data.uniqueTraits(comparedTo: nil)["notify_of_messages"] as? Bool, true)
  }

  func testUniqueTraits() {
    let user1 = User.template
      |> User.lens.name .~ "Test User 1"
      |> User.lens.notifications.mobileBackings .~ false
      |> User.lens.notifications.messages .~ true

    let user2 = User.template
      |> User.lens.name .~ "Test User 2"
      |> User.lens.notifications.mobileBackings .~ false
      |> User.lens.notifications.messages .~ true
      |> User.lens.notifications.friendActivity .~ true

    let data1 = KSRAnalyticsIdentityData(user1)
    let data2 = KSRAnalyticsIdentityData(user2)

    let uniqueTraits = data2.uniqueTraits(comparedTo: data1)

    XCTAssertEqual(uniqueTraits.keys.count, 2)

    XCTAssertEqual(uniqueTraits["name"] as? String, "Test User 2")
    XCTAssertEqual(uniqueTraits["notify_of_friend_activity"] as? Bool, true)
  }

  func testEquality() {
    let user1 = User.template
      |> User.lens.name .~ "Test User 1"
      |> User.lens.notifications.mobileBackings .~ false
      |> User.lens.notifications.messages .~ true

    let user2 = User.template
      |> User.lens.name .~ "Test User 1"
      |> User.lens.notifications.mobileBackings .~ false
      |> User.lens.notifications.messages .~ true

    XCTAssertEqual(KSRAnalyticsIdentityData(user1), KSRAnalyticsIdentityData(user2))

    let user3 = User.template
      |> User.lens.name .~ "Test User 2"
      |> User.lens.notifications.mobileBackings .~ false
      |> User.lens.notifications.messages .~ true

    let user4 = User.template
      |> User.lens.name .~ "Test User 3"
      |> User.lens.notifications.mobileBackings .~ true
      |> User.lens.notifications.messages .~ true

    XCTAssertNotEqual(KSRAnalyticsIdentityData(user3), KSRAnalyticsIdentityData(user4))

    let user5 = User.template
      |> User.lens.id .~ 1

    let user6 = User.template
      |> User.lens.id .~ 2

    XCTAssertNotEqual(KSRAnalyticsIdentityData(user5), KSRAnalyticsIdentityData(user6))
  }

  func testAllTraits() {
    let user = User.template

    let data = KSRAnalyticsIdentityData(user)

    let traits = data.allTraits

    XCTAssertEqual(traits["name"] as? String, user.name)

    let notifications = user.notifications.encode()

    for (key, _) in notifications {
      XCTAssertEqual(notifications[key] as? Bool, traits[key] as? Bool)
    }
  }

  func testEncodingDecoding() {
    let data1 = KSRAnalyticsIdentityData(.template)

    guard let encoded = try? JSONEncoder().encode(data1) else {
      XCTFail("Failed to encode")
      return
    }

    let decoded = try? JSONDecoder().decode(KSRAnalyticsIdentityData.self, from: encoded)

    XCTAssertEqual(decoded, data1)
  }
}
