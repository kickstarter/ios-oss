import Apollo
@testable import KsApi
import ReactiveSwift
import XCTest

final class Project_FetchProjectQueryDataTests: XCTestCase {
  /// `FetchProjectQueryBySlug` returns identical data.
  func testFetchProjectQueryData_Success() {
    let producer = Project.projectProducer(
      from: FetchProjectQueryTemplate.valid.data,
      configCurrency: Project.Country.de.currencyCode
    )

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
    XCTAssertEqual(project.watchesCount, 180)
    XCTAssertTrue(project.isPledgeOverTimeAllowed!)
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

    /// Project Stats
    XCTAssertEqual(project.stats.backersCount, 148)
    XCTAssertEqual(project.stats.projectCurrency, "EUR")
    XCTAssertEqual(project.stats.goal, 2_000)
    XCTAssertEqual(project.stats.pledged, 7_827)
    XCTAssertEqual(project.stats.staticUsdRate, 1.18302594)
    XCTAssertEqual(project.stats.usdExchangeRate, 1.18302594)
    XCTAssertEqual(project.stats.updatesCount, 5)
    XCTAssertEqual(project.stats.commentsCount, 0)
    XCTAssertEqual(project.stats.convertedPledgedAmount, 11_706.016586616)
    XCTAssertEqual(project.stats.userCurrency, "CAD")
    XCTAssertEqual(project.stats.userCurrencyRate, 1.49547966)

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
      "https://i.kickstarter.com/assets/033/846/044/7134a6f4504bd636327de703a1d2dd1c_original.jpg?anim=false&fit=crop&gravity=auto&height=576&origin=ugc-qa&q=92&width=1024&sig=8iRaaTqqHeMUUXIcSvaNxHjjeHO5pbqMMizjXnBn82c%3D"
    )
    XCTAssertEqual(
      project.photo.full,
      "https://i.kickstarter.com/assets/033/846/044/7134a6f4504bd636327de703a1d2dd1c_original.jpg?anim=false&fit=crop&gravity=auto&height=576&origin=ugc-qa&q=92&width=1024&sig=8iRaaTqqHeMUUXIcSvaNxHjjeHO5pbqMMizjXnBn82c%3D"
    )
    XCTAssertEqual(
      project.photo.med,
      "https://i.kickstarter.com/assets/033/846/044/7134a6f4504bd636327de703a1d2dd1c_original.jpg?anim=false&fit=crop&gravity=auto&height=576&origin=ugc-qa&q=92&width=1024&sig=8iRaaTqqHeMUUXIcSvaNxHjjeHO5pbqMMizjXnBn82c%3D"
    )
    XCTAssertEqual(
      project.photo.small,
      "https://i.kickstarter.com/assets/033/846/044/7134a6f4504bd636327de703a1d2dd1c_original.jpg?anim=false&fit=crop&gravity=auto&height=576&origin=ugc-qa&q=92&width=1024&sig=8iRaaTqqHeMUUXIcSvaNxHjjeHO5pbqMMizjXnBn82c%3D"
    )

    /// Project Category
    XCTAssertEqual(project.category.name, "Photobooks")
    XCTAssertEqual(project.category.id, decompose(id: "Q2F0ZWdvcnktMjgw"))
    XCTAssertEqual(project.category.analyticsName, "Photobooks")
    XCTAssertEqual(project.category.parentId, decompose(id: "Q2F0ZWdvcnktMTU="))
    XCTAssertEqual(project.category.parentName, "Photography")

    /// Project Country
    XCTAssertEqual(project.country.countryCode, "CA")
    XCTAssertEqual(project.country.currencySymbol, "€")
    XCTAssertEqual(project.country.maxPledge, 8_500)
    XCTAssertEqual(project.country.minPledge, 1)
    XCTAssertEqual(project.country.trailingCode, true)

    // Project Send Capi Events
    XCTAssertEqual(project.sendMetaCapiEvents, true)

    // Project Flagging
    XCTAssertEqual(project.flagging, false)

    /// Project User
    XCTAssertEqual(project.creator.avatar.large, "image-a")
    XCTAssertEqual(project.creator.avatar.medium, "image-a")
    XCTAssertEqual(project.creator.avatar.small, "image-a")
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
    XCTAssertNil(project.addOns)

    /// Project rewards data -- rewards
    XCTAssertEqual(project.rewards.count, 1)

    guard let firstReward = project.rewards.first else {
      XCTFail("project should have at least one reward.")

      return
    }

    XCTAssertTrue(firstReward.isNoReward)

    guard let extendedProjectProperties = project.extendedProjectProperties,
          let firstTextElement = extendedProjectProperties.story.htmlViewElements.first as? TextViewElement,
          let firstImageElement = extendedProjectProperties.story
          .htmlViewElements[extendedProjectProperties.story.htmlViewElements.count - 2] as? ImageViewElement,
          let firstAudioVideoElement = extendedProjectProperties.story.htmlViewElements
          .last as? AudioVideoViewElement,
          let firstTextComponent = firstTextElement.components.first else {
      XCTFail("extended project properties should exist.")

      return
    }

    XCTAssertEqual(firstImageElement.caption, "Viktor Pushkarev using lino-cutting to create the cover art.")
    XCTAssertEqual(
      firstImageElement.src,
      "https://i.kickstarter.com/assets/034/488/736/c35446a93f1f9faedd76e9db814247bf_original.gif?fit=contain&origin=ugc-qa&q=92&width=700&sig=d1W1LoX9kZ07lXxteoCWiWFBPiGqf%2F6MfmGOppqCVzU%3D"
    )
    XCTAssertEqual(
      firstImageElement.href,
      "https://producthype.co/most-powerful-crowdfunding-newsletter/?utm_source=ProductHype&utm_medium=Banner&utm_campaign=Homi"
    )

    XCTAssertEqual(extendedProjectProperties.story.htmlViewElements.count, 4)
    XCTAssertEqual(firstTextElement.components.count, 1)
    XCTAssertEqual(firstTextComponent.text, "What about a bold link to that same newspaper website?")
    XCTAssertEqual(firstTextComponent.link, "http://record.pt/")
    XCTAssertEqual(firstTextComponent.styles, [.bold, .link])
    XCTAssertEqual(
      firstAudioVideoElement.sourceURLString,
      "https://v.kickstarter.com/1646345127_8366452d275cb8330ca0cee82a6c5259a1df288e/assets/035/786/501/b99cdfe87fc9b942dce0fe9a59a3767a_h264_high.mp4"
    )
    XCTAssertEqual(
      firstAudioVideoElement.thumbnailURLString,
      "https://dr0rfahizzuzj.cloudfront.net/assets/035/786/501/b99cdfe87fc9b942dce0fe9a59a3767a_h264_base.jpg?2021"
    )
    XCTAssertEqual(firstAudioVideoElement.seekPosition, .zero)
    XCTAssertEqual(extendedProjectProperties.risks, "Risks")
    XCTAssertEqual(extendedProjectProperties.environmentalCommitments.count, 1)
    XCTAssertEqual(
      extendedProjectProperties.environmentalCommitments.last?.category,
      .longLastingDesign
    )
    XCTAssertEqual(
      extendedProjectProperties.environmentalCommitments.last?.description,
      "High quality materials and cards - there is nothing design or tech-wise that would render Dustbiters obsolete besides losing the cards."
    )
    XCTAssertEqual(
      extendedProjectProperties.environmentalCommitments.last?.id,
      decompose(id: "RW52aXJvbm1lbnRhbENvbW1pdG1lbnQtMTI2NTA2")
    )
    XCTAssertEqual(extendedProjectProperties.faqs.count, 1)
    XCTAssertEqual(
      extendedProjectProperties.faqs.last!.question,
      "Are you planning any expansions for Dustbiters?"
    )
    XCTAssertEqual(
      extendedProjectProperties.faqs.last!.answer,
      "This may sound weird in the world of big game boxes with hundreds of tokens, cards and thick manuals, but through years of playtesting and refinement we found our ideal experience is these 21 unique cards we have now. Dustbiters is balanced for quick and furious games with different strategies every time you jump back in, and we currently have no plans to mess with that."
    )
    XCTAssertEqual(
      extendedProjectProperties.faqs.last!.id,
      decompose(id: "UHJvamVjdEZhcS0zNzA4MDM=")
    )
    XCTAssertEqual(extendedProjectProperties.faqs.last!.createdAt!, TimeInterval(1_628_103_400))

    guard let aiDisclosureRawData = extendedProjectProperties.aiDisclosure else {
      XCTFail("AI disclosure should exist")

      return
    }

    XCTAssertEqual(aiDisclosureRawData.id, decompose(id: "QWlEaXNjbG9zdXJlLTE="))
    XCTAssertFalse(aiDisclosureRawData.funding.fundingForAiOption)
    XCTAssertFalse(aiDisclosureRawData.funding.fundingForAiConsent)
    XCTAssertTrue(aiDisclosureRawData.funding.fundingForAiAttribution)
    XCTAssertFalse(aiDisclosureRawData.generationDisclosure!.consent!.isEmpty)
    XCTAssertFalse(aiDisclosureRawData.generationDisclosure!.details!.isEmpty)
    XCTAssertTrue(aiDisclosureRawData.involvesAi)
    XCTAssertTrue(aiDisclosureRawData.involvesFunding)
    XCTAssertTrue(aiDisclosureRawData.involvesGeneration)
    XCTAssertFalse(aiDisclosureRawData.involvesOther)
    XCTAssertNil(aiDisclosureRawData.otherAiDetails)
  }
}
