import KsApi

/// Represents the options that can be presented for search filters.
public struct SearchFilterOptions {
  public struct CategoryOptions {
    public let categories: [KsApi.Category]
  }

  public struct SortOptions {
    public let sortOptions: [DiscoveryParams.Sort]
  }

  public struct ProjectStateOptions {
    public let stateOptions: [DiscoveryParams.State]
  }

  public let category: CategoryOptions
  public let sort: SortOptions
  public let projectState: ProjectStateOptions
}
