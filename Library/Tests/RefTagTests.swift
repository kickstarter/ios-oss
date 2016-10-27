import XCTest
@testable import Library

public final class RefTagTests: XCTestCase {

  func testStringTag() {
    XCTAssertEqual("activity", RefTag.activity.stringTag)
    XCTAssertEqual("discovery_activity_sample", RefTag.activitySample.stringTag)
    XCTAssertEqual("category", RefTag.category.stringTag)
    XCTAssertEqual("category_featured", RefTag.categoryFeatured.stringTag)
    XCTAssertEqual("city", RefTag.city.stringTag)
    XCTAssertEqual("dashboard", RefTag.dashboard.stringTag)
    XCTAssertEqual("dashboard_activity", RefTag.dashboardActivity.stringTag)
    XCTAssertEqual("discovery", RefTag.discovery.stringTag)
    XCTAssertEqual("discovery_potd", RefTag.discoveryPotd.stringTag)
    XCTAssertEqual("message_thread", RefTag.messageThread.stringTag)
    XCTAssertEqual("profile_backed", RefTag.profileBacked.stringTag)
    XCTAssertEqual("push", RefTag.push.stringTag)
    XCTAssertEqual("recommended", RefTag.recommended.stringTag)
    XCTAssertEqual("search", RefTag.search.stringTag)
    XCTAssertEqual("social", RefTag.social.stringTag)
    XCTAssertEqual("thanks", RefTag.thanks.stringTag)

    XCTAssertEqual("category_ending_soon", RefTag.categoryWithSort(.endingSoon).stringTag)
    XCTAssertEqual("category", RefTag.categoryWithSort(.magic).stringTag)
    XCTAssertEqual("category_most_funded", RefTag.categoryWithSort(.mostFunded).stringTag)
    XCTAssertEqual("category_newest", RefTag.categoryWithSort(.newest).stringTag)
    XCTAssertEqual("category_popular", RefTag.categoryWithSort(.popular).stringTag)

    XCTAssertEqual("recommended_ending_soon", RefTag.recommendedWithSort(.endingSoon).stringTag)
    XCTAssertEqual("recommended", RefTag.recommendedWithSort(.magic).stringTag)
    XCTAssertEqual("recommended_most_funded", RefTag.recommendedWithSort(.mostFunded).stringTag)
    XCTAssertEqual("recommended_newest", RefTag.recommendedWithSort(.newest).stringTag)
    XCTAssertEqual("recommended_popular", RefTag.recommendedWithSort(.popular).stringTag)
  }

  func testEquatable() {
    XCTAssertEqual(RefTag.activity, RefTag.activity)
    XCTAssertEqual(RefTag.activitySample, RefTag.activitySample)
    XCTAssertEqual(RefTag.category, RefTag.category)
    XCTAssertEqual(RefTag.categoryFeatured, RefTag.categoryFeatured)
    XCTAssertEqual(RefTag.city, RefTag.city)
    XCTAssertEqual(RefTag.dashboard, RefTag.dashboard)
    XCTAssertEqual(RefTag.dashboardActivity, RefTag.dashboardActivity)
    XCTAssertEqual(RefTag.discovery, RefTag.discovery)
    XCTAssertEqual(RefTag.discoveryPotd, RefTag.discoveryPotd)
    XCTAssertEqual(RefTag.messageThread, RefTag.messageThread)
    XCTAssertEqual(RefTag.profileBacked, RefTag.profileBacked)
    XCTAssertEqual(RefTag.push, RefTag.push)
    XCTAssertEqual(RefTag.recommended, RefTag.recommended)
    XCTAssertEqual(RefTag.search, RefTag.search)
    XCTAssertEqual(RefTag.social, RefTag.social)
    XCTAssertEqual(RefTag.thanks, RefTag.thanks)

    XCTAssertEqual(RefTag.categoryWithSort(.magic), RefTag.categoryWithSort(.magic))
    XCTAssertNotEqual(RefTag.categoryWithSort(.magic), RefTag.categoryWithSort(.popular))

    XCTAssertEqual(RefTag.recommendedWithSort(.magic), RefTag.recommendedWithSort(.magic))
    XCTAssertNotEqual(RefTag.recommendedWithSort(.magic), RefTag.recommendedWithSort(.popular))
  }

  func testCustomStringConvertible() {
    XCTAssertEqual("category", RefTag.category.description)
  }

  func testHashable() {
    XCTAssertEqual("category".hashValue, RefTag.category.hashValue)
  }

  func testInit() {
    XCTAssertEqual(RefTag.activity, RefTag(code: RefTag.activity.stringTag))

    XCTAssertEqual(RefTag.activity, RefTag(code: RefTag.activity.stringTag))
    XCTAssertEqual(RefTag.category, RefTag(code: RefTag.category.stringTag))
    XCTAssertEqual(RefTag.categoryFeatured, RefTag(code: RefTag.categoryFeatured.stringTag))
    XCTAssertEqual(RefTag.activitySample, RefTag(code: RefTag.activitySample.stringTag))

    XCTAssertEqual(RefTag.categoryWithSort(.endingSoon),
                   RefTag(code: RefTag.categoryWithSort(.endingSoon).stringTag))
    XCTAssertEqual(RefTag.category, RefTag(code: RefTag.categoryWithSort(.magic).stringTag))
    XCTAssertEqual(RefTag.categoryWithSort(.mostFunded),
                   RefTag(code: RefTag.categoryWithSort(.mostFunded).stringTag))
    XCTAssertEqual(RefTag.categoryWithSort(.newest),
                   RefTag(code: RefTag.categoryWithSort(.newest).stringTag))
    XCTAssertEqual(RefTag.categoryWithSort(.popular),
                   RefTag(code: RefTag.categoryWithSort(.popular).stringTag))

    XCTAssertEqual(RefTag.city, RefTag(code: RefTag.city.stringTag))
    XCTAssertEqual(RefTag.dashboard, RefTag(code: RefTag.dashboard.stringTag))
    XCTAssertEqual(RefTag.dashboardActivity, RefTag(code: RefTag.dashboardActivity.stringTag))
    XCTAssertEqual(RefTag.discovery, RefTag(code: RefTag.discovery.stringTag))
    XCTAssertEqual(RefTag.discoveryPotd, RefTag(code: RefTag.discoveryPotd.stringTag))
    XCTAssertEqual(RefTag.messageThread, RefTag(code: RefTag.messageThread.stringTag))
    XCTAssertEqual(RefTag.profileBacked, RefTag(code: RefTag.profileBacked.stringTag))
    XCTAssertEqual(RefTag.push, RefTag(code: RefTag.push.stringTag))
    XCTAssertEqual(RefTag.recommended, RefTag(code: RefTag.recommended.stringTag))

    XCTAssertEqual(RefTag.recommended, RefTag(code: RefTag.recommendedWithSort(.magic).stringTag))
    XCTAssertEqual(RefTag.recommendedWithSort(.endingSoon),
                   RefTag(code: RefTag.recommendedWithSort(.endingSoon).stringTag))
    XCTAssertEqual(RefTag.recommendedWithSort(.mostFunded),
                   RefTag(code: RefTag.recommendedWithSort(.mostFunded).stringTag))
    XCTAssertEqual(RefTag.recommendedWithSort(.newest),
                   RefTag(code: RefTag.recommendedWithSort(.newest).stringTag))
    XCTAssertEqual(RefTag.recommendedWithSort(.popular),
                   RefTag(code: RefTag.recommendedWithSort(.popular).stringTag))

    XCTAssertEqual(RefTag.search, RefTag(code: RefTag.search.stringTag))
    XCTAssertEqual(RefTag.social, RefTag(code: RefTag.social.stringTag))
    XCTAssertEqual(RefTag.thanks, RefTag(code: RefTag.thanks.stringTag))
    XCTAssertEqual(RefTag.unrecognized("custom"), RefTag(code: RefTag.unrecognized("custom").stringTag))
  }
}
