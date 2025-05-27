import Library

extension SearchFilters {
  var sortPill: SearchFilterPill? {
    return self.pills.first(where: { $0.filterType == .sort })
  }

  var filterPill: SearchFilterPill? {
    return self.pills.first(where: { $0.filterType == .allFilters })
  }

  var categoryPill: SearchFilterPill? {
    return self.pills.first(where: { $0.filterType == .category })
  }

  var projectStatePill: SearchFilterPill? {
    return self.pills.first(where: { $0.filterType == .projectState })
  }
}
