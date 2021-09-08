import Apollo
@testable import KsApi
import XCTest

final class Project_FetchProjectQueryDataTests: XCTestCase {
  // TODO: Look into the `AssertNil` cases in this ticket: https://kickstarter.atlassian.net/browse/NTV-161 those are missing properties we are not correctly mapping from GQl to the V1 model or not part of the existing `ProjectQuery`

  /// `FetchProjectQueryBySlug` returns identical data.
  func testFetchProjectQueryData_Success() {
    let producer = Project.projectProducer(from: FetchProjectQueryTemplate.valid.data)
    guard let projectById = MockGraphQLClient.shared.client.data(from: producer) else {
      XCTFail()

      return
    }

    self.testProjectProperties_Success(project: projectById)
  }

  private func testProjectProperties_Success(project: Project) {
    /// Project
    XCTAssertEqual(project.name, "The Quiet")
    XCTAssertEqual(project.id, 904_702_116)
    XCTAssertNil(project.availableCardTypes)
    XCTAssertEqual(
      project.blurb,
      "A photographic book about the daily life and work on board of a Russian research vessel during the MOSAiC expedition in the Arctic."
    )
    XCTAssertNil(project.displayPrelaunch)
    XCTAssertNil(project.prelaunchActivated)
    XCTAssertEqual(project.slug, "theaschneider/thequiet")
    XCTAssertTrue(project.staffPick)
    XCTAssertEqual(project.state, .live)
    XCTAssertNil(project.video)
    XCTAssertNil(project.tags)

    /// Project URLS
    XCTAssertEqual(
      project.urls.web.project,
      "https://staging.kickstarter.com/projects/theaschneider/thequiet"
    )
    XCTAssertNil(project.urls.web.updates)

    /// Project Stats
    XCTAssertEqual(project.stats.backersCount, 147)
    XCTAssertEqual(project.stats.currency, "EUR")
    // TODO: Should be corrected XCTAssertEqual(project.stats.goal, 2000.0)
    // TODO: Should be corrected XCTAssertEqual(project.stats.pledged, 7826.6)
    // TODO: Should be corrected XCTAssertEqual(project.stats.staticUsdRate, 1.18420975)
    // TODO: Should be corrected XCTAssertEqual(project.stats.usdExchangeRate, 1.49694415)
    XCTAssertNil(project.stats.updatesCount)
    XCTAssertNil(project.stats.commentsCount)
    XCTAssertNil(project.stats.convertedPledgedAmount)
    XCTAssertNil(project.stats.currentCurrency)
    XCTAssertNil(project.stats.currentCurrencyRate)

    /// Project Location
    XCTAssertEqual(project.location.country, "DE")
    XCTAssertEqual(project.location.displayableName, "München, Germany")
    XCTAssertEqual(project.location.localizedName, "München")
    XCTAssertEqual(project.location.name, "München")
    XCTAssertEqual(project.location.id, decompose(id: "TG9jYXRpb24tNjc2NzU2"))

    /// Project Personalization
    XCTAssertNil(project.personalization.backing)
    XCTAssertTrue(project.personalization.friends!.isEmpty)
    XCTAssertFalse(project.personalization.isStarred!)
    XCTAssertFalse(project.personalization.isBacking!)

    /// Project Photo
    XCTAssertEqual(
      project.photo.size1024x768,
      "https://ksr-qa-ugc.imgix.net/assets/033/846/044/7134a6f4504bd636327de703a1d2dd1c_original.jpg?ixlib=rb-4.0.2&crop=faces&w=1024&h=576&fit=crop&v=1623348736&auto=format&frame=1&q=92&s=a7b486e4831db1bcbf393201bc64a40a"
    )
    XCTAssertEqual(
      project.photo.full,
      "https://ksr-qa-ugc.imgix.net/assets/033/846/044/7134a6f4504bd636327de703a1d2dd1c_original.jpg?ixlib=rb-4.0.2&crop=faces&w=1024&h=576&fit=crop&v=1623348736&auto=format&frame=1&q=92&s=a7b486e4831db1bcbf393201bc64a40a"
    )
    XCTAssertEqual(
      project.photo.med,
      "https://ksr-qa-ugc.imgix.net/assets/033/846/044/7134a6f4504bd636327de703a1d2dd1c_original.jpg?ixlib=rb-4.0.2&crop=faces&w=1024&h=576&fit=crop&v=1623348736&auto=format&frame=1&q=92&s=a7b486e4831db1bcbf393201bc64a40a"
    )
    XCTAssertEqual(
      project.photo.small,
      "https://ksr-qa-ugc.imgix.net/assets/033/846/044/7134a6f4504bd636327de703a1d2dd1c_original.jpg?ixlib=rb-4.0.2&crop=faces&w=1024&h=576&fit=crop&v=1623348736&auto=format&frame=1&q=92&s=a7b486e4831db1bcbf393201bc64a40a"
    )

    /// Project Category
    XCTAssertEqual(project.category.name, "Photobooks")
    XCTAssertEqual(project.category.id, decompose(id: "Q2F0ZWdvcnktMjgw"))
    XCTAssertNil(project.category.analyticsName)
    XCTAssertEqual(project.category.parentId, decompose(id: "Q2F0ZWdvcnktMTU="))
    XCTAssertEqual(project.category.parentName, "Photography")

    /// Project Country
    XCTAssertEqual(project.country, .de)

    /// Project User
    XCTAssertEqual(
      project.creator.avatar.large,
      "https://ksr-qa-ugc.imgix.net/assets/033/846/528/69cae8b2ccc2403e233b5715cb1f869f_original.png?ixlib=rb-4.0.2&blur=false&w=1024&h=1024&fit=crop&v=1623351187&auto=format&frame=1&q=92&s=d0d5f5993e64056e5ddf7e42b56e50cd"
    )
    XCTAssertEqual(
      project.creator.avatar.medium,
      "https://ksr-qa-ugc.imgix.net/assets/033/846/528/69cae8b2ccc2403e233b5715cb1f869f_original.png?ixlib=rb-4.0.2&blur=false&w=1024&h=1024&fit=crop&v=1623351187&auto=format&frame=1&q=92&s=d0d5f5993e64056e5ddf7e42b56e50cd"
    )
    XCTAssertEqual(
      project.creator.avatar.small,
      "https://ksr-qa-ugc.imgix.net/assets/033/846/528/69cae8b2ccc2403e233b5715cb1f869f_original.png?ixlib=rb-4.0.2&blur=false&w=1024&h=1024&fit=crop&v=1623351187&auto=format&frame=1&q=92&s=d0d5f5993e64056e5ddf7e42b56e50cd"
    )
    XCTAssertEqual(project.creator.id, decompose(id: "VXNlci0xNTMyMzU3OTk3"))
    XCTAssertNil(project.creator.isEmailVerified)

    // TODO: Missing user properties being returned by current v1 model (ie need to be filled in for GQL)
    XCTAssertNil(project.creator.erroredBackingsCount)
    XCTAssertNil(project.creator.facebookConnected)
    XCTAssertNil(project.creator.isAdmin)
    XCTAssertNil(project.creator.isFriend)
    XCTAssertNil(project.creator.location)
    XCTAssertNil(project.creator.needsFreshFacebookToken)
    XCTAssertNil(project.creator.newsletters.arts)
    XCTAssertNil(project.creator.newsletters.games)
    XCTAssertNil(project.creator.newsletters.happening)
    XCTAssertNil(project.creator.newsletters.invent)
    XCTAssertNil(project.creator.newsletters.promo)
    XCTAssertNil(project.creator.newsletters.weekly)
    XCTAssertNil(project.creator.newsletters.films)
    XCTAssertNil(project.creator.newsletters.publishing)
    XCTAssertNil(project.creator.newsletters.alumni)
    XCTAssertNil(project.creator.newsletters.music)
    XCTAssertNil(project.creator.notifications.backings)
    XCTAssertNil(project.creator.notifications.commentReplies)
    XCTAssertNil(project.creator.notifications.comments)
    XCTAssertNil(project.creator.notifications.creatorDigest)
    XCTAssertNil(project.creator.notifications.creatorTips)
    XCTAssertNil(project.creator.notifications.follower)
    XCTAssertNil(project.creator.notifications.friendActivity)
    XCTAssertNil(project.creator.notifications.messages)
    XCTAssertNil(project.creator.notifications.mobileBackings)
    XCTAssertNil(project.creator.notifications.mobileComments)
    XCTAssertNil(project.creator.notifications.mobileFollower)
    XCTAssertNil(project.creator.notifications.mobileFriendActivity)
    XCTAssertNil(project.creator.notifications.mobileMarketingUpdate)
    XCTAssertNil(project.creator.notifications.mobileMessages)
    XCTAssertNil(project.creator.notifications.mobilePostLikes)
    XCTAssertNil(project.creator.notifications.mobileUpdates)
    XCTAssertNil(project.creator.notifications.postLikes)
    XCTAssertNil(project.creator.notifications.updates)
    XCTAssertNil(project.creator.showPublicProfile)
    XCTAssertNil(project.creator.social)
    XCTAssertNil(project.creator.stats.backedProjectsCount)
    XCTAssertNil(project.creator.stats.createdProjectsCount)
    XCTAssertNil(project.creator.stats.draftProjectsCount)
    XCTAssertNil(project.creator.stats.memberProjectsCount)
    XCTAssertNil(project.creator.stats.starredProjectsCount)
    XCTAssertNil(project.creator.stats.unansweredSurveysCount)
    XCTAssertNil(project.creator.stats.unreadMessagesCount)
    XCTAssertNil(project.creator.unseenActivityCount)

    /// Project member data
    XCTAssertNil(project.memberData.lastUpdatePublishedAt)
    XCTAssertEqual(
      project.memberData.permissions,
      [.editProject, .editFaq, .post, .comment, .viewPledges, .fulfillment]
    )
    XCTAssertNil(project.memberData.unreadMessagesCount)
    XCTAssertNil(project.memberData.unseenActivityCount)

    /// Project dates
    XCTAssertEqual(project.dates.deadline, TimeInterval(1_628_622_000))
    XCTAssertNil(project.dates.featuredAt)
    XCTAssertNil(project.dates.finalCollectionDate)
    XCTAssertEqual(project.dates.launchedAt, TimeInterval(1_625_118_948))
    XCTAssertEqual(project.dates.stateChangedAt, TimeInterval(1_625_118_950))

    /// Project rewards data -- add ons
    XCTAssertEqual(project.addOns?.count, 3)

    guard let lastAddOn = project.addOns?.last else {
      XCTFail()

      return
    }

    XCTAssertEqual(lastAddOn.backersCount, 6)
    XCTAssertEqual(lastAddOn.convertedMinimum, 36.0)
    XCTAssertEqual(lastAddOn.description, "First edition of the book.")
    XCTAssertNil(lastAddOn.endsAt)
    XCTAssertFalse(lastAddOn.hasAddOns)
    let date: String? = "2021-11-01"
    let formattedDate = date.flatMap(DateFormatter.isoDateFormatter.date(from:))
    let timeInterval = formattedDate?.timeIntervalSince1970
    XCTAssertEqual(lastAddOn.estimatedDeliveryOn, timeInterval)

    XCTAssertEqual(lastAddOn.id, decompose(id: "UmV3YXJkLTgzNjE3Njc="))
    XCTAssertNil(lastAddOn.limit)
    XCTAssertEqual(lastAddOn.limitPerBacker, 10)
    XCTAssertEqual(lastAddOn.minimum, 24.0)
    XCTAssertNil(lastAddOn.remaining)
    XCTAssertNil(lastAddOn.startsAt)
    XCTAssertEqual(lastAddOn.title, "FIRST EDITION / ERSTAUSGABE")
    XCTAssertEqual(lastAddOn.shippingRules?.count, 2)
    XCTAssertEqual(lastAddOn.shipping.enabled, false)
    XCTAssertEqual(lastAddOn.shipping.preference!, .none)
    XCTAssertNil(lastAddOn.shippingRulesExpanded)
    XCTAssertNil(lastAddOn.shipping.location)
    XCTAssertNil(lastAddOn.shipping.summary)
    XCTAssertNil(lastAddOn.shipping.type)

    /// Project rewards data -- rewards
    XCTAssertEqual(project.rewards.count, 14)

    guard let lastReward = project.rewards.last else {
      XCTFail()

      return
    }

    XCTAssertEqual(lastReward.backersCount, 1)
    XCTAssertEqual(lastReward.convertedMinimum, 599.0)
    XCTAssertEqual(lastReward.description, "Signed first edition of the book.")
    XCTAssertNil(lastReward.endsAt)
    XCTAssertFalse(lastReward.hasAddOns)
    let date2: String? = "2021-11-01"
    let formattedDate2 = date2.flatMap(DateFormatter.isoDateFormatter.date(from:))
    let timeInterval2 = formattedDate2?.timeIntervalSince1970
    XCTAssertEqual(lastReward.estimatedDeliveryOn, timeInterval2)

    XCTAssertEqual(lastReward.id, decompose(id: "UmV3YXJkLTgzNDExODA="))
    XCTAssertEqual(lastReward.limit, 10)
    XCTAssertEqual(lastReward.limitPerBacker, 1)
    XCTAssertEqual(lastReward.minimum, 400.0)
    XCTAssertEqual(lastReward.remaining, 9)
    XCTAssertNil(lastReward.startsAt)
    XCTAssertEqual(lastReward.title, "SIGNED BOOK + GALLERY PRINT (30x45cm)")
    XCTAssertEqual(lastReward.shippingRules?.count, 4)
    XCTAssertEqual(lastReward.shippingRules?[1].cost, 15.0)
    XCTAssertEqual(lastReward.shippingRules?[1].location.country, "CH")
    XCTAssertEqual(lastReward.shippingRules?[1].location.displayableName, "Switzerland")
    XCTAssertEqual(lastReward.shippingRules?[1].location.localizedName, "Switzerland")
    XCTAssertEqual(lastReward.shippingRules?[1].location.name, "Switzerland")
    XCTAssertEqual(lastReward.shippingRules?[1].location.id, decompose(id: "TG9jYXRpb24tMjM0MjQ5NTc="))
    // TODO: Investigate in ticket above  XCTAssertFalse(lastReward.shipping.enabled)
    // TODO: Investigate in ticket above XCTAssertEqual(lastReward.shipping.preference!, .none)
    XCTAssertNil(lastReward.shippingRulesExpanded)
    XCTAssertNil(lastReward.shipping.location)
    XCTAssertNil(lastReward.shipping.summary)
    XCTAssertNil(lastReward.shipping.type)
  }
}
