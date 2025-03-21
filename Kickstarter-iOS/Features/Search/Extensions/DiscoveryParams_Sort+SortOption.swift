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
      return Strings.discovery_sort_types_magic()
    case .newest:
      return Strings.discovery_sort_types_newest()
    case .popular:
      return Strings.discovery_sort_types_popularity()
    }
  }
}
