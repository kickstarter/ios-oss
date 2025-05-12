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
  /// Call this when the user taps reset on a filter modal
  func resetFilters(for: SearchFilterModalType)
}

public protocol SearchFiltersUseCaseUIOutputs {
  /// Sends a model object which can be used to display all filter options, and a type describing which filters to display.
  var showFilters: Signal<(SearchFilterOptions, SearchFilterModalType), Never> { get }

  /// An @ObservableObject model which SwiftUI can use to observe the selected filters. Owned and automatically updated by this use case.
  var selectedFilters: SelectedSearchFilters { get }
}

public protocol SearchFiltersUseCaseDataOutputs {
  /// The currently selected sort option. Defaults to `.popular`. Default value only sent after `initialSignal` occurs.
  var selectedSort: Signal<DiscoveryParams.Sort, Never> { get }
  /// The currently selected category. Defaults to nil. Default value only sent after `initialSignal` occurs.
  var selectedCategory: Signal<SearchFiltersCategory, Never> { get }
  /// The currently selected project state. Defaults to `.all`. Default value only sent after `initialSignal` occurs.
  var selectedState: Signal<DiscoveryParams.State, Never> { get }
}

public final class SearchFiltersUseCase: SearchFiltersUseCaseType, SearchFiltersUseCaseInputs,
  SearchFiltersUseCaseUIOutputs, SearchFiltersUseCaseDataOutputs {
  /// @param initialSignal - An initial signal pulse. Must be sent once for default values of `selectedSort` and `selectedCategory` to emit.
  /// @param categories - A list of possible filter categories. Must be sent for `showCategoryFilters` and `selectedSortOption` to work.

  public init(initialSignal: Signal<Void, Never>, categories: Signal<[KsApi.Category], Never>) {
    self.categoriesProperty <~ categories

    self.showFilters = self.categoriesProperty.producer
      .takePairWhen(self.tappedFilterTypeSignal)
      .map { [sortOptions, stateOptions] categories, pill in
        let options = SearchFilterOptions(
          category: SearchFilterOptions.CategoryOptions(
            categories: categories
          ),
          sort: SearchFilterOptions.SortOptions(
            sortOptions: sortOptions
          ),
          projectState: SearchFilterOptions.ProjectStateOptions(
            stateOptions: stateOptions
          )
        )

        let modalType = filterModal(toShowForPill: pill)

        return (options, modalType)
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

    self.selectedFilters = SelectedSearchFilters(
      sort: self.selectedSortProperty.value,
      category: self.selectedCategoryProperty.value,
      projectState: self.selectedStateProperty.value
    )

    Signal.combineLatest(
      self.dataOutputs.selectedSort,
      self.dataOutputs.selectedCategory,
      self.dataOutputs.selectedState
    )
    .observeForUI()
    .observeValues { [weak selectedFilters] sort, category, state in
      selectedFilters?.update(withSort: sort, category: category, projectState: state)
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

  // Used for some extra sanity assertions.
  fileprivate let categoriesProperty = MutableProperty<[KsApi.Category]>([])

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

  public var showFilters: Signal<(SearchFilterOptions, SearchFilterModalType), Never>

  public var selectedSort: Signal<DiscoveryParams.Sort, Never>
  public var selectedCategory: Signal<SearchFiltersCategory, Never>
  public var selectedState: Signal<DiscoveryParams.State, Never>

  public private(set) var selectedFilters: SelectedSearchFilters

  public func clearedQueryText() {
    self.selectedSortProperty.value = SearchFiltersUseCase.defaultSortOption
    self.selectedCategoryProperty.value = .none
    self.selectedStateProperty.value = SearchFiltersUseCase.defaultStateOption
  }

  public func resetFilters(for modal: SearchFilterModalType) {
    switch modal {
    case .allFilters:
      // Sort isn't a filter, so it's not included here.
      self.selectedCategoryProperty.value = .none
      self.selectedStateProperty.value = SearchFiltersUseCase.defaultStateOption
    case .category:
      self.selectedCategoryProperty.value = .none
    case .sort:
      self.selectedSortProperty.value = SearchFiltersUseCase.defaultSortOption
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
  }
  return modalType
}

public enum SearchFilterModalType: Hashable {
  case allFilters
  case category
  case sort
}
