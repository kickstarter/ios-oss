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
    story: storyViewableElements(),
    minimumPledgeAmount: minimumSingleTierPledgeAmount
  )

  return extendedProjectProperties
}

private func storyViewableElements() -> ProjectStoryElements {
  // TODO: Replace this in https://kickstarter.atlassian.net/browse/NTV-344
  let sampleStory = """
  <h1 id=\"h:whoop-whoop\" class=\"page-anchor\">Whoop whoop</h1>\n<p>Coach Lasso must navigate the team through encounters with the best teams in English football, despite having no prior experience in the sport.</p>\n<ol>\n  <li> <a href=\"https://www.goal.com/en/news/afc-richmond-real-team-ted-lasso-club-inspiration-stadium/dsktplas5tln1usbhdmqjarih#afc-richmond-real-team\" target=\"_blank\" rel=\"noopener\">Is <em>AFC</em></a> <a href=\"https://www.goal.com/en/news/afc-richmond-real-team-ted-lasso-club-inspiration-stadium/dsktplas5tln1usbhdmqjarih#afc-richmond-real-team\" target=\"_blank\" rel=\"noopener\"><em><strong>Richmond</strong></em></a> <a href=\"https://www.goal.com/en/news/afc-richmond-real-team-ted-lasso-club-inspiration-stadium/dsktplas5tln1usbhdmqjarih#afc-richmond-real-team\" target=\"_blank\" rel=\"noopener\">a real<strong> team</strong>?</a> </li>\n  <li><a href=\"https://www.goal.com/en/news/afc-richmond-real-team-ted-lasso-club-inspiration-stadium/dsktplas5tln1usbhdmqjarih#real-footballers\" target=\"_blank\" rel=\"noopener\">Are there real footballers in Ted Lasso?</a></li>\n  <li><a href=\"https://www.goal.com/en/news/afc-richmond-real-team-ted-lasso-club-inspiration-stadium/dsktplas5tln1usbhdmqjarih#stadium\" target=\"_blank\" rel=\"noopener\"><em>Which stadium do AFC Richmond play in?</em></a></li>\n  <li> <strong>Ted </strong>Lasso<em>filming</em><em><strong>locations</strong></em> </li>\n</ol>\n<p><strong>AFC Richmond</strong> is a fictional team, despite being portrayed as a competitor in the <em>Premier League</em> in the <strong>Ted Lasso</strong> TV series.</p>\n<p>However, while Coach Lasso's team is not real, the club understandably takes some inspiration from actual football teams in England and plays up to the idea that it is real.</p>\n<p><a href=\"https://www.goal.com/en/news/afc-richmond-real-team-ted-lasso-club-inspiration-stadium/dsktplas5tln1usbhdmqjarih\" target=\"_blank\" rel=\"noopener\">Read it all here</a></p>\n<h1 id=\"h:show-me-the-deal\" class=\"page-anchor\">Show me the deal </h1>\n\n<div class=\"template asset\" contenteditable=\"false\" data-alt-text=\"\" data-caption=\"\" data-id=\"35659916\">\n<figure>\n<img alt=\"\" class=\"fit\" src=\"https://ksr-qa-ugc.imgix.net/assets/035/659/916/0b0c6239321146d5aaa32468f3ef6d6e_original.jpg?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1641856690&amp;auto=format&amp;gif-q=50&amp;q=92&amp;s=57d2d74ac9b0d896aa74fd61bd5fac68\">\n</figure>\n\n</div>\n\n\n<div class=\"template asset\" contenteditable=\"false\" data-alt-text=\"\" data-caption=\"Ice baths are great\" data-id=\"35659917\">\n<figure>\n<img alt=\"\" class=\"fit\" src=\"https://ksr-qa-ugc.imgix.net/assets/035/659/917/05e192776dee3dc2a94e45f3ed8501d3_original.jpg?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1641856715&amp;auto=format&amp;gif-q=50&amp;q=92&amp;s=99e2650ab12af78bdb3f5722c7e5e43e\">\n<figcaption class=\"px2\">Ice baths are great</figcaption>\n</figure>\n\n</div>\n\n\n<a href=\"https://www.youtube.com/watch?v=KuM8VGvBIVk\" target=\"_blank\" rel=\"noopener\"><div class=\"template asset\" contenteditable=\"false\" data-alt-text=\"\" data-caption=\"Football is life\" data-id=\"35659918\">\n<figure>\n<img alt=\"\" class=\"fit\" src=\"https://ksr-qa-ugc.imgix.net/assets/035/659/918/aac45095dc7d2071c12c22f734e0776a_original.jpg?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1641856747&amp;auto=format&amp;gif-q=50&amp;q=92&amp;s=40437d3d488a70c855d296efe004186d\">\n<figcaption class=\"px2\">Football is life</figcaption>\n</figure>\n\n</div>\n</a>\n\n<div class=\"template asset\" contenteditable=\"false\" data-alt-text=\"\" data-caption=\"\" data-id=\"35659921\">\n<figure>\n<img alt=\"\" class=\"fit js-lazy-image\" data-src=\"https://ksr-qa-ugc.imgix.net/assets/035/659/921/b0109638f8c7857774acd3763b77ca71_original.gif?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1642033322&amp;auto=format&amp;gif-q=50&amp;q=92&amp;s=9efd75fd791adffbabd72e30ab358da8\" src=\"https://ksr-qa-ugc.imgix.net/assets/035/659/921/b0109638f8c7857774acd3763b77ca71_original.gif?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1642033322&amp;auto=format&amp;frame=1&amp;q=92&amp;s=4356c90f28d1bf931a3dc4467a746da1\">\n</figure>\n\n</div>\n\n\n<div class=\"template asset\" contenteditable=\"false\" data-alt-text=\"\" data-caption=\"Always remember to...\" data-id=\"35659922\">\n<figure>\n<img alt=\"\" class=\"fit js-lazy-image\" data-src=\"https://ksr-qa-ugc.imgix.net/assets/035/659/922/eae68383730822ffe949f3825600a80a_original.gif?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1642033337&amp;auto=format&amp;gif-q=50&amp;q=92&amp;s=b51bcbd62ce9e4a2a70af72d63356df2\" src=\"https://ksr-qa-ugc.imgix.net/assets/035/659/922/eae68383730822ffe949f3825600a80a_original.gif?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1642033337&amp;auto=format&amp;frame=1&amp;q=92&amp;s=7380121ecdd5cbef18075c41ef40c4df\">\n<figcaption class=\"px2\">Always remember to...</figcaption>\n</figure>\n\n</div>\n\n\n<a href=\"https://www.youtube.com/watch?v=0_qRyDCh2TE\" target=\"_blank\" rel=\"noopener\"><div class=\"template asset\" contenteditable=\"false\" data-alt-text=\"\" data-caption=\"... and party hard!\" data-id=\"35659923\">\n<figure>\n<img alt=\"\" class=\"fit js-lazy-image\" data-src=\"https://ksr-qa-ugc.imgix.net/assets/035/659/923/ae8758cdcb8d0c0e75cd4c1a155772b6_original.gif?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1642033373&amp;auto=format&amp;gif-q=50&amp;q=92&amp;s=53fc033fb5049b4dbd6cda7de287cb04\" src=\"https://ksr-qa-ugc.imgix.net/assets/035/659/923/ae8758cdcb8d0c0e75cd4c1a155772b6_original.gif?ixlib=rb-4.0.2&amp;w=700&amp;fit=max&amp;v=1642033373&amp;auto=format&amp;frame=1&amp;q=92&amp;s=26ea61449bb3a0fb5067c64790c1a6a1\">\n<figcaption class=\"px2\">... and party hard!</figcaption>\n</figure>\n\n</div>\n</a>\n\n            <div class=\"template oembed\" contenteditable=\"false\" data-href=\"https://www.youtube.com/watch?v=3u7EIiohs6U\">\n<iframe width=\"356\" height=\"200\" src=\"https://www.youtube.com/embed/3u7EIiohs6U?feature=oembed&amp;wmode=transparent\" frameborder=\"0\" allow=\"accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture\" allowfullscreen></iframe>\n\n</div>\n\n          \n\n<h1 id=\"h:what-about-some-musi\" class=\"page-anchor\">What about some music?</h1>\n<p>We got you!</p>\n\n            <div class=\"template oembed\" contenteditable=\"false\" data-href=\"https://open.spotify.com/track/0dpyzcT3RMNNSd2xKBf35I?si=8c3a869d82464083\">\n<iframe width=\"100%\" height=\"80\" title=\"Spotify Embed: Be Sweet\" frameborder=\"0\" allowfullscreen allow=\"autoplay; clipboard-write; encrypted-media; fullscreen; picture-in-picture\" src=\"https://open.spotify.com/embed/track/0dpyzcT3RMNNSd2xKBf35I?si=8c3a869d82464083&amp;utm_source=oembed\"></iframe>\n\n</div>\n\n          \n\n            <div class=\"template oembed\" contenteditable=\"false\" data-href=\"https://soundcloud.com/japanesebreakfast/savage-good-boy?utm_source=clipboard&amp;utm_medium=text&amp;utm_campaign=social_sharing\">\n<iframe width=\"560\" height=\"400\" scrolling=\"no\" frameborder=\"no\" src=\"https://w.soundcloud.com/player/?visual=true&amp;url=https%3A%2F%2Fapi.soundcloud.com%2Ftracks%2F994103107&amp;show_artwork=true&amp;maxwidth=560\"></iframe>\n\n</div>\n\n          \n\n            <div class=\"template oembed\" contenteditable=\"false\" data-href=\"https://michellezauner.bandcamp.com/track/paprika\">\n<iframe class=\"embedly-embed\" src=\"https://cdn.embedly.com/widgets/media.html?src=https%3A%2F%2Fbandcamp.com%2FEmbeddedPlayer%2Fv%3D2%2Ftrack%3D512671900%2Fsize%3Dlarge%2Flinkcol%3D0084B4%2Fnotracklist%3Dtrue%2Ftwittercard%3Dtrue%2F&amp;display_name=BandCamp&amp;url=https%3A%2F%2Fmichellezauner.bandcamp.com%2Ftrack%2Fpaprika&amp;image=https%3A%2F%2Ff4.bcbits.com%2Fimg%2Fa1594462619_5.jpg&amp;key=bb604e7974304bcc890165e12e2e0a7b&amp;type=text%2Fhtml&amp;schema=bandcamp\" width=\"350\" height=\"467\" scrolling=\"no\" title=\"BandCamp embed\" frameborder=\"0\" allow=\"autoplay; fullscreen\" allowfullscreen=\"true\"></iframe>\n\n</div>\n
  """

  let viewElements = Project.htmlParser.parse(bodyHtml: sampleStory)
  let textElements = viewElements.compactMap { $0 as? TextViewElement }
  let storyElements = ProjectStoryElements(textElements: textElements)

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
