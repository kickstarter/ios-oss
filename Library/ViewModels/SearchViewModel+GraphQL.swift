import KsApi

extension GraphAPI.ProjectSort {
  static func from(discovery sort: DiscoveryParams.Sort) -> GraphAPI.ProjectSort {
    switch sort {
    case .endingSoon:
      return .endDate
    case .magic:
      return .magic
    case .newest:
      return .newest
    case .popular:
      return .popularity
    case .most_funded:
      return .mostFunded
    case .most_backed:
      return .mostBacked
    }
  }
}

extension GraphAPI.PublicProjectState {
  static func from(discovery state: DiscoveryParams.State) -> GraphAPI.PublicProjectState? {
    switch state {
    case .all:
      // Returning all results means we're not filtering to any particular state
      return nil
    case .live:
      return GraphAPI.PublicProjectState.live
    case .successful:
      return GraphAPI.PublicProjectState.successful
    case .late_pledge:
      return GraphAPI.PublicProjectState.latePledge
    case .upcoming:
      return GraphAPI.PublicProjectState.upcoming
    }
  }
}

extension GraphAPI.RaisedBuckets {
  static func from(discovery raised: DiscoveryParams.PercentRaisedBucket?) -> GraphAPI.RaisedBuckets? {
    guard let raised = raised else {
      return nil
    }

    switch raised {
    case .bucket_0:
      return GraphAPI.RaisedBuckets.bucket0
    case .bucket_1:
      return GraphAPI.RaisedBuckets.bucket1
    case .bucket_2:
      return GraphAPI.RaisedBuckets.bucket2
    }
  }
}

extension GraphAPI.PledgedBuckets {
  static func from(discovery pledged: DiscoveryParams.AmountRaisedBucket?) -> GraphAPI.PledgedBuckets? {
    guard let pledged = pledged else {
      return nil
    }

    switch pledged {
    case .bucket_0:
      return GraphAPI.PledgedBuckets.bucket0
    case .bucket_1:
      return GraphAPI.PledgedBuckets.bucket1
    case .bucket_2:
      return GraphAPI.PledgedBuckets.bucket2
    case .bucket_3:
      return GraphAPI.PledgedBuckets.bucket3
    case .bucket_4:
      return GraphAPI.PledgedBuckets.bucket4
    }
  }
}

extension GraphAPI.SearchQuery {
  static func from(
    discoveryParams params: DiscoveryParams,
    withCursor cursor: String? = nil
  ) -> GraphAPI.SearchQuery {
    let sort = GraphAPI.ProjectSort.from(discovery: params.sort ?? .magic)
    let categoryId: String?
    if let categoryIntId = params.category?.intID {
      categoryId = "\(categoryIntId)"
    } else {
      categoryId = nil
    }

    let state = GraphAPI.PublicProjectState.from(discovery: params.state ?? .all)
    let raised = GraphAPI.RaisedBuckets.from(discovery: params.percentRaised)
    let locationId = params.location?.graphID
    let pledged = GraphAPI.PledgedBuckets.from(discovery: params.amountRaised)

    let showRecommended = params.social
    let showSavedProjects = params.starred
    let showProjectsWeLove = params.staffPicks
    let showFollowing = params.social

    assert(
      showRecommended != .some(false),
      "Setting showRecommended to false would return only non-recommended results. Did you mean to set it to nil?"
    )
    assert(
      showSavedProjects != .some(false),
      "Setting showSavedProjects to false would return only unsaved results. Did you mean to set it to nil?"
    )
    assert(
      showProjectsWeLove != .some(false),
      "Setting showProjectsWeLove to false would return only unloved results. Did you mean to set it to nil?"
    )
    assert(
      showFollowing != .some(false),
      "Setting showFollowing to false would return only unfollowed results. Did you mean to set it to nil?"
    )

    return GraphAPI.SearchQuery(
      term: GraphQLNullable.someOrNil(params.query),
      sort: GraphQLEnum.caseOrNil(sort),
      categoryId: GraphQLNullable.someOrNil(categoryId),
      state: GraphQLEnum.caseOrNil(state),
      raised: GraphQLEnum.caseOrNil(raised),
      locationId: GraphQLNullable.someOrNil(locationId),
      pledged: GraphQLEnum.caseOrNil(pledged),
      showRecommended: GraphQLNullable.someOrNil(showRecommended),
      showSavedProjects: GraphQLNullable.someOrNil(showSavedProjects),
      showProjectsWeLove: GraphQLNullable.someOrNil(showProjectsWeLove),
      showFollowing: GraphQLNullable.someOrNil(showFollowing),
      first: GraphQLNullable.someOrNil(params.perPage),
      cursor: GraphQLNullable.someOrNil(cursor)
    )
  }
}

extension DiscoveryParams {
  static var popular: DiscoveryParams {
    var params = DiscoveryParams.defaults
    params.sort = .popular
    params.perPage = 15
    params.state = .all
    return params
  }

  static func withQuery(
    _ query: String,
    sort: DiscoveryParams.Sort,
    category: Category?,
    state: DiscoveryParams.State?,
    percentRaised: DiscoveryParams.PercentRaisedBucket?,
    location: Location?,
    amountRaised: DiscoveryParams.AmountRaisedBucket?
  ) -> DiscoveryParams {
    var params = DiscoveryParams.defaults
    params.sort = sort
    params.query = query
    params.category = category
    params.perPage = 15
    params.state = state
    params.percentRaised = percentRaised
    params.location = location
    params.amountRaised = amountRaised
    return params
  }
}

extension GraphAPI.SearchQuery.Data.Projects.Node: @retroactive Equatable {}

public func == (
  lhs: GraphAPI.SearchQuery.Data.Projects.Node,
  rhs: GraphAPI.SearchQuery.Data.Projects.Node
) -> Bool {
  return lhs.fragments.backerDashboardProjectCellFragment.projectId == rhs.fragments
    .backerDashboardProjectCellFragment.projectId
}
