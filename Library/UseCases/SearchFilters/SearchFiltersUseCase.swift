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
  /// Call this when the user updates a sort or filter option
  func selectedFilter(_ event: SearchFilterEvent)
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
  /// The currently selected filter location. Defaults to `nil`. Default value only sent after `initialSignal` occurs.
  var selectedLocation: Signal<Location?, Never> { get }
  /// The currently selected amount raised bucket. Defaults to `nil`. Default value only sent after `initialSignal` occurs.
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

    self.selectedSort = self.selectedSortProperty.signal(takeInitialValueWhen: initialSignal)
    self.selectedCategory = self.selectedCategoryProperty.signal(takeInitialValueWhen: initialSignal)
    self.selectedState = self.selectedStateProperty.signal(takeInitialValueWhen: initialSignal)
    self.selectedPercentRaisedBucket = self.selectedPercentRaisedBucketProperty
      .signal(takeInitialValueWhen: initialSignal)
    self.selectedLocation = self.selectedLocationProperty.signal(takeInitialValueWhen: initialSignal)
    self.selectedAmountRaisedBucket = self.selectedAmountRaisedBucketProperty
      .signal(takeInitialValueWhen: initialSignal)

    self.searchFilters = SearchFilters(
      sort: SearchFilters.SortOptions(
        sortOptions: self.sortOptions,
        selectedSort: self.selectedSortProperty.value
      ),
      category: SearchFilters.CategoryOptions(
        categories: self.categoriesProperty.value,
        selectedCategory: self.selectedCategoryProperty.value
      ),
      projectState: SearchFilters.ProjectStateOptions(
        stateOptions: self.stateOptions,
        selectedProjectState: self.selectedStateProperty.value
      ),
      percentRaised: SearchFilters.PercentRaisedOptions(
        buckets: DiscoveryParams.PercentRaisedBucket.allCases
      ),
      location: SearchFilters.LocationOptions(
        defaultLocations: self.defaultLocationsProperty.value,
        suggestedLocations: self.suggestedLocationsProperty.value
      ),
      amountRaised: SearchFilters.AmountRaisedOptions(
        buckets: DiscoveryParams.AmountRaisedBucket.allCases
      )
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

  public func selectedFilter(_ event: SearchFilterEvent) {
    switch event {
    case let .sort(sort):
      self.selectedSortProperty.value = sort
    case let .category(selectedCategory):
      self.selectedCategoryProperty.value = selectedCategory
    case let .projectState(state):
      self.selectedStateProperty.value = state
    case let .percentRaised(bucket):
      self.selectedPercentRaisedBucketProperty.value = bucket
    case let .amountRaised(bucket):
      self.selectedAmountRaisedBucketProperty.value = bucket
    case let .location(location):
      self.selectedLocationProperty.value = location
    }
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
  case .projectsWeLove:
    modalType = .allFilters
  case .saved:
    modalType = .allFilters
  case .following:
    modalType = .allFilters
  case .recommended:
    modalType = .allFilters
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

public enum SearchFilterEvent {
  case sort(DiscoveryParams.Sort)
  case category(SearchFiltersCategory)
  case projectState(DiscoveryParams.State)
  case percentRaised(DiscoveryParams.PercentRaisedBucket)
  case amountRaised(DiscoveryParams.AmountRaisedBucket)
  case location(Location?)
}

private extension GraphAPI.LocationsByTermQuery.Data.Location {}

private extension MutableProperty {
  /// Emits its current value when `takeInitialValueWhen` is sent, and whenever the value changes, too.
  /// Useful for turning a `MutableProperty` with a default value into a `signal`.
  func signal(takeInitialValueWhen initialSignal: Signal<Void, Never>) -> Signal<Value, Never> {
    return Signal.merge(
      self.producer.takeWhen(initialSignal),
      self.signal
    )
  }
}
