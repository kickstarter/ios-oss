@testable import KsApi
@testable import Library
import Prelude
import XCTest

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
    XCTAssertEqual("ksr_email_backer_failed_transaction", RefTag.emailBackerFailedTransaction.stringTag)
    XCTAssertEqual("profile_backed", RefTag.profileBacked.stringTag)
    XCTAssertEqual("project_page", RefTag.projectPage.stringTag)
    XCTAssertEqual("push", RefTag.push.stringTag)
    XCTAssertEqual("recommended", RefTag.recommended.stringTag)
    XCTAssertEqual("search", RefTag.search.stringTag)
    XCTAssertEqual("social", RefTag.social.stringTag)
    XCTAssertEqual("thanks", RefTag.thanks.stringTag)
    XCTAssertEqual("category_ending_soon", RefTag.categoryWithSort(.endingSoon).stringTag)
    XCTAssertEqual("category_home", RefTag.categoryWithSort(.magic).stringTag)
    XCTAssertEqual("category_newest", RefTag.categoryWithSort(.newest).stringTag)
    XCTAssertEqual("category_popular", RefTag.categoryWithSort(.popular).stringTag)
    XCTAssertEqual("recommended_ending_soon", RefTag.recommendedWithSort(.endingSoon).stringTag)
    XCTAssertEqual("recommended_home", RefTag.recommendedWithSort(.magic).stringTag)
    XCTAssertEqual("recommended_newest", RefTag.recommendedWithSort(.newest).stringTag)
    XCTAssertEqual("recommended_popular", RefTag.recommendedWithSort(.popular).stringTag)
    XCTAssertEqual("update", RefTag.update.stringTag)
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
    XCTAssertEqual(RefTag.messageThread, RefTag.messageThread)
    XCTAssertEqual(RefTag.profileBacked, RefTag.profileBacked)
    XCTAssertEqual(RefTag.projectPage, RefTag.projectPage)
    XCTAssertEqual(RefTag.push, RefTag.push)
    XCTAssertEqual(RefTag.recommended, RefTag.recommended)
    XCTAssertEqual(RefTag.search, RefTag.search)
    XCTAssertEqual(RefTag.social, RefTag.social)
    XCTAssertEqual(RefTag.thanks, RefTag.thanks)

    XCTAssertEqual(RefTag.categoryWithSort(.magic), RefTag.categoryWithSort(.magic))
    XCTAssertNotEqual(RefTag.categoryWithSort(.magic), RefTag.categoryWithSort(.popular))

    XCTAssertEqual(RefTag.discoveryWithSort(.magic), RefTag.discoveryWithSort(.magic))
    XCTAssertNotEqual(RefTag.discoveryWithSort(.magic), RefTag.discoveryWithSort(.popular))

    XCTAssertEqual(RefTag.recommendedWithSort(.magic), RefTag.recommendedWithSort(.magic))
    XCTAssertNotEqual(RefTag.recommendedWithSort(.magic), RefTag.recommendedWithSort(.popular))

    XCTAssertEqual(RefTag.recsWithSort(.magic), RefTag.recsWithSort(.magic))
    XCTAssertNotEqual(RefTag.recsWithSort(.magic), RefTag.recsWithSort(.popular))

    XCTAssertEqual(RefTag.socialWithSort(.magic), RefTag.socialWithSort(.magic))
    XCTAssertNotEqual(RefTag.socialWithSort(.magic), RefTag.socialWithSort(.popular))

    XCTAssertEqual(RefTag.starredWithSort(.magic), RefTag.starredWithSort(.magic))
    XCTAssertNotEqual(RefTag.starredWithSort(.magic), RefTag.starredWithSort(.popular))
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

    XCTAssertEqual(
      RefTag.categoryWithSort(.endingSoon),
      RefTag(code: RefTag.categoryWithSort(.endingSoon).stringTag)
    )
    XCTAssertEqual(RefTag.categoryWithSort(.magic), RefTag(code: RefTag.categoryWithSort(.magic).stringTag))

    XCTAssertEqual(
      RefTag.categoryWithSort(.newest),
      RefTag(code: RefTag.categoryWithSort(.newest).stringTag)
    )
    XCTAssertEqual(
      RefTag.categoryWithSort(.popular),
      RefTag(code: RefTag.categoryWithSort(.popular).stringTag)
    )

    XCTAssertEqual(RefTag.city, RefTag(code: RefTag.city.stringTag))
    XCTAssertEqual(RefTag.dashboard, RefTag(code: RefTag.dashboard.stringTag))
    XCTAssertEqual(RefTag.dashboardActivity, RefTag(code: RefTag.dashboardActivity.stringTag))

    XCTAssertEqual(RefTag.discovery, RefTag(code: RefTag.discovery.stringTag))
    XCTAssertEqual(
      RefTag.discoveryWithSort(.endingSoon),
      RefTag(code: RefTag.discoveryWithSort(.endingSoon).stringTag)
    )
    XCTAssertEqual(RefTag.discoveryWithSort(.magic), RefTag(code: RefTag.discoveryWithSort(.magic).stringTag))

    XCTAssertEqual(
      RefTag.discoveryWithSort(.newest),
      RefTag(code: RefTag.discoveryWithSort(.newest).stringTag)
    )
    XCTAssertEqual(
      RefTag.discoveryWithSort(.popular),
      RefTag(code: RefTag.discoveryWithSort(.popular).stringTag)
    )

    XCTAssertEqual(
      RefTag.emailBackerFailedTransaction,
      RefTag(code: "ksr_email_backer_failed_transaction")
    )

    XCTAssertEqual(RefTag.messageThread, RefTag(code: RefTag.messageThread.stringTag))
    XCTAssertEqual(RefTag.messageThread, RefTag(code: RefTag.messageThread.stringTag))
    XCTAssertEqual(RefTag.profileBacked, RefTag(code: RefTag.profileBacked.stringTag))
    XCTAssertEqual(RefTag.projectPage, RefTag(code: RefTag.projectPage.stringTag))
    XCTAssertEqual(RefTag.push, RefTag(code: RefTag.push.stringTag))
    XCTAssertEqual(RefTag.recommended, RefTag(code: RefTag.recommended.stringTag))

    XCTAssertEqual(
      RefTag.recommendedWithSort(.magic),
      RefTag(code: RefTag.recommendedWithSort(.magic).stringTag)
    )
    XCTAssertEqual(
      RefTag.recommendedWithSort(.endingSoon),
      RefTag(code: RefTag.recommendedWithSort(.endingSoon).stringTag)
    )
    XCTAssertEqual(
      RefTag.recommendedWithSort(.newest),
      RefTag(code: RefTag.recommendedWithSort(.newest).stringTag)
    )
    XCTAssertEqual(
      RefTag.recommendedWithSort(.popular),
      RefTag(code: RefTag.recommendedWithSort(.popular).stringTag)
    )

    XCTAssertEqual(RefTag.recsWithSort(.endingSoon), RefTag(code: RefTag.recsWithSort(.endingSoon).stringTag))
    XCTAssertEqual(RefTag.recsWithSort(.magic), RefTag(code: RefTag.recsWithSort(.magic).stringTag))
    XCTAssertEqual(RefTag.recsWithSort(.newest), RefTag(code: RefTag.recsWithSort(.newest).stringTag))
    XCTAssertEqual(RefTag.recsWithSort(.popular), RefTag(code: RefTag.recsWithSort(.popular).stringTag))

    XCTAssertEqual(RefTag.search, RefTag(code: RefTag.search.stringTag))

    XCTAssertEqual(RefTag.social, RefTag(code: RefTag.social.stringTag))
    XCTAssertEqual(
      RefTag.socialWithSort(.endingSoon),
      RefTag(code: RefTag.socialWithSort(.endingSoon).stringTag)
    )
    XCTAssertEqual(RefTag.socialWithSort(.magic), RefTag(code: RefTag.socialWithSort(.magic).stringTag))

    XCTAssertEqual(RefTag.socialWithSort(.newest), RefTag(code: RefTag.socialWithSort(.newest).stringTag))
    XCTAssertEqual(RefTag.socialWithSort(.popular), RefTag(code: RefTag.socialWithSort(.popular).stringTag))

    XCTAssertEqual(
      RefTag.starredWithSort(.endingSoon),
      RefTag(code: RefTag.starredWithSort(.endingSoon).stringTag)
    )
    XCTAssertEqual(
      RefTag.starredWithSort(.magic),
      RefTag(code: RefTag.starredWithSort(.magic).stringTag)
    )
    XCTAssertEqual(RefTag.starredWithSort(.newest), RefTag(code: RefTag.starredWithSort(.newest).stringTag))
    XCTAssertEqual(RefTag.starredWithSort(.popular), RefTag(code: RefTag.starredWithSort(.popular).stringTag))

    XCTAssertEqual(RefTag.thanks, RefTag(code: RefTag.thanks.stringTag))
    XCTAssertEqual(RefTag.update, RefTag(code: RefTag.update.stringTag))
    XCTAssertEqual(RefTag.unrecognized("custom"), RefTag(code: RefTag.unrecognized("custom").stringTag))
  }

  func testRefTagFromDiscoveryParams() {
    let discoSort = DiscoveryParams.defaults
      |> DiscoveryParams.lens.sort .~ .endingSoon
    let discoCategory = DiscoveryParams.defaults
      |> DiscoveryParams.lens.sort .~ .endingSoon
      |> DiscoveryParams.lens.category .~ Category.documentary
    let discoRecommended = DiscoveryParams.defaults
      |> DiscoveryParams.lens.recommended .~ true
    let discoPWL = DiscoveryParams.defaults
      |> DiscoveryParams.lens.staffPicks .~ true
    let discoSocial = DiscoveryParams.defaults
      |> DiscoveryParams.lens.social .~ true
    let discoStarred = DiscoveryParams.defaults
      |> DiscoveryParams.lens.starred .~ true
    let discoCollection = DiscoveryParams.defaults
      |> DiscoveryParams.lens.tagId .~ .lightsOn

    XCTAssertEqual("discovery_ending_soon", RefTag.fromParams(discoSort).stringTag)
    XCTAssertEqual("category_ending_soon", RefTag.fromParams(discoCategory).stringTag)
    XCTAssertEqual("recs_home", RefTag.fromParams(discoRecommended).stringTag)
    XCTAssertEqual("recommended_home", RefTag.fromParams(discoPWL).stringTag)
    XCTAssertEqual("social_home", RefTag.fromParams(discoSocial).stringTag)
    XCTAssertEqual("starred_home", RefTag.fromParams(discoStarred).stringTag)
    XCTAssertEqual("ios_project_collection_tag_557", RefTag.fromParams(discoCollection).stringTag)
  }
}
