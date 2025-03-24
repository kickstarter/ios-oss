import KsApi
import Library

extension DiscoveryParams.Sort: @retroactive Identifiable {}
// Implements SortOption so DiscoveryParams.Sort can be used in a SortView.
extension DiscoveryParams.Sort: SortOption {
  public var id: Int {
    return self.rawValue.hashValue
  }

  public var name: String {
    switch self {
    case .endingSoon:
      return Strings.discovery_sort_types_end_date()
    case .magic:
      return Strings.Recommended()
    case .newest:
      return Strings.discovery_sort_types_newest()
    case .popular:
      return Strings.discovery_sort_types_popularity()
    case .most_funded:
      return Strings.discovery_sort_types_most_funded()
    case .most_backed:
      return Strings.discovery_sort_types_most_backed()
    }
  }
}
