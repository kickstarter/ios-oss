import Foundation

extension Project {
  /**
   Returns a minimal `Project` from a `ProjectFragment`
   */
  static func project(
    from projectFragment: GraphAPI.ProjectFragment,
    rewards: [Reward] = [],
    addOns: [Reward]? = nil
  ) -> Project? {
    guard
      let country = Country.country(from: projectFragment.country.fragments.countryFragment),
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
      web: UrlsEnvelope.WebEnvelope(project: projectFragment.url, updates: nil)
    )

    return Project(
      blurb: projectFragment.description,
      category: category,
      country: country,
      creator: creator,
      memberData: memberData,
      dates: dates,
      id: projectFragment.pid,
      location: location,
      name: projectFragment.name,
      personalization: Personalization(),
      photo: photo,
      rewardData: RewardData(addOns: addOns, rewards: rewards),
      slug: projectFragment.slug,
      staffPick: projectFragment.isProjectWeLove,
      state: state,
      stats: projectStats(from: projectFragment),
      urls: urls
    )
  }
}

private func projectRewards(from rewardFragments: [GraphAPI.RewardFragment]?) -> [Reward]? {
  return rewardFragments?.compactMap { rewardFragment in
    Reward.reward(from: rewardFragment)
  }
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

  return Project.Dates(
    deadline: deadline,
    featuredAt: nil,
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
  let collaboratorPermissions = projectFragment.collaboratorPermissions.compactMap { permission in
    Project.MemberData.Permission(rawValue: permission.rawValue.lowercased())
  }

  // TODO: - Once we are receiving the other three properties of MemberData back from a Project on Graph, extend this functionality.
  return Project.MemberData(permissions: collaboratorPermissions)
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
private func projectStats(from projectFragment: GraphAPI.ProjectFragment) -> Project.Stats {
  return Project.Stats(
    backersCount: projectFragment.backersCount,
    commentsCount: nil,
    convertedPledgedAmount: nil,
    currency: projectFragment.currency.rawValue,
    currentCurrency: nil,
    currentCurrencyRate: nil,
    goal: projectFragment.goal?.fragments.moneyFragment.amount.flatMap(Int.init) ?? 0,
    pledged: projectFragment.pledged.fragments.moneyFragment.amount.flatMap(Int.init) ?? 0,
    staticUsdRate: projectFragment.usdExchangeRate.flatMap(Float.init) ?? 0,
    updatesCount: nil
  )
}
