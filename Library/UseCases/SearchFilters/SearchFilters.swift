import Combine
import KsApi
import SwiftUI

/// A model that SwiftUI can use to display Search Filters modals.
///
/// Also creates `SearchFilterPill`s from the selected filters,
/// for the `SearchFiltersHeaderView`.
///
/// This object is read-only outside of the `Library-iOS` Framework.
/// `SearchFiltersUseCase` owns and updates this object.
public class SearchFilters: ObservableObject {
  public struct CategoryOptions {
    public var categories: [KsApi.Category]
    public var selectedCategory: SearchFiltersCategory
  }

  public struct SortOptions {
    public let sortOptions: [DiscoveryParams.Sort]
    public var selectedSort: DiscoveryParams.Sort
  }

  public struct ProjectStateOptions {
    public let stateOptions: [DiscoveryParams.State]
    public var selectedProjectState: DiscoveryParams.State
  }

  public private(set) var category: CategoryOptions
  public private(set) var sort: SortOptions
  public private(set) var projectState: ProjectStateOptions
  public fileprivate(set) var pills: [SearchFilterPill]

  public let objectWillChange = ObservableObjectPublisher()

  public var hasFilters: Bool {
    return self.hasCategory || self.hasProjectState
  }

  public var hasCategory: Bool {
    switch self.category.selectedCategory {
    case .none:
      return false
    case .rootCategory:
      return true
    case .subcategory:
      return true
    }
  }

  public var hasProjectState: Bool {
    return self.projectState.selectedProjectState != SearchFiltersUseCase.defaultStateOption
  }

  public var hasSort: Bool {
    return self.sort.selectedSort != SearchFiltersUseCase.defaultSortOption
  }

  internal init(
    sort: SortOptions,
    category: CategoryOptions,
    projectState: ProjectStateOptions
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

    self.sort.selectedSort = sort
    self.category.selectedCategory = category
    self.projectState.selectedProjectState = projectState

    self.updatePills()
  }

  internal func update(
    withCategories categories: [KsApi.Category]
  ) {
    self.objectWillChange.send()
    self.category.categories = categories
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

    pills.append(SearchFilterPill(
      isHighlighted: self.hasFilters,
      filterType: .allFilters,
      buttonType: .image("icon-filters"),
      count: filterCount
    ))

    let selectedCategory = self.category.selectedCategory.category
    let categoryPillTitle = selectedCategory?.name ?? Strings.Category()

    pills.append(SearchFilterPill(
      isHighlighted: self.hasCategory,
      filterType: .category,
      buttonType: .dropdown(categoryPillTitle)
    ))

    let projectStatePillTitle = self.hasProjectState ? self.projectState.selectedProjectState.title : Strings
      .Project_status()

    pills.append(
      SearchFilterPill(
        isHighlighted: self.hasProjectState,
        filterType: .projectState,
        buttonType: .dropdown(projectStatePillTitle)
      )
    )

    self.pills = pills
  }
}
