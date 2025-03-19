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
    }
  }
}

extension GraphAPI.SearchQuery {
  static func from(
    discoveryParams params: DiscoveryParams,
    withCursor cursor: String? = nil
  ) -> GraphAPI.SearchQuery {
    let sort = GraphAPI.ProjectSort.from(discovery: params.sort ?? .magic)
    return GraphAPI.SearchQuery(term: params.query, sort: sort, first: params.perPage, cursor: cursor)
  }
}

extension DiscoveryParams {
  static var popular: DiscoveryParams {
    var params = DiscoveryParams.defaults
    params.sort = .popular
    params.perPage = 15
    return params
  }

  static func withQuery(_ query: String) -> DiscoveryParams {
    var params = DiscoveryParams.defaults
    params.sort = .popular
    params.query = query
    params.perPage = 15
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
