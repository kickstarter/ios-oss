import Foundation

extension Project {
  fileprivate static var htmlParser = {
    HTMLParser()
  }()

  /**
   Returns a minimal `Project` from a `ProjectFragment`
   */
  static func project(
    from projectFragment: GraphAPI.ProjectFragment,
    rewards: [Reward] = [],
    addOns: [Reward]? = nil,
    backing: Backing? = nil,
    currentUserChosenCurrency: String?
  ) -> Project? {
    guard
      let country = Country.country(
        from: projectFragment.country.fragments.countryFragment,
        minPledge: projectFragment.minPledge,
        maxPledge: projectFragment.maxPledge,
        currency: projectFragment.currency
      ),
      let categoryFragment = projectFragment.category?.fragments.categoryFragment,
      let category = Project.Category.category(from: categoryFragment),
      let dates = projectDates(from: projectFragment),
      let locationFragment = projectFragment.location?.fragments.locationFragment,
      let location = Location.location(from: locationFragment),
      let memberData = projectMemberData(from: projectFragment),
      let photo = projectPhoto(from: projectFragment),
      let state = projectState(from: projectFragment.state),
      let userFragment = projectFragment.creator?.fragments.userFragment,
      let creator = User.user(from: userFragment)
    else { return nil }

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

    let extendedProjectProperties = extendedProject(from: projectFragment)

    return Project(
      availableCardTypes: availableCardTypes,
      blurb: projectFragment.description,
      category: category,
      country: country,
      creator: creator,
      extendedProjectProperties: extendedProjectProperties,
      memberData: memberData,
      dates: dates,
      displayPrelaunch: displayPrelaunch,
      id: projectFragment.pid,
      location: location,
      name: projectFragment.name,
      personalization: projectPersonalization(
        isStarred: projectFragment.isWatched,
        backing: backing,
        friends: []
      ),
      photo: photo,
      prelaunchActivated: projectFragment.prelaunchActivated,
      rewardData: RewardData(addOns: addOns, rewards: rewards),
      slug: generatedSlug ?? projectFragment.slug,
      staffPick: projectFragment.isProjectWeLove,
      state: state,
      stats: projectStats(from: projectFragment, currentUserChosenCurrency: currentUserChosenCurrency),
      tags: discoverTags,
      urls: urls,
      video: projectVideo(from: projectFragment)
    )
  }
}

private func projectPersonalization(isStarred: Bool,
                                    backing: Backing?,
                                    friends: [User]) -> Project.Personalization {
  return Project.Personalization(
    backing: backing,
    friends: friends,
    isBacking: backing != nil,
    isStarred: isStarred
  )
}

/**
 Returns a minimal `Project.Dates` from a `ProjectFragment`
 */
private func projectDates(from projectFragment: GraphAPI.ProjectFragment) -> Project.Dates? {
  guard
    let deadline = projectFragment.deadlineAt.flatMap(TimeInterval.init),
    let launchedAt = projectFragment.launchedAt.flatMap(TimeInterval.init),
    let stateChangedAt = TimeInterval(projectFragment.stateChangedAt)
  else { return nil }

  let startOfToday = Calendar.current.startOfDay(for: Date()).timeIntervalSince1970

  var featuredAtDate: TimeInterval?

  if let projectOfTheDay = projectFragment.isProjectOfTheDay {
    featuredAtDate = projectOfTheDay ? startOfToday : nil
  }

  return Project.Dates(
    deadline: deadline,
    featuredAt: featuredAtDate,
    finalCollectionDate: finalCollectionDateTimeInterval(from: projectFragment.finalCollectionDate),
    launchedAt: launchedAt,
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

private func projectState(from projectState: GraphAPI.ProjectState) -> Project.State? {
  return Project.State(rawValue: projectState.rawValue.lowercased())
}

/**
 Returns a minimal `Project.Stats` from a `ProjectFragment`
 */
private func projectStats(from projectFragment: GraphAPI.ProjectFragment,
                          currentUserChosenCurrency: String?) -> Project.Stats {
  let pledgedRawData = projectFragment.pledged.fragments.moneyFragment.amount.flatMap(Float.init)
  let pledgedRawValue = projectFragment.pledged.fragments.moneyFragment.amount.flatMap(Float.init) ?? 0
  let pledgedValue = pledgedRawData != nil ? Int(pledgedRawValue) : 0
  let fxRateValue = Float(projectFragment.fxRate)
  let convertedPledgedAmountValue = pledgedRawData != nil ? pledgedRawValue * fxRateValue : nil
  let staticUSDRateValue = Float(projectFragment.usdExchangeRate ?? 0)
  var usdExchangeRate: Float?

  if let usdExchangeRateRawValue = projectFragment.usdExchangeRate {
    usdExchangeRate = Float(usdExchangeRateRawValue)
  }

  return Project.Stats(
    backersCount: projectFragment.backersCount,
    commentsCount: projectFragment.commentsCount,
    convertedPledgedAmount: convertedPledgedAmountValue,
    currency: projectFragment.currency.rawValue,
    currentCurrency: currentUserChosenCurrency,
    currentCurrencyRate: fxRateValue,
    goal: projectFragment.goal?.fragments.moneyFragment.amount.flatMap(Float.init).flatMap(Int.init) ?? 0,
    pledged: pledgedValue,
    staticUsdRate: staticUSDRateValue,
    updatesCount: projectFragment.posts?.totalCount,
    usdExchangeRate: usdExchangeRate
  )
}

/**
 Returns a video `Project.video` from `ProjectFragment`
 */

private func projectVideo(from projectFragment: GraphAPI.ProjectFragment) -> Project.Video? {
  guard let video = projectFragment.video,
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
 Returns a `ExtendedProjectProperties` object from `ProjectFragment`
 */
private func extendedProject(from projectFragment: GraphAPI.ProjectFragment) -> ExtendedProjectProperties {
  let risks = projectFragment.risks
  let environmentalCommitments = extendedProjectEnvironmentalCommitments(from: projectFragment)
  let faqs = extendedProjectFAQs(from: projectFragment)
  let minimumSingleTierPledgeAmount = projectFragment.minPledge

  let extendedProjectProperties = ExtendedProjectProperties(
    environmentalCommitments: environmentalCommitments,
    faqs: faqs,
    risks: risks,
    story: storyElements(from: projectFragment),
    minimumPledgeAmount: minimumSingleTierPledgeAmount
  )

  return extendedProjectProperties
}

/**
 Returns a `ProjectStoryElements` object from `ProjectFragment`
 */
private func storyElements(from projectFragment: GraphAPI.ProjectFragment) -> ProjectStoryElements {
  var viewElements = Project.htmlParser.parse(bodyHtml: projectFragment.story)

  let videoViewElementTest =
    VideoViewElement(
      sourceURLString: "https://v.kickstarter.com/1646253861_eee618959d375e50481b4b31a19b416125ecc615/assets/036/484/390/7d3797530a67146d18b5c32a1bcae961_h264_high.mp4",
      thumbnailURLString: "https://dr0rfahizzuzj.cloudfront.net/assets/034/747/335/b060e1907417e761401ac958a6df9cd7_h264_high.jpg?2021",
      seekPosition: .zero
    )
  /**

   let videoViewElementTest2 =
     VideoViewElement(
       sourceURLString: "https://v.kickstarter.com/1645751496_817a6f06026c9d931015968e0a7cedc46e72a435/projects/4306092/video-1148586-h264_high.mp4",
       thumbnailURLString: "https://dr0rfahizzuzj.cloudfront.net/assets/034/747/335/b060e1907417e761401ac958a6df9cd7_h264_high.jpg?2021",
       seekPosition: .zero
     )

   let videoViewElementTest3 =
     VideoViewElement(
       sourceURLString: "https://v.kickstarter.com/1645751598_22a09032b6d0e947d9fad126603dba08606b42b0/projects/4292671/video-1146600-h264_high.mp4",
       thumbnailURLString: "https://dr0rfahizzuzj.cloudfront.net/assets/034/747/335/b060e1907417e761401ac958a6df9cd7_h264_high.jpg?2021",
       seekPosition: .zero
     )

   let videoViewElementTest4 =
     VideoViewElement(
       sourceURLString: "https://v.kickstarter.com/1645751605_7bfc123e1cd41f47c45ef821fdcef50361cdbdde/assets/036/163/639/287fe32ebf3a018938f305af5fe41a1d_h264_high.mp4",
       thumbnailURLString: "https://dr0rfahizzuzj.cloudfront.net/assets/034/747/335/b060e1907417e761401ac958a6df9cd7_h264_high.jpg?2021",
       seekPosition: .zero
     )

   let videoViewElementTest5 =
     VideoViewElement(
       sourceURLString: "https://v.kickstarter.com/1645751605_fe99b3f7f8b53d83dd09476882c7cb60f39e6127/assets/036/101/316/357375a0a2d93f7e428a65c7a6734c74_h264_high.mp4",
       thumbnailURLString: "https://dr0rfahizzuzj.cloudfront.net/assets/034/747/335/b060e1907417e761401ac958a6df9cd7_h264_high.jpg?2021",
       seekPosition: .zero
     )

   let videoViewElementTest6 =
     VideoViewElement(
       sourceURLString: "https://v.kickstarter.com/1645751605_94bf826e0a7049439b8d6a70dd8317235f0ba664/assets/036/330/597/acd2968f9fb0fb5bd7d5d79f0b92a55d_h264_high.mp4",
       thumbnailURLString: "https://dr0rfahizzuzj.cloudfront.net/assets/034/747/335/b060e1907417e761401ac958a6df9cd7_h264_high.jpg?2021",
       seekPosition: .zero
     )

   let videoViewElementTest7 =
     VideoViewElement(
       sourceURLString: "https://v.kickstarter.com/1645752103_5b51ed41af3680ceb14606e33f10ea0b1bd5cd87/assets/036/045/093/8f245b0b6790a9eb0a956669b0439188_h264_high.mp4",
       thumbnailURLString: "https://dr0rfahizzuzj.cloudfront.net/assets/034/747/335/b060e1907417e761401ac958a6df9cd7_h264_high.jpg?2021",
       seekPosition: .zero
     )

   let videoViewElementTest8 =
     VideoViewElement(
       sourceURLString: "https://v.kickstarter.com/1645752487_c8d804760a0eeaf3f73954c2f7e268049a714ec2/assets/036/165/410/e12e7bb3e4a2a8b7c4007836d3945efb_h264_high.mp4",
       thumbnailURLString: "https://dr0rfahizzuzj.cloudfront.net/assets/034/747/335/b060e1907417e761401ac958a6df9cd7_h264_high.jpg?2021",
       seekPosition: .zero
     )

   let videoViewElementTest9 =
     VideoViewElement(
       sourceURLString: "https://v.kickstarter.com/1645752708_97e35d99a3e087865c845dc2cd48efed73ba5b03/assets/036/152/353/f213495bec4173655e107f863d0442e6_h264_high.mp4",
       thumbnailURLString: "https://dr0rfahizzuzj.cloudfront.net/assets/034/747/335/b060e1907417e761401ac958a6df9cd7_h264_high.jpg?2021",
       seekPosition: .zero
     )

   let videoViewElementTest10 =
     VideoViewElement(
       sourceURLString: "https://v.kickstarter.com/1645752972_8f4439afeaeacf79fa0ad78c0f127f2c866de5ae/assets/036/186/504/a1bfcf3174fefc5f6bacb9252144929b_h264_high.mp4",
       thumbnailURLString: "https://dr0rfahizzuzj.cloudfront.net/assets/034/747/335/b060e1907417e761401ac958a6df9cd7_h264_high.jpg?2021",
       seekPosition: .zero
     )
   */

  viewElements.insert(videoViewElementTest, at: viewElements.count / 2)
  /**
   viewElements.insert(videoViewElementTest2, at: 0)
   viewElements.insert(videoViewElementTest3, at: 0)
   viewElements.insert(videoViewElementTest4, at: 0)
   viewElements.insert(videoViewElementTest5, at: 0)
   viewElements.insert(videoViewElementTest6, at: 0)
   viewElements.insert(videoViewElementTest7, at: 0)
   viewElements.insert(videoViewElementTest8, at: 0)
   viewElements.insert(videoViewElementTest9, at: 0)
   viewElements.insert(videoViewElementTest10, at: 0)

   /// INFO: `AVPlayerItem` cannot be associated with more than one `AVPlayer`. Prevents a scenario later on where repeated video urls cause a crash in the `VideoViewElementCell`
   var allVideoElementURLStringsAndIndices = [(urlString: String, index: Int)]()

   for index in 0..<viewElements.count {
     if let videoViewElement = viewElements[index] as? VideoViewElement {
       let urlStringAndIndex = (urlString: videoViewElement.sourceURLString, index: index)

       allVideoElementURLStringsAndIndices.append(urlStringAndIndex)
     }
   }

   allVideoElementURLStringsAndIndices.sort(by: { $0.urlString < $1.urlString })

   for urlIndex in 0..<allVideoElementURLStringsAndIndices.count - 1 {
     if allVideoElementURLStringsAndIndices[urlIndex].urlString == allVideoElementURLStringsAndIndices[urlIndex + 1].urlString {
       viewElements.remove(at: allVideoElementURLStringsAndIndices[urlIndex].index - urlIndex)
     }
   }

    // USE THIS INSTEAD FOR CHECKING DUPLICATES, CLEANER, FASTER
    var seenURLStrings = Set<String>()
    var uniqueElements = [(element: VideoViewElement, item: AVPlayerItem?)]()
    for videoElement in uniqueElements {
        if !seenURLStrings.contains(videoElement.element.sourceURLString) {
            uniqueElements.append(videoElement)
          seenURLStrings.insert(videoElement.element.sourceURLString)
        }
    }
   */

  let storyElements = ProjectStoryElements(htmlViewElements: viewElements)

  return storyElements
}

/**
 Returns a `GraphQLProject.ProjectFAQ` from `ProjectFragment`
 */

private func extendedProjectFAQs(from projectFragment: GraphAPI
  .ProjectFragment) -> [ProjectFAQ] {
  var faqs = [ProjectFAQ]()

  if let allFaqs = projectFragment.faqs?.nodes.flatMap({ $0 }) {
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
 Returns a `GraphQLProject.EnvironmentalCommitment` from `ProjectFragment`
 */

private func extendedProjectEnvironmentalCommitments(from projectFragment: GraphAPI
  .ProjectFragment) -> [ProjectEnvironmentalCommitment] {
  var environmentalCommitments = [ProjectEnvironmentalCommitment]()

  if let allEnvironmentalCommitments = projectFragment.environmentalCommitments {
    for commitment in allEnvironmentalCommitments {
      guard let id = commitment?.id,
        let decomposedId = decompose(id: id),
        let description = commitment?.description else {
        continue
      }

      var commitmentCategory: ProjectCommitmentCategory

      switch commitment?.commitmentCategory {
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

      let environmentalCommitment = ProjectEnvironmentalCommitment(
        description: description,
        category: commitmentCategory,
        id: decomposedId
      )

      environmentalCommitments.append(environmentalCommitment)
    }
  }

  return environmentalCommitments
}
