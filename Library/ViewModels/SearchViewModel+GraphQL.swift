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

    return GraphAPI.SearchQuery(
      term: params.query,
      sort: sort,
      categoryId: categoryId,
      state: state,
      raised: raised,
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
    percentRaised: DiscoveryParams.PercentRaisedBucket?
  ) -> DiscoveryParams {
    var params = DiscoveryParams.defaults
    params.sort = sort
    params.query = query
    params.category = category
    params.perPage = 15
    params.state = state
    params.percentRaised = percentRaised
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
