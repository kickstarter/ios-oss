import KsApi
import ReactiveSwift
import UIKit

public protocol SearchFiltersUseCaseType {
  var inputs: SearchFiltersUseCaseInputs { get }
  var uiOutputs: SearchFiltersUseCaseUIOutputs { get }
  var dataOutputs: SearchFiltersUseCaseDataOutputs { get }
}

public protocol SearchFiltersUseCaseInputs {
  /// Call this when the user taps on a button to show one of the sort options.
  func tappedButton(forFilterType: SearchFilterPill.FilterType)
  /// Call this when the clears their query and the sort options should reset.
  func clearedQueryText()
  /// Call this when the user selects a new sort option.
  func selectedSortOption(_ sort: DiscoveryParams.Sort)
  /// Call this when the user selects a new category.
  func selectedCategory(_ category: SearchFiltersCategory)
  /// Call this when the user selects a new project state filter.
  func selectedProjectState(_ state: DiscoveryParams.State)
  /// Call this when the user selects a new percent raised filter.
  func selectedPercentRaisedBucket(_ bucket: DiscoveryParams.PercentRaisedBucket)
  /// Call this when the user selects a new amount raised filter.
  func selectedAmountRaisedBucket(_ bucket: DiscoveryParams.AmountRaisedBucket)
  /// Cal this when the user selects a filter location.
  func filteredLocation(_: Location?)
  /// Call this when the user taps reset on a filter modal
  func resetFilters(for: SearchFilterModalType)
}

public protocol SearchFiltersUseCaseUIOutputs {
  /// Sends a model object which can be used to display all filter options, and a type describing which filters to display.
  var showFilters: Signal<SearchFilterModalType, Never> { get }

  /// An @ObservableObject model which SwiftUI can use to display the search filters modals and header.
  /// Owned and automatically updated by this `SearchFiltersUseCase`.
  var searchFilters: SearchFilters { get }
}

public protocol SearchFiltersUseCaseDataOutputs {
  /// The currently selected sort option. Defaults to `.popular`. Default value only sent after `initialSignal` occurs.
  var selectedSort: Signal<DiscoveryParams.Sort, Never> { get }
  /// The currently selected category. Defaults to nil. Default value only sent after `initialSignal` occurs.
  var selectedCategory: Signal<SearchFiltersCategory, Never> { get }
  /// The currently selected project state. Defaults to `.all`. Default value only sent after `initialSignal` occurs.
  var selectedState: Signal<DiscoveryParams.State, Never> { get }
  /// The currently selected percent raised bucket. Defaults to `nil`. Default value only sent after `initialSignal` occurs.
  var selectedPercentRaisedBucket: Signal<DiscoveryParams.PercentRaisedBucket?, Never> { get }
  var selectedLocation: Signal<Location?, Never> { get }
  var selectedAmountRaisedBucket: Signal<DiscoveryParams.AmountRaisedBucket?, Never> { get }
}

public final class SearchFiltersUseCase: SearchFiltersUseCaseType, SearchFiltersUseCaseInputs,
  SearchFiltersUseCaseUIOutputs, SearchFiltersUseCaseDataOutputs {
  /// @param initialSignal - An initial signal pulse. Must be sent once for default values of `selectedSort` and `selectedCategory` to emit.
  /// @param categories - A list of possible filter categories. Must be sent for `showCategoryFilters` and `selectedSortOption` to work.

  public init(
    initialSignal: Signal<Void, Never>,
    categories: Signal<[KsApi.Category], Never>,
    defaultLocations: Signal<[KsApi.Location], Never>,
    suggestedLocations: Signal<[KsApi.Location], Never>
  ) {
    self.categoriesProperty <~ categories
    self.defaultLocationsProperty <~ defaultLocations
    self.suggestedLocationsProperty <~ suggestedLocations

    self.showFilters = self.tappedFilterTypeSignal
      .map { pill in
        let modalType = filterModal(toShowForPill: pill)
        return modalType
      }

    self.selectedSort = Signal.merge(
      self.selectedSortProperty.producer.takeWhen(initialSignal),
      self.selectedSortProperty.signal
    )

    self.selectedCategory = Signal.merge(
      self.selectedCategoryProperty.producer.takeWhen(initialSignal),
      self.selectedCategoryProperty.signal
    )

    self.selectedState = Signal.merge(
      self.selectedStateProperty.producer.takeWhen(initialSignal),
      self.selectedStateProperty.signal
    )

    self.selectedPercentRaisedBucket = Signal.merge(
      self.selectedPercentRaisedBucketProperty.producer.takeWhen(initialSignal),
      self.selectedPercentRaisedBucketProperty.signal
    )

    self.selectedLocation = Signal.merge(
      self.selectedLocationProperty.producer.takeWhen(initialSignal),
      self.selectedLocationProperty.signal
    )

    self.selectedAmountRaisedBucket = Signal.merge(
      self.selectedAmountRaisedBucketProperty.producer.takeWhen(initialSignal),
      self.selectedAmountRaisedBucketProperty.signal
    )

    let sortOptions = SearchFilters.SortOptions(
      sortOptions: self.sortOptions,
      selectedSort: self.selectedSortProperty.value
    )

    let categoryOptions = SearchFilters.CategoryOptions(
      categories: self.categoriesProperty.value,
      selectedCategory: self.selectedCategoryProperty.value
    )

    let projectStateOptions = SearchFilters.ProjectStateOptions(
      stateOptions: self.stateOptions,
      selectedProjectState: self.selectedStateProperty.value
    )

    let percentRaisedOptions = SearchFilters.PercentRaisedOptions(
      buckets: DiscoveryParams.PercentRaisedBucket.allCases
    )

    let locationOptions = SearchFilters.LocationOptions(
      defaultLocations: self.defaultLocationsProperty.value,
      suggestedLocations: self.suggestedLocationsProperty.value
    )

    let amountRaisedOptions = SearchFilters.AmountRaisedOptions(
      buckets: DiscoveryParams.AmountRaisedBucket.allCases
    )

    self.searchFilters = SearchFilters(
      sort: sortOptions,
      category: categoryOptions,
      projectState: projectStateOptions,
      percentRaised: percentRaisedOptions,
      location: locationOptions,
      amountRaised: amountRaisedOptions
    )

    Signal.combineLatest(
      self.dataOutputs.selectedSort,
      self.dataOutputs.selectedCategory,
      self.dataOutputs.selectedState,
      self.dataOutputs.selectedPercentRaisedBucket,
      self.dataOutputs.selectedLocation,
      self.dataOutputs.selectedAmountRaisedBucket
    )
    .observeForUI()
    .observeValues { [
      weak searchFilters
    ] sort, category, state, percentRaisedBucket, location, amountRaisedBucket in
      searchFilters?.update(
        withSort: sort,
        category: category,
        projectState: state,
        percentRaisedBucket: percentRaisedBucket,
        location: location,
        amountRaisedBucket: amountRaisedBucket
      )
    }

    self.categoriesProperty
      .signal
      .observeForUI()
      .observeValues { [weak searchFilters] categories in
        searchFilters?.update(withCategories: categories)
      }

    self.defaultLocationsProperty
      .signal
      .observeForUI()
      .observeValues { [weak searchFilters] locations in
        searchFilters?.update(withDefaultSearchLocations: locations)
      }

    self.suggestedLocationsProperty
      .signal
      .observeForUI()
      .observeValues { [weak searchFilters] locations in
        searchFilters?.update(withSuggestedLocations: locations)
      }
  }

  fileprivate let (tappedFilterTypeSignal, tappedFilterTypeObserver) = Signal<
    SearchFilterPill.FilterType,
    Never
  >
  .pipe()
  public func tappedButton(forFilterType type: SearchFilterPill.FilterType) {
    self.tappedFilterTypeObserver.send(value: type)
  }

  fileprivate let selectedSortProperty = MutableProperty<DiscoveryParams.Sort>(
    SearchFiltersUseCase
      .defaultSortOption
  )
  fileprivate let selectedCategoryProperty = MutableProperty<SearchFiltersCategory>(.none)
  fileprivate let selectedStateProperty = MutableProperty<DiscoveryParams.State>(
    SearchFiltersUseCase
      .defaultStateOption
  )
  fileprivate let selectedPercentRaisedBucketProperty =
    MutableProperty<DiscoveryParams.PercentRaisedBucket?>(nil)
  fileprivate let selectedLocationProperty = MutableProperty<Location?>(nil)
  fileprivate let selectedAmountRaisedBucketProperty =
    MutableProperty<DiscoveryParams.AmountRaisedBucket?>(nil)

  fileprivate let categoriesProperty = MutableProperty<[KsApi.Category]>([])
  fileprivate let defaultLocationsProperty = MutableProperty<[KsApi.Location]>([])
  fileprivate let suggestedLocationsProperty = MutableProperty<[KsApi.Location]>([])

  internal static let defaultSortOption = DiscoveryParams.Sort.magic

  fileprivate let sortOptions = [
    DiscoveryParams.Sort.magic, // aka Recommended
    DiscoveryParams.Sort.popular,
    DiscoveryParams.Sort.newest,
    DiscoveryParams.Sort.endingSoon,
    DiscoveryParams.Sort.most_funded,
    DiscoveryParams.Sort.most_backed
  ]

  internal static let defaultStateOption = DiscoveryParams.State.all

  fileprivate let stateOptions = [
    DiscoveryParams.State.all,
    DiscoveryParams.State.live,
    DiscoveryParams.State.late_pledge,
    DiscoveryParams.State.upcoming,
    DiscoveryParams.State.successful
  ]

  public var showFilters: Signal<SearchFilterModalType, Never>

  public var selectedSort: Signal<DiscoveryParams.Sort, Never>
  public var selectedCategory: Signal<SearchFiltersCategory, Never>
  public var selectedState: Signal<DiscoveryParams.State, Never>
  public var selectedPercentRaisedBucket: Signal<DiscoveryParams.PercentRaisedBucket?, Never>
  public var selectedLocation: Signal<Location?, Never>
  public var selectedAmountRaisedBucket: Signal<DiscoveryParams.AmountRaisedBucket?, Never>

  public private(set) var searchFilters: SearchFilters

  public func clearedQueryText() {
    self.resetFilters(for: .allFilters)
    self.resetFilters(for: .sort)
  }

  public func resetFilters(for modal: SearchFilterModalType) {
    switch modal {
    case .allFilters:
      // Sort isn't a filter, so it's not included here.
      self.selectedCategoryProperty.value = .none
      self.selectedStateProperty.value = SearchFiltersUseCase.defaultStateOption
      self.selectedPercentRaisedBucketProperty.value = nil
      self.selectedLocationProperty.value = nil
      self.selectedAmountRaisedBucketProperty.value = nil
    case .category:
      self.selectedCategoryProperty.value = .none
    case .sort:
      self.selectedSortProperty.value = SearchFiltersUseCase.defaultSortOption
    case .percentRaised:
      self.selectedPercentRaisedBucketProperty.value = nil
    case .location:
      self.selectedLocationProperty.value = nil
    case .amountRaised:
      self.selectedAmountRaisedBucketProperty.value = nil
    }
  }

  public func selectedSortOption(_ sort: DiscoveryParams.Sort) {
    assert(
      self.sortOptions.contains(sort),
      "Selected a sort option that isn't actually available in SearchFiltersUseCase."
    )

    self.selectedSortProperty.value = sort
  }

  public func selectedCategory(_ selectedCategory: SearchFiltersCategory) {
    if let category = selectedCategory.category {
      let categories = self.categoriesProperty.value
      let subcategories = categories.lazy.flatMap { $0.subcategories?.nodes ?? [] }
      let exists = categories.contains(category) || subcategories.contains(category)
      if !exists {
        assert(false, "Selected category should be one of the categories set in SearchFiltersUseCase.")
      }
    }

    self.selectedCategoryProperty.value = selectedCategory
  }

  public func selectedProjectState(_ state: DiscoveryParams.State) {
    assert(
      self.stateOptions.contains(state),
      "Selected a state option that isn't actually available in SearchFiltersUseCase."
    )

    self.selectedStateProperty.value = state
  }

  public func selectedPercentRaisedBucket(_ bucket: DiscoveryParams.PercentRaisedBucket) {
    self.selectedPercentRaisedBucketProperty.value = bucket
  }

  public func filteredLocation(_ location: Location?) {
    self.selectedLocationProperty.value = location
  }

  public func selectedAmountRaisedBucket(_ bucket: DiscoveryParams.AmountRaisedBucket) {
    self.selectedAmountRaisedBucketProperty.value = bucket
  }

  public var inputs: SearchFiltersUseCaseInputs { return self }
  public var uiOutputs: SearchFiltersUseCaseUIOutputs { return self }
  public var dataOutputs: SearchFiltersUseCaseDataOutputs { return self }
}

private func filterModal(toShowForPill pill: SearchFilterPill.FilterType) -> SearchFilterModalType {
  let modalType: SearchFilterModalType
  switch pill {
  case .allFilters:
    modalType = .allFilters
  case .category:
    modalType = .category
  case .sort:
    modalType = .sort
  case .projectState:
    modalType = .allFilters
  case .percentRaised:
    modalType = .percentRaised
  case .location:
    modalType = .location
  case .amountRaised:
    modalType = .amountRaised
  }
  return modalType
}

public enum SearchFilterModalType: Hashable, CaseIterable {
  case allFilters
  case category
  case sort
  case percentRaised
  case location
  case amountRaised
}

private extension GraphAPI.LocationsByTermQuery.Data.Location {}
