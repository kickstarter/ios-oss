import Combine
import KsApi
import SwiftUI

/// A model that SwiftUI can use to know which filters are selected.
/// Creates `SearchFilterPill`s from the selected filters.
///
/// `SearchFiltersUseCase` owns and updates this object.
public class SelectedSearchFilters: ObservableObject {
  public let objectWillChange = ObservableObjectPublisher()

  public private(set) var sort: DiscoveryParams.Sort
  public private(set) var category: KsApi.Category?
  public private(set) var projectState: DiscoveryParams.State
  public fileprivate(set) var pills: [SearchFilterPill]

  public var hasFilters: Bool {
    return self.hasCategory || self.hasProjectState
  }

  public var hasCategory: Bool {
    return self.category != nil
  }

  public var hasProjectState: Bool {
    return self.projectState != SearchFiltersUseCase.defaultStateOption
  }

  public var hasSort: Bool {
    return self.sort != SearchFiltersUseCase.defaultSortOption
  }

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
    self.objectWillChange.send()

    self.sort = sort
    self.category = category
    self.projectState = projectState

    self.updatePills()
  }

  public func canReset(filter type: SearchFilterModalType) -> Bool {
    switch type {
    case .allFilters:
      return self.hasFilters
    case .category:
      return self.hasCategory
    case .sort:
      return self.hasSort
    }
  }

  private func updatePills() {
    let filterCount = [self.hasCategory, self.hasProjectState].reduce(0) { filterCount, hasFilter in
      filterCount + (hasFilter ? 1 : 0)
    }

    var pills: [SearchFilterPill] = []

    pills.append(SearchFilterPill(
      isHighlighted: self.hasSort,
      filterType: .sort,
      buttonType: .image("icon-sort")
    ))

    if featureSearchFilterByProjectStatusEnabled() {
      pills.append(SearchFilterPill(
        isHighlighted: self.hasFilters,
        filterType: .allFilters,
        buttonType: .image("icon-filters"),
        count: filterCount
      ))
    }

    pills.append(SearchFilterPill(
      isHighlighted: self.hasCategory,
      filterType: .category,
      buttonType: .dropdown(self.category?.name ?? Strings.Category())
    ))

    if featureSearchFilterByProjectStatusEnabled() {
      pills.append(
        SearchFilterPill(
          isHighlighted: self.hasProjectState,
          filterType: .projectState,
          buttonType: .dropdown(self.hasProjectState ? self.projectState.title : Strings.Project_status())
        )
      )
    }

    self.pills = pills
  }
}
