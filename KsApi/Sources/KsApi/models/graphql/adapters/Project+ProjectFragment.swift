import Foundation
import GraphAPI

extension Project {
  fileprivate static var htmlParser = {
    HTMLParser()
  }()

  /**
   Returns a minimal `Project` from a `ProjectFragment`
   */
  static func project(
    from projectFragment: GraphAPI.ProjectFragment,
    flagging: Bool? = nil,
    rewards: [Reward] = [],
    addOns: [Reward]? = nil,
    backing: Backing? = nil
  ) -> Project? {
    guard
      let country = Country.country(
        from: projectFragment.country.fragments.countryFragment,
        minPledge: projectFragment.minPledge,
        maxPledge: projectFragment.maxPledge,
        currency: projectFragment.currency.value
      ),
      let categoryFragment = projectFragment.category?.fragments.categoryFragment,
      let dates = projectDates(from: projectFragment.fragments.projectDatesFragment),
      let memberData = projectMemberData(from: projectFragment),
      let photo = projectPhoto(from: projectFragment),
      let state = projectState(from: projectFragment.state.value),
      let userFragment = projectFragment.creator?.fragments.publicUserFragment,
      let creator = User.publicUser(from: userFragment)
    else { return nil }

    var category: Category?
    if let categoryFragment = projectFragment.category?.fragments.categoryFragment {
      category = Project.Category.category(from: categoryFragment)
    }

    var location: Location?
    if let locationFragment = projectFragment.location?.fragments.locationFragment {
      location = Location.location(from: locationFragment)
    }

    let urls = Project.UrlsEnvelope(
      web: UrlsEnvelope.WebEnvelope(project: projectFragment.url, updates: projectFragment.url + "/posts")
    )

    let availableCardTypes = projectFragment.availableCardTypes.compactMap { $0.rawValue }

    let displayPrelaunch = !projectFragment.isLaunched

    let discoverTags: [String] = projectFragment.tags
      .compactMap { tag -> String? in
        if let tagName = tag?.name {
          return tagName
        }

        return nil
      }
    /**
     NOTE: Project friends fetched by
     `fetchProjectFriends(param: Param) -> SignalProducer<[User], ErrorEnvelope>`
     */

    /**
     NOTE: `Project.generatedSlug`currently returns an internal server error for user that isn't logged in. Seeing as we need the project object even if the user isn't logged in, we can still use `Project.slug` and parse the string below to get the same result until the `Project.generatedSlug` is fixed.
     */

    let generatedSlug = projectFragment.slug
      .components(separatedBy: "/")
      .filter { $0 != "" }
      .last

    let extendedFragment = projectFragment.fragments.extendedProjectPropertiesFragment
    let extendedProjectProperties = extendedProject(from: extendedFragment)

    let lastWave = projectFragment.lastWave
      .flatMap { LastWave(fromFragment: $0.fragments.lastWaveFragment) }

    let pledgeManager = projectFragment.pledgeManager
      .flatMap { PledgeManager(fromFragment: $0.fragments.pledgeManagerFragment) }

    let video = projectVideo(from: projectFragment.video?.fragments.projectVideoFragment)

    let plotFragment = projectFragment.fragments.pledgeOverTimeFragment

    let statsFragment = projectFragment.fragments.projectStatsFragment
    let stats = projectStats(from: statsFragment)

    return
      Project(
        availableCardTypes: availableCardTypes,
        blurb: projectFragment.description,
        category: category,
        country: country,
        creator: creator,
        extendedProjectProperties: extendedProjectProperties,
        memberData: memberData,
        dates: dates,
        displayPrelaunch: displayPrelaunch,
        flagging: flagging,
        id: projectFragment.pid,
        lastWave: lastWave,
        location: location,
        name: projectFragment.name,
        pledgeManager: pledgeManager,
        pledgeOverTimeCollectionPlanChargeExplanation: plotFragment
          .pledgeOverTimeCollectionPlanChargeExplanation ?? "",
        pledgeOverTimeCollectionPlanChargedAsNPayments: plotFragment
          .pledgeOverTimeCollectionPlanChargedAsNPayments ?? "",
        pledgeOverTimeCollectionPlanShortPitch: plotFragment.pledgeOverTimeCollectionPlanShortPitch ?? "",
        pledgeOverTimeMinimumExplanation: plotFragment.pledgeOverTimeMinimumExplanation ?? "",
        personalization: projectPersonalization(
          isStarred: projectFragment.isWatched,
          backing: backing,
          friends: []
        ),
        photo: photo,
        isInPostCampaignPledgingPhase: projectFragment.isInPostCampaignPledgingPhase,
        postCampaignPledgingEnabled: projectFragment.postCampaignPledgingEnabled,
        prelaunchActivated: projectFragment.prelaunchActivated,
        redemptionPageUrl: projectFragment.redemptionPageUrl,
        rewardData: RewardData(addOns: addOns, rewards: rewards),
        sendMetaCapiEvents: projectFragment.sendMetaCapiEvents,
        slug: generatedSlug ?? projectFragment.slug,
        staffPick: projectFragment.isProjectWeLove,
        state: state,
        stats: stats,
        tags: discoverTags,
        urls: urls,
        video: video,
        watchesCount: projectFragment.watchesCount,
        isPledgeOverTimeAllowed: plotFragment.isPledgeOverTimeAllowed
      )
  }
}

private func projectPersonalization(
  isStarred: Bool,
  backing: Backing?,
  friends: [User]
) -> Project.Personalization {
  return Project.Personalization(
    backing: backing,
    friends: friends,
    isBacking: backing != nil,
    isStarred: isStarred
  )
}

/**
 Returns a minimal `Project.Dates` from a `ProjectDatesFragment`
 */
private func projectDates(from datesFragment: GraphAPI.ProjectDatesFragment) -> Project.Dates? {
  guard let stateChangedAt = TimeInterval(datesFragment.stateChangedAt)
  else { return nil }

  let startOfToday = Calendar.current.startOfDay(for: Date()).timeIntervalSince1970

  var featuredAtDate: TimeInterval?

  if let projectOfTheDay = datesFragment.isProjectOfTheDay {
    featuredAtDate = projectOfTheDay ? startOfToday : nil
  }

  return Project.Dates(
    deadline: datesFragment.deadlineAt.flatMap(TimeInterval.init),
    featuredAt: featuredAtDate,
    finalCollectionDate: finalCollectionDateTimeInterval(from: datesFragment.finalCollectionDate),
    launchedAt: datesFragment.launchedAt.flatMap(TimeInterval.init),
    stateChangedAt: stateChangedAt
  )
}

private func finalCollectionDateTimeInterval(
  from string: String?,
  dateFormatter: ISO8601DateFormatter = ISO8601DateFormatter()
) -> TimeInterval? {
  guard let string = string else { return nil }

  return dateFormatter.date(from: string)?.timeIntervalSince1970
}

/**
 Returns a minimal `Project.MemberData` from a `ProjectFragment`
 */
private func projectMemberData(from projectFragment: GraphAPI.ProjectFragment) -> Project.MemberData? {
  let collaboratorPermissions = Project.MemberData(permissions: projectFragment.canComment ? [.comment] : [])

  // TODO: Also used by `DashboardActionCellViewModel` and `MessagesViewModel` - but they are not using the GQL `fetchProject(param:)` call yet.
  return collaboratorPermissions
}

/**
 Returns a minimal `Project.Photo` from a `ProjectFragment`
 */
private func projectPhoto(from projectFragment: GraphAPI.ProjectFragment) -> Project.Photo? {
  guard let url = projectFragment.image?.url else { return nil }

  return Project.Photo(
    full: url,
    med: url,
    size1024x768: url,
    small: url
  )
}

private func projectState(from projectState: GraphAPI.ProjectState?) -> Project.State? {
  guard let projectState else {
    return nil
  }
  return Project.State(rawValue: projectState.rawValue.lowercased())
}

/**
 Returns a minimal `Project.Stats` from a `ProjectStatsFragment`
 */
private func projectStats(
  from statsFragment: GraphAPI.ProjectStatsFragment
) -> Project.Stats {
  let pledgedRawData = statsFragment.pledged.fragments.moneyFragment.amount.flatMap(Float.init)
  let pledgedRawValue = statsFragment.pledged.fragments.moneyFragment.amount.flatMap(Float.init) ?? 0
  let pledgedValue = pledgedRawData != nil ? Int(pledgedRawValue) : 0
  let fxRateValue = Float(statsFragment.fxRate)
  let convertedPledgedAmountValue = pledgedRawData != nil ? pledgedRawValue * fxRateValue : nil
  let staticUSDRateValue = Float(statsFragment.usdExchangeRate ?? 0)
  var usdExchangeRate: Float?

  if let usdExchangeRateRawValue = statsFragment.usdExchangeRate {
    usdExchangeRate = Float(usdExchangeRateRawValue)
  }

  return Project.Stats(
    backersCount: statsFragment.backersCount,
    commentsCount: statsFragment.commentsCount,
    convertedPledgedAmount: convertedPledgedAmountValue,
    projectCurrency: statsFragment.currency.rawValue,
    userCurrency: statsFragment.fxRateCurrency.rawValue,
    userCurrencyRate: fxRateValue,
    goal: statsFragment.goal?.fragments.moneyFragment.amount.flatMap(Float.init).flatMap(Int.init) ?? 0,
    pledged: pledgedValue,
    staticUsdRate: staticUSDRateValue,
    updatesCount: statsFragment.posts.totalCount,
    usdExchangeRate: usdExchangeRate
  )
}

/**
 Returns a video `Project.video` from `ProjectVideoFragment`
 */

private func projectVideo(from videoFragment: GraphAPI.ProjectVideoFragment?) -> Project.Video? {
  guard let video = videoFragment,
        let videoId = decompose(id: video.id),
        let high = video.videoSources?.high?.src else {
    return nil
  }

  return Project.Video(
    id: videoId,
    high: high,
    hls: video.videoSources?.hls?.src
  )
}

/**
 Returns a `ExtendedProjectProperties` object from `ExtendedProjectPropertiesFragment`
 */
private func extendedProject(
  from fragment: GraphAPI.ExtendedProjectPropertiesFragment
) -> ExtendedProjectProperties {
  let risks = fragment.risks
  let environmentalCommitments = extendedProjectEnvironmentalCommitments(from: fragment)
  let faqs = extendedProjectFAQs(from: fragment)
  let minimumSingleTierPledgeAmount = fragment.minPledge
  let aiDisclosure = extendedProjectAIDisclosure(from: fragment)

  let extendedProjectProperties = ExtendedProjectProperties(
    environmentalCommitments: environmentalCommitments,
    faqs: faqs,
    aiDisclosure: aiDisclosure,
    risks: risks,
    story: storyElements(from: fragment),
    minimumPledgeAmount: minimumSingleTierPledgeAmount,
    projectNotice: fragment.projectNotice
  )

  return extendedProjectProperties
}

/**
 Returns a `ProjectStoryElements` object from `ExtendedProjectPropertiesFragment`
 */
private func storyElements(
  from fragment: GraphAPI.ExtendedProjectPropertiesFragment
) -> ProjectStoryElements {
  let viewElements = Project.htmlParser.parse(bodyHtml: fragment.story)
  var seenURLStrings = Set<String>()
  var htmlElementsWithUniqueAudioVideoViewElements = [HTMLViewElement]()

  for viewElement in viewElements {
    guard let audioVideoViewElement = viewElement as? AudioVideoViewElement else {
      htmlElementsWithUniqueAudioVideoViewElements.append(viewElement)

      continue
    }

    if !seenURLStrings.contains(audioVideoViewElement.sourceURLString) {
      htmlElementsWithUniqueAudioVideoViewElements.append(viewElement)
      seenURLStrings.insert(audioVideoViewElement.sourceURLString)
    }
  }

  let storyElements = ProjectStoryElements(htmlViewElements: htmlElementsWithUniqueAudioVideoViewElements)

  return storyElements
}

/**
 Returns a `GraphQLProject.ProjectFAQ` from `ExtendedProjectPropertiesFragment`
 */

private func extendedProjectFAQs(
  from fragment: GraphAPI.ExtendedProjectPropertiesFragment
) -> [ProjectFAQ] {
  var faqs = [ProjectFAQ]()

  if let allFaqs = fragment.faqs?.nodes.flatMap({ $0 }) {
    for faq in allFaqs {
      guard let id = faq?.id,
            let decomposedId = decompose(id: id),
            let faqQuestion = faq?.question,
            let faqAnswer = faq?.answer else {
        continue
      }

      var createdAtDate: TimeInterval?

      if let existingDate = faq?.createdAt {
        createdAtDate = TimeInterval(existingDate)
      }

      let faq = ProjectFAQ(
        answer: faqAnswer,
        question: faqQuestion,
        id: decomposedId,
        createdAt: createdAtDate
      )

      faqs.append(faq)
    }
  }

  return faqs
}

/**
 Returns a `GraphQLProject.EnvironmentalCommitment` from `ExtendedProjectPropertiesFragment`
 */

private func extendedProjectEnvironmentalCommitments(
  from fragment: GraphAPI.ExtendedProjectPropertiesFragment
) -> [ProjectTabCategoryDescription] {
  var environmentalCommitments = [ProjectTabCategoryDescription]()

  if let allEnvironmentalCommitments = fragment.environmentalCommitments {
    for commitment in allEnvironmentalCommitments {
      guard let id = commitment?.id,
            let decomposedId = decompose(id: id),
            let description = commitment?.description else {
        continue
      }

      var commitmentCategory: ProjectTabCategory

      switch commitment?.commitmentCategory.value {
      case .longLastingDesign:
        commitmentCategory = .longLastingDesign
      case .sustainableMaterials:
        commitmentCategory = .sustainableMaterials
      case .environmentallyFriendlyFactories:
        commitmentCategory = .environmentallyFriendlyFactories
      case .sustainableDistribution:
        commitmentCategory = .sustainableDistribution
      case .reusabilityAndRecyclability:
        commitmentCategory = .reusabilityAndRecyclability
      default:
        commitmentCategory = .somethingElse
      }

      let environmentalCommitment = ProjectTabCategoryDescription(
        description: description,
        category: commitmentCategory,
        id: decomposedId
      )

      environmentalCommitments.append(environmentalCommitment)
    }
  }

  return environmentalCommitments
}

private func extendedProjectAIDisclosure(
  from fragment: GraphAPI.ExtendedProjectPropertiesFragment
) -> ProjectAIDisclosure? {
  guard let aiDisclosureRawData = fragment.aiDisclosure,
        let decomposedId = decompose(id: aiDisclosureRawData.id) else {
    return nil
  }

  let generatedByAIConsent = aiDisclosureRawData
    .generatedByAiConsent ??
    ""
  let generatedByAIDetails = aiDisclosureRawData
    .generatedByAiDetails ??
    ""

  let generatedOtherAIDetails = aiDisclosureRawData
    .otherAiDetails ??
    ""

  let aiDisclosureOther = ProjectTabCategoryDescription(
    description: generatedOtherAIDetails,
    category: .aiDisclosureOtherDetails,
    id: decomposedId + 2
  )

  let availableAIOtherDisclosure = !generatedOtherAIDetails.isEmpty

  let fundingForAIAttribution = aiDisclosureRawData.fundingForAiAttribution ?? false
  let fundingForAIConsent = aiDisclosureRawData.fundingForAiConsent ?? false
  let fundingForAIOption = aiDisclosureRawData.fundingForAiOption ?? false

  let fundingOptions = ProjectTabFundingOptions(
    fundingForAiAttribution: fundingForAIAttribution,
    fundingForAiConsent: fundingForAIConsent,
    fundingForAiOption: fundingForAIOption
  )

  let generationDisclosure = generatedByAIConsent.isEmpty && generatedByAIDetails.isEmpty ? nil :
    ProjectTabGenerationDisclosure(
      consent: generatedByAIConsent,
      details: generatedByAIDetails
    )

  let aiDisclosure = ProjectAIDisclosure(
    id: decomposedId,
    funding: fundingOptions,
    generationDisclosure: generationDisclosure,
    involvesAi: aiDisclosureRawData.involvesAi,
    involvesFunding: aiDisclosureRawData.involvesFunding,
    involvesGeneration: aiDisclosureRawData.involvesGeneration,
    involvesOther: aiDisclosureRawData.involvesOther,
    otherAiDetails: availableAIOtherDisclosure ? aiDisclosureOther : nil
  )

  return aiDisclosure
}

extension Project.State {
  public init?(_ fragment: GraphAPI.ProjectState) {
    guard let state = projectState(from: fragment) else {
      return nil
    }
    self = state
  }
}
