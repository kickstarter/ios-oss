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
  public private(set) var category: SearchFiltersCategory
  public private(set) var projectState: DiscoveryParams.State
  public fileprivate(set) var pills: [SearchFilterPill]

  public var hasFilters: Bool {
    return self.hasCategory || self.hasProjectState
  }

  public var hasCategory: Bool {
    switch self.category {
    case .none:
      return false
    case .rootCategory:
      return true
    case .subcategory:
      return true
    }
  }

  public var hasProjectState: Bool {
    return self.projectState != SearchFiltersUseCase.defaultStateOption
  }

  public var hasSort: Bool {
    return self.sort != SearchFiltersUseCase.defaultSortOption
  }

  internal init(
    sort: DiscoveryParams.Sort,
    category: SearchFiltersCategory,
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
    category: SearchFiltersCategory,
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
    let filterCount = [self.hasCategory, self.hasProjectState]
      .count(where: { $0 == true })

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

    let selectedCategory = self.category.category

    pills.append(SearchFilterPill(
      isHighlighted: self.hasCategory,
      filterType: .category,
      buttonType: .dropdown(selectedCategory?.name ?? Strings.Category())
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
