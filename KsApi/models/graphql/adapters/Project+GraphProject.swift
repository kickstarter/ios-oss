import Foundation

extension Project {
  /**
   Returns a minimal `Project` from a `GraphProject`
   */
  static func project(from graphProject: GraphProject) -> Project? {
    guard
      let country = graphProject.country.flatMap(Country.country(from:)),
      let graphCategory = graphProject.category,
      let category = Project.Category.category(from: graphCategory),
      let dates = projectDates(from: graphProject),
      let graphLocation = graphProject.location,
      let location = Location.location(from: graphLocation),
      let photo = projectPhoto(from: graphProject),
      let state = projectState(from: graphProject.state),
      let creator = User.user(from: graphProject.creator)
    else { return nil }

    let urls = Project.UrlsEnvelope(
      web: UrlsEnvelope.WebEnvelope(project: graphProject.url, updates: nil)
    )

    let addOns = projectRewards(
      from: graphProject.addOns?.nodes,
      projectId: graphProject.pid
    )

    let rewards = projectRewards(
      from: graphProject.rewards?.nodes,
      projectId: graphProject.pid
    ) ?? []

    return Project(
      blurb: graphProject.description,
      category: category,
      country: country,
      creator: creator,
      memberData: MemberData(permissions: []),
      dates: dates,
      id: graphProject.pid,
      location: location,
      name: graphProject.name,
      personalization: Personalization(),
      photo: photo,
      rewardData: RewardData(addOns: addOns, rewards: rewards),
      slug: graphProject.slug,
      staffPick: graphProject.isProjectWeLove ?? false,
      state: state,
      stats: projectStats(from: graphProject),
      urls: urls
    )
  }
}

private func projectRewards(from graphRewards: [GraphReward]?, projectId: Int) -> [Reward]? {
  return graphRewards?.compactMap { graphReward in
    Reward.reward(from: graphReward, projectId: projectId)
  }
}

/**
 Returns a minimal `Project.Dates` from a `GraphProject`
 */
private func projectDates(from graphProject: GraphProject) -> Project.Dates? {
  guard
    let deadline = graphProject.deadlineAt,
    let launchedAt = graphProject.launchedAt
  else { return nil }

  return Project.Dates(
    deadline: deadline,
    featuredAt: nil,
    finalCollectionDate: finalCollectionDateTimeInterval(from: graphProject.finalCollectionDate),
    launchedAt: launchedAt,
    stateChangedAt: graphProject.stateChangedAt
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
 Returns a minimal `Project.Stats` from a `GraphProject`
 */
private func projectStats(from graphProject: GraphProject) -> Project.Stats {
  return Project.Stats(
    backersCount: graphProject.backersCount,
    commentsCount: nil,
    convertedPledgedAmount: nil,
    currency: graphProject.currency,
    currentCurrency: nil,
    currentCurrencyRate: nil,
    goal: graphProject.goal.map(\.amount).flatMap(Int.init) ?? 0,
    pledged: Int(graphProject.pledged.amount),
    staticUsdRate: graphProject.usdExchangeRate.flatMap(Float.init) ?? 0,
    updatesCount: nil
  )
}

/**
 Returns a minimal `Project.Photo` from a `GraphProject`
 */
private func projectPhoto(from graphProject: GraphProject) -> Project.Photo? {
  guard let url = graphProject.image?.url else { return nil }

  return Project.Photo(
    full: url,
    med: url,
    size1024x768: url,
    small: url
  )
}

private func projectState(from projectState: ProjectState) -> Project.State? {
  return Project.State(rawValue: projectState.rawValue.lowercased())
}
