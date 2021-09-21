import Apollo
@testable import KsApi
import ReactiveSwift
import XCTest

final class Project_FetchProjectQueryDataTests: XCTestCase {
  /// `FetchProjectQueryBySlug` returns identical data.
  func testFetchProjectQueryData_Success() {
    let producer = Project.projectProducer(from: FetchProjectQueryTemplate.valid.data)

    let projectProducer = producer
      .switchMap { projectPamphletData -> SignalProducer<Project, ErrorEnvelope> in
        SignalProducer(value: projectPamphletData.project)
      }

    let backingIdProducer = producer
      .switchMap { projectPamphletData -> SignalProducer<Int?, ErrorEnvelope> in
        SignalProducer(value: projectPamphletData.backingId)
      }

    guard let projectDataById = MockGraphQLClient.shared.client.data(from: projectProducer),
      let backingId = MockGraphQLClient.shared.client.data(from: backingIdProducer) else {
      XCTFail()

      return
    }

    self.testProjectProperties_Success(project: projectDataById)
    XCTAssertEqual(backingId, decompose(id: "QmFja2luZy0xNDgwMTQwMzQ="))
  }

  private func testProjectProperties_Success(project: Project) {
    /// Project
    XCTAssertEqual(project.name, "The Quiet")
    XCTAssertEqual(project.id, 904_702_116)
    XCTAssertEqual(project.availableCardTypes, ["VISA", "AMEX", "MASTERCARD"])
    XCTAssertEqual(
      project.blurb,
      "A photographic book about the daily life and work on board of a Russian research vessel during the MOSAiC expedition in the Arctic."
    )
    XCTAssertFalse(project.displayPrelaunch!)
    XCTAssertTrue(project.prelaunchActivated!)
    XCTAssertEqual(project.slug, "thequiet")
    XCTAssertTrue(project.staffPick)
    XCTAssertEqual(project.state, .live)
    XCTAssertEqual(
      project.video?.high,
      "https://v.kickstarter.com/1631480664_a23b86f39dcfa7b0009309fa0f668ceb5e13b8a8/projects/4196183/video-1116448-h264_high.mp4"
    )
    XCTAssertEqual(
      project.video?.hls,
      "https://v.kickstarter.com/1631480664_a23b86f39dcfa7b0009309fa0f668ceb5e13b8a8/projects/4196183/video-1116448-hls_playlist.m3u8"
    )
    XCTAssertEqual(project.video?.id, decompose(id: "VmlkZW8tMTExNjQ0OA=="))
    XCTAssertTrue(project.tags!.isEmpty)

    /// Project URLS
    XCTAssertEqual(
      project.urls.web.project,
      "https://staging.kickstarter.com/projects/theaschneider/thequiet"
    )
    XCTAssertEqual(
      project.urls.web.updates,
      "https://staging.kickstarter.com/projects/theaschneider/thequiet/posts"
    )

    /// Project Statshttps://staging.kickstarter.com/projects/theaschneider/thequiet/posts
    XCTAssertEqual(project.stats.backersCount, 148)
    XCTAssertEqual(project.stats.currency, "EUR")
    XCTAssertEqual(project.stats.goal, 2_000)
    XCTAssertEqual(project.stats.pledged, 7_827)
    XCTAssertEqual(project.stats.staticUsdRate, 1.18302594)
    XCTAssertEqual(project.stats.usdExchangeRate, 1.18302594)
    XCTAssertEqual(project.stats.updatesCount, 5)
    XCTAssertEqual(project.stats.commentsCount, 0)
    XCTAssertEqual(project.stats.convertedPledgedAmount, 11_706.016586616)
    XCTAssertEqual(project.stats.currentCurrency, "CAD")
    XCTAssertEqual(project.stats.currentCurrencyRate, 1.49547966)

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
    XCTAssertEqual(project.category.analyticsName, "Photobooks")
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
    XCTAssertEqual(project.creator.erroredBackingsCount, 1)
    XCTAssertEqual(project.creator.id, decompose(id: "VXNlci0xNTMyMzU3OTk3"))
    XCTAssertTrue(project.creator.isEmailVerified!)
    XCTAssertFalse(project.creator.facebookConnected!)
    XCTAssertTrue(project.creator.isFriend!)
    XCTAssertTrue(project.creator.isAdmin!)
    XCTAssertEqual(project.creator.location?.country, "US")
    XCTAssertEqual(project.creator.location?.displayableName, "Las Vegas, NV")
    XCTAssertEqual(project.creator.location?.id, decompose(id: "TG9jYXRpb24tMjQzNjcwNA=="))
    XCTAssertEqual(project.creator.location?.name, "Las Vegas")
    XCTAssertEqual(project.creator.location?.localizedName, "Las Vegas")
    XCTAssertTrue(project.creator.needsFreshFacebookToken!)
    XCTAssertTrue(project.creator.showPublicProfile!)

    XCTAssertTrue(project.creator.newsletters.arts!)
    XCTAssertFalse(project.creator.newsletters.films!)
    XCTAssertFalse(project.creator.newsletters.games!)
    XCTAssertFalse(project.creator.newsletters.happening!)
    XCTAssertFalse(project.creator.newsletters.invent!)
    XCTAssertFalse(project.creator.newsletters.promo!)
    XCTAssertFalse(project.creator.newsletters.weekly!)
    XCTAssertFalse(project.creator.newsletters.publishing!)
    XCTAssertTrue(project.creator.newsletters.alumni!)
    XCTAssertFalse(project.creator.newsletters.music!)
    XCTAssertFalse(project.creator.notifications.backings!)
    XCTAssertTrue(project.creator.notifications.commentReplies!)
    XCTAssertTrue(project.creator.notifications.comments!)
    XCTAssertTrue(project.creator.notifications.creatorDigest!)
    XCTAssertTrue(project.creator.notifications.creatorTips!)
    XCTAssertTrue(project.creator.notifications.follower!)
    XCTAssertTrue(project.creator.notifications.friendActivity!)
    XCTAssertTrue(project.creator.notifications.messages!)
    XCTAssertTrue(project.creator.notifications.mobileBackings!)
    XCTAssertTrue(project.creator.notifications.mobileComments!)
    XCTAssertTrue(project.creator.notifications.mobileFollower!)
    XCTAssertFalse(project.creator.notifications.mobileFriendActivity!)
    XCTAssertFalse(project.creator.notifications.mobileMarketingUpdate!)
    XCTAssertTrue(project.creator.notifications.mobileMessages!)
    XCTAssertNil(project.creator.notifications.mobilePostLikes)
    XCTAssertNil(project.creator.notifications.mobileUpdates)
    XCTAssertNil(project.creator.notifications.postLikes)
    XCTAssertTrue(project.creator.notifications.updates!)
    XCTAssertTrue(project.creator.social!)
    XCTAssertEqual(project.creator.stats.createdProjectsCount, 16)
    XCTAssertNil(project.creator.stats.draftProjectsCount)
    XCTAssertNil(project.creator.stats.memberProjectsCount)
    XCTAssertEqual(project.creator.stats.starredProjectsCount, 11)
    XCTAssertEqual(project.creator.stats.unansweredSurveysCount, 2)
    XCTAssertEqual(project.creator.stats.backedProjectsCount, 3)
    XCTAssertEqual(project.creator.stats.unreadMessagesCount, 0)
    XCTAssertEqual(project.creator.unseenActivityCount, 1)
    /// Project member data
    XCTAssertEqual(
      project.memberData.permissions,
      [.comment]
    )
    // TODO: Related to creator login (ie. DashboardViewController), map these values to GQL Query data if they are available.
    XCTAssertNil(project.memberData.lastUpdatePublishedAt)
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
    XCTAssertEqual(
      lastAddOn.description,
      "First edition of the book The Quiet / Erstausgabe des Buchs The Quiet."
    )
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
    XCTAssertEqual(
      lastReward.description,
      "Signed first edition of the book The Quiet with a personal inscription and one of 10 limited edition gallery prints (numbered and signed) on Aluminium Dibond of a photo of your choice from the book (Format: 30x45cm) / Signierte Erstausgabe des Buchs The Quiet mit einer persönlichen WIdmung und einem von 10 limitierten Alu-Dibond Galleryprint (nummeriert und signiert) eines Fotos deiner Wahl aus dem Buch im Format 30 cm x 45 cm."
    )
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
    XCTAssertFalse(lastReward.shipping.enabled)
    XCTAssertEqual(lastReward.shipping.preference!, .none)
    XCTAssertNil(lastReward.shippingRulesExpanded)
    XCTAssertNil(lastReward.shipping.location)
    XCTAssertNil(lastReward.shipping.summary)
    XCTAssertNil(lastReward.shipping.type)
  }
}
