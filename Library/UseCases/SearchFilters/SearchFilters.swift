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

  public struct PercentRaisedOptions {
    public let buckets: [DiscoveryParams.PercentRaisedBucket]
    public var selectedBucket: DiscoveryParams.PercentRaisedBucket?
  }

  public struct LocationOptions {
    public var defaultLocations: [Location]
    public var searchLocations: [Location]
    public var selectedLocation: Location?
  }

  public private(set) var category: CategoryOptions
  public private(set) var sort: SortOptions
  public private(set) var projectState: ProjectStateOptions
  public private(set) var percentRaised: PercentRaisedOptions
  public private(set) var location: LocationOptions

  public fileprivate(set) var pills: [SearchFilterPill]

  public let objectWillChange = ObservableObjectPublisher()

  var filterCount: Int {
    // Note that sort is a special case and is not included in
    // reset or the filter count functionality.
    [
      self.hasCategory,
      self.hasProjectState,
      self.hasPercentRaised,
      self.hasLocation
    ]
    .count(where: { $0 == true })
  }

  var hasFilters: Bool {
    self.filterCount > 0
  }

  var hasCategory: Bool {
    switch self.category.selectedCategory {
    case .none:
      return false
    case .rootCategory:
      return true
    case .subcategory:
      return true
    }
  }

  var hasProjectState: Bool {
    return self.projectState.selectedProjectState != SearchFiltersUseCase.defaultStateOption
  }

  var hasSort: Bool {
    return self.sort.selectedSort != SearchFiltersUseCase.defaultSortOption
  }

  var hasPercentRaised: Bool {
    return self.percentRaised.selectedBucket != nil
  }

  var hasLocation: Bool {
    return self.location.selectedLocation != nil
  }

  internal init(
    sort: SortOptions,
    category: CategoryOptions,
    projectState: ProjectStateOptions,
    percentRaised: PercentRaisedOptions,
    location: LocationOptions
  ) {
    self.sort = sort
    self.category = category
    self.projectState = projectState
    self.percentRaised = percentRaised
    self.location = location

    self.pills = []
    self.updatePills()
  }

  internal func update(
    withSort sort: DiscoveryParams.Sort,
    category: SearchFiltersCategory,
    projectState: DiscoveryParams.State,
    percentRaisedBucket: DiscoveryParams.PercentRaisedBucket?
  ) {
    self.objectWillChange.send()

    self.sort.selectedSort = sort
    self.category.selectedCategory = category
    self.projectState.selectedProjectState = projectState
    self.percentRaised.selectedBucket = percentRaisedBucket

    self.updatePills()
  }

  internal func update(
    withCategories categories: [KsApi.Category]
  ) {
    self.objectWillChange.send()
    self.category.categories = categories
  }

  internal func update(
    withDefaultSearchLocations locations: [Location]
  ) {
    self.objectWillChange.send()
    self.location.defaultLocations = locations
  }

  internal func update(
    withSearchQueryLocations locations: [Location]
  ) {
    self.objectWillChange.send()
    self.location.searchLocations = locations
  }

  public func has(filter type: SearchFilterModalType) -> Bool {
    switch type {
    case .allFilters:
      return self.hasFilters
    case .category:
      return self.hasCategory
    case .sort:
      return self.hasSort
    case .percentRaised:
      return self.hasPercentRaised
    case .location:
      return self.hasLocation
    }
  }

  public func canReset(filter type: SearchFilterModalType) -> Bool {
    return self.has(filter: type)
  }

  private func updatePills() {
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
      count: self.filterCount
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

    if featureSearchFilterByPercentRaisedEnabled() {
      let percentRaisedTitle = self.percentRaised.selectedBucket?.title ?? Strings.Percentage_raised()

      pills.append(
        SearchFilterPill(
          isHighlighted: self.hasPercentRaised,
          filterType: .percentRaised,
          buttonType: .dropdown(percentRaisedTitle)
        )
      )
    }

    if featureSearchFilterByLocation() {
      pills.append(
        SearchFilterPill(
          isHighlighted: self.hasLocation,
          filterType: .location,
          buttonType: .dropdown("FPO: Location")
        )
      )
    }

    self.pills = pills
  }
}
