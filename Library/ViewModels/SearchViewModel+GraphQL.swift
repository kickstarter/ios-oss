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
      return GraphAPI.RaisedBuckets.bucket_0
    case .bucket_1:
      return GraphAPI.RaisedBuckets.bucket_1
    case .bucket_2:
      return GraphAPI.RaisedBuckets.bucket_2
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
      return GraphAPI.PledgedBuckets.bucket_0
    case .bucket_1:
      return GraphAPI.PledgedBuckets.bucket_1
    case .bucket_2:
      return GraphAPI.PledgedBuckets.bucket_2
    case .bucket_3:
      return GraphAPI.PledgedBuckets.bucket_3
    case .bucket_4:
      return GraphAPI.PledgedBuckets.bucket_4
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

    return GraphAPI.SearchQuery(
      term: params.query,
      sort: sort,
      categoryId: categoryId,
      state: state,
      raised: raised,
      locationId: locationId,
      pledged: pledged,
      first: params.perPage,
      cursor: cursor
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

extension GraphAPI.SearchQuery.Data.Project.Node: @retroactive Equatable {}

public func == (
  lhs: GraphAPI.SearchQuery.Data.Project.Node,
  rhs: GraphAPI.SearchQuery.Data.Project.Node
) -> Bool {
  return lhs.fragments.backerDashboardProjectCellFragment.projectId == rhs.fragments
    .backerDashboardProjectCellFragment.projectId
}
