import XCTest
@testable import Library

public final class RefTagTests: XCTestCase {

  func testStringTag() {
    XCTAssertEqual("activity", RefTag.activity.stringTag)
    XCTAssertEqual("discovery_activity_sample", RefTag.activitySample.stringTag)
    XCTAssertEqual("category", RefTag.category.stringTag)
    XCTAssertEqual("category_featured", RefTag.categoryFeatured.stringTag)
    XCTAssertEqual("city", RefTag.city.stringTag)
    XCTAssertEqual("discovery", RefTag.discovery.stringTag)
    XCTAssertEqual("discovery_potd", RefTag.discoveryPotd.stringTag)
    XCTAssertEqual("recommended", RefTag.recommended.stringTag)
    XCTAssertEqual("search", RefTag.search.stringTag)
    XCTAssertEqual("social", RefTag.social.stringTag)
    XCTAssertEqual("thanks", RefTag.thanks.stringTag)
    XCTAssertEqual("users", RefTag.users.stringTag)

    XCTAssertEqual("category_ending_soon", RefTag.categoryWithSort(.EndingSoon).stringTag)
    XCTAssertEqual("category", RefTag.categoryWithSort(.Magic).stringTag)
    XCTAssertEqual("category_most_funded", RefTag.categoryWithSort(.MostFunded).stringTag)
    XCTAssertEqual("category_newest", RefTag.categoryWithSort(.Newest).stringTag)
    XCTAssertEqual("category_popular", RefTag.categoryWithSort(.Popular).stringTag)

    XCTAssertEqual("recommended_ending_soon", RefTag.recommendedWithSort(.EndingSoon).stringTag)
    XCTAssertEqual("recommended", RefTag.recommendedWithSort(.Magic).stringTag)
    XCTAssertEqual("recommended_most_funded", RefTag.recommendedWithSort(.MostFunded).stringTag)
    XCTAssertEqual("recommended_newest", RefTag.recommendedWithSort(.Newest).stringTag)
    XCTAssertEqual("recommended_popular", RefTag.recommendedWithSort(.Popular).stringTag)
  }

  func testEquatable() {
    XCTAssertEqual(RefTag.activity, RefTag.activity)
    XCTAssertEqual(RefTag.activitySample, RefTag.activitySample)
    XCTAssertEqual(RefTag.category, RefTag.category)
    XCTAssertEqual(RefTag.categoryFeatured, RefTag.categoryFeatured)
    XCTAssertEqual(RefTag.city, RefTag.city)
    XCTAssertEqual(RefTag.discovery, RefTag.discovery)
    XCTAssertEqual(RefTag.discoveryPotd, RefTag.discoveryPotd)
    XCTAssertEqual(RefTag.recommended, RefTag.recommended)
    XCTAssertEqual(RefTag.search, RefTag.search)
    XCTAssertEqual(RefTag.social, RefTag.social)
    XCTAssertEqual(RefTag.thanks, RefTag.thanks)
    XCTAssertEqual(RefTag.users, RefTag.users)

    XCTAssertEqual(RefTag.categoryWithSort(.Magic), RefTag.categoryWithSort(.Magic))
    XCTAssertNotEqual(RefTag.categoryWithSort(.Magic), RefTag.categoryWithSort(.Popular))

    XCTAssertEqual(RefTag.recommendedWithSort(.Magic), RefTag.recommendedWithSort(.Magic))
    XCTAssertNotEqual(RefTag.recommendedWithSort(.Magic), RefTag.recommendedWithSort(.Popular))
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

    XCTAssertEqual(RefTag.categoryWithSort(.EndingSoon),
                   RefTag(code: RefTag.categoryWithSort(.EndingSoon).stringTag))
    XCTAssertEqual(RefTag.category, RefTag(code: RefTag.categoryWithSort(.Magic).stringTag))
    XCTAssertEqual(RefTag.categoryWithSort(.MostFunded),
                   RefTag(code: RefTag.categoryWithSort(.MostFunded).stringTag))
    XCTAssertEqual(RefTag.categoryWithSort(.Newest),
                   RefTag(code: RefTag.categoryWithSort(.Newest).stringTag))
    XCTAssertEqual(RefTag.categoryWithSort(.Popular),
                   RefTag(code: RefTag.categoryWithSort(.Popular).stringTag))

    XCTAssertEqual(RefTag.city, RefTag(code: RefTag.city.stringTag))
    XCTAssertEqual(RefTag.discovery, RefTag(code: RefTag.discovery.stringTag))
    XCTAssertEqual(RefTag.discoveryPotd, RefTag(code: RefTag.discoveryPotd.stringTag))
    XCTAssertEqual(RefTag.recommended, RefTag(code: RefTag.recommended.stringTag))

    XCTAssertEqual(RefTag.recommended, RefTag(code: RefTag.recommendedWithSort(.Magic).stringTag))
    XCTAssertEqual(RefTag.recommendedWithSort(.EndingSoon),
                   RefTag(code: RefTag.recommendedWithSort(.EndingSoon).stringTag))
    XCTAssertEqual(RefTag.recommendedWithSort(.MostFunded),
                   RefTag(code: RefTag.recommendedWithSort(.MostFunded).stringTag))
    XCTAssertEqual(RefTag.recommendedWithSort(.Newest),
                   RefTag(code: RefTag.recommendedWithSort(.Newest).stringTag))
    XCTAssertEqual(RefTag.recommendedWithSort(.Popular),
                   RefTag(code: RefTag.recommendedWithSort(.Popular).stringTag))

    XCTAssertEqual(RefTag.search, RefTag(code: RefTag.search.stringTag))
    XCTAssertEqual(RefTag.social, RefTag(code: RefTag.social.stringTag))
    XCTAssertEqual(RefTag.thanks, RefTag(code: RefTag.thanks.stringTag))
    XCTAssertEqual(RefTag.users, RefTag(code: RefTag.users.stringTag))
    XCTAssertEqual(RefTag.unrecognized("custom"), RefTag(code: RefTag.unrecognized("custom").stringTag))
  }
}
