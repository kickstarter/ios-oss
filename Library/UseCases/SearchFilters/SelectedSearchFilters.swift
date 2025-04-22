import KsApi
import SwiftUI

/// A model that SwiftUI can use to know which filters are selected.
/// Creates `SearchFilterPill`s from the selected filters.
///
/// `SearchFiltersUseCase` owns and updates this object.
public class SelectedSearchFilters: ObservableObject {
  @Published public private(set) var sort: DiscoveryParams.Sort
  @Published public private(set) var category: KsApi.Category?
  @Published public private(set) var projectState: DiscoveryParams.State
  @Published public fileprivate(set) var pills: [SearchFilterPill]

  internal init(
    sort: DiscoveryParams.Sort,
    category: KsApi.Category? = nil,
    projectState: DiscoveryParams.State
  ) {
    self.sort = sort
    self.category = category
    self.projectState = projectState

    self.pills = []
    self.updatePills()
  }

  internal func update(
    withSort sort: DiscoveryParams.Sort,
    category: KsApi.Category?,
    projectState: DiscoveryParams.State
  ) {
    self.sort = sort
    self.category = category
    self.projectState = projectState

    self.updatePills()
  }

  private func updatePills() {
    self.pills = filterPills(fromSelectedSort: self.sort, category: self.category, state: self.projectState)
  }
}

private func filterPills(
  fromSelectedSort sort: DiscoveryParams.Sort,
  category: KsApi.Category?,
  state: DiscoveryParams.State
) -> [SearchFilterPill] {
  let hasCategory = category != nil
  let hasState = state != SearchFiltersUseCase.defaultStateOption

  let filterCount = [hasCategory, hasState].reduce(0) { filterCount, hasFilter in
    filterCount + (hasFilter ? 1 : 0)
  }

  var pills: [SearchFilterPill] = []

  pills.append(SearchFilterPill(
    isHighlighted: sort != SearchFiltersUseCase.defaultSortOption,
    filterType: .sort,
    buttonType: .image("icon-sort")
  ))

  if featureSearchFilterByProjectStatusEnabled() {
    pills.append(SearchFilterPill(
      isHighlighted: hasCategory || hasState,
      filterType: .all,
      buttonType: .image("icon-filters"),
      count: filterCount
    ))
  }

  pills.append(SearchFilterPill(
    isHighlighted: category != nil,
    filterType: .category,
    buttonType: .dropdown(category?.name ?? Strings.Category())
  ))

  if featureSearchFilterByProjectStatusEnabled() {
    pills.append(
      SearchFilterPill(
        isHighlighted: state != SearchFiltersUseCase.defaultStateOption,
        filterType: .projectState,
        buttonType: .dropdown(hasState ? state.title : Strings.Project_status())
      )
    )
  }

  return pills
}
