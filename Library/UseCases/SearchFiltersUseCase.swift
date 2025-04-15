import KsApi
import ReactiveSwift
import UIKit

public protocol SearchFiltersUseCaseType {
  var inputs: SearchFiltersUseCaseInputs { get }
  var uiOutputs: SearchFiltersUseCaseUIOutputs { get }
  var dataOuputs: SearchFiltersUseCaseDataOutputs { get }
}

public protocol SearchFiltersUseCaseInputs {
  /// Call this when the user taps on a button to show one of the sort options.
  func tappedButton(forFilterType: SearchFilterPill.FilterType)
  /// Call this when the user selects a new sort option.
  func selectedSortOption(_ sort: DiscoveryParams.Sort)
  /// Call this when the user selects a new category.
  func selectedCategory(_ category: KsApi.Category?)
  /// Call this when the user selects a new project state filter.
  func selectedProjectState(_ state: DiscoveryParams.State)
  /// Call this when the clears their query and the sort options should reset.
  func clearOptions()
}

public protocol SearchFiltersUseCaseUIOutputs {
  /// Sends a model object which can be used to display all filter options, and a type describing which filters to display.
  var showFilters: Signal<(SearchFilterOptions, SearchFilterModalType), Never> { get }
  /// Sends an array of model objects which represent filter options, to be displayed in the search filter header.
  var pills: Signal<[SearchFilterPill], Never> { get }
}

public protocol SearchFiltersUseCaseDataOutputs {
  /// The currently selected sort option. Defaults to `.popular`. Default value only sent after `initialSignal` occurs.
  var selectedSort: Signal<DiscoveryParams.Sort, Never> { get }
  /// The currently selected category. Defaults to nil. Default value only sent after `initialSignal` occurs.
  var selectedCategory: Signal<KsApi.Category?, Never> { get }
  /// The currently selected project state. Defaults to `.all`. Default value only sent after `initialSignal` occurs.
  var selectedState: Signal<DiscoveryParams.State, Never> { get }
}

public final class SearchFiltersUseCase: SearchFiltersUseCaseType, SearchFiltersUseCaseInputs,
  SearchFiltersUseCaseUIOutputs, SearchFiltersUseCaseDataOutputs {
  /// @param initialSignal - An initial signal pulse. Must be sent once for default values of `selectedSort` and `selectedCategory` to emit.
  /// @param categories - A list of possible filter categories. Must be sent for `showCategoryFilters` and `selectedSortOption` to work.

  public init(initialSignal: Signal<Void, Never>, categories: Signal<[KsApi.Category], Never>) {
    self.categoriesProperty <~ categories

    self.showFilters = SignalProducer.combineLatest(
      self.categoriesProperty.producer,
      self.selectedCategoryProperty.producer,
      self.selectedSortProperty.producer,
      self.selectedStateProperty.producer
    )
    .takePairWhen(self.tappedFilterTypeSignal)
    .map { a, b in (a.0, a.1, a.2, a.3, b) }
    .map { [sortOptions, stateOptions] categories, category, sort, state, pill in
      let options = SearchFilterOptions(
        category: SearchFilterOptions.CategoryOptions(
          categories: categories,
          selectedCategory: category
        ),
        sort: SearchFilterOptions.SortOptions(
          sortOptions: sortOptions,
          selectedOption: sort
        ),
        projectState: SearchFilterOptions.ProjectStateOptions(
          stateOptions: stateOptions,
          selectedOption: state
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

    self.pills = Signal.combineLatest(self.selectedSort, self.selectedCategory, self.selectedState)
      .map { sort, category, state in
        filterPills(fromSelectedSort: sort, category: category, state: state)
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
  fileprivate let selectedCategoryProperty = MutableProperty<KsApi.Category?>(nil)
  fileprivate let selectedStateProperty = MutableProperty<DiscoveryParams.State>(
    SearchFiltersUseCase
      .defaultStateOption
  )

  // Used for some extra sanity assertions.
  fileprivate let categoriesProperty = MutableProperty<[KsApi.Category]>([])

  fileprivate static let defaultSortOption = DiscoveryParams.Sort.magic

  fileprivate let sortOptions = [
    DiscoveryParams.Sort.magic, // aka Recommended
    DiscoveryParams.Sort.popular,
    DiscoveryParams.Sort.newest,
    DiscoveryParams.Sort.endingSoon,
    DiscoveryParams.Sort.most_funded,
    DiscoveryParams.Sort.most_backed
  ]

  fileprivate static let defaultStateOption = DiscoveryParams.State.all

  fileprivate let stateOptions = [
    DiscoveryParams.State.all,
    DiscoveryParams.State.live,
    DiscoveryParams.State.late_pledge,
    DiscoveryParams.State.upcoming,
    DiscoveryParams.State.successful
  ]

  public var showFilters: Signal<(SearchFilterOptions, SearchFilterModalType), Never>
  public let pills: Signal<[SearchFilterPill], Never>

  public var selectedSort: Signal<DiscoveryParams.Sort, Never>
  public var selectedCategory: Signal<KsApi.Category?, Never>
  public var selectedState: Signal<DiscoveryParams.State, Never>

  public func clearOptions() {
    self.selectedSortProperty.value = SearchFiltersUseCase.defaultSortOption
    self.selectedCategoryProperty.value = nil
    self.selectedStateProperty.value = SearchFiltersUseCase.defaultStateOption
  }

  public func selectedSortOption(_ sort: DiscoveryParams.Sort) {
    assert(
      self.sortOptions.contains(sort),
      "Selected a sort option that isn't actually available in SearchFiltersUseCase."
    )

    self.selectedSortProperty.value = sort
  }

  public func selectedCategory(_ maybeCategory: KsApi.Category?) {
    guard let category = maybeCategory else {
      self.selectedCategoryProperty.value = nil
      return
    }

    let index = self.categoriesProperty.value.firstIndex(of: category)
    if index == nil {
      assert(false, "Selected category should be one of the categories set in SearchFiltersUseCase.")
    }

    self.selectedCategoryProperty.value = category
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
  public var dataOuputs: SearchFiltersUseCaseDataOutputs { return self }
}

private func filterPills(
  fromSelectedSort sort: DiscoveryParams.Sort,
  category: KsApi.Category?,
  state: DiscoveryParams.State
) -> [SearchFilterPill] {
  let hasCategory = category != nil
  let hasState = state != SearchFiltersUseCase.defaultStateOption

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
      // FIXME: MBL-2218 Use the real filter icon.
      buttonType: .image("star-small-icon")
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
        // FIXME: MBL-2218 Turn the state into a user-readable title.
        buttonType: .dropdown(state.rawValue)
      )
    )
  }

  return pills
}

private func filterModal(toShowForPill pill: SearchFilterPill.FilterType) -> SearchFilterModalType {
  let modalType: SearchFilterModalType
  switch pill {
  case .all:
    modalType = .all
  case .category:
    modalType = .category
  case .sort:
    modalType = .sort
  case .projectState:
    modalType = .all
  }
  return modalType
}

public enum SearchFilterModalType {
  case all
  case category
  case sort
}

public struct SearchFilterOptions {
  public struct CategoryOptions {
    public let categories: [KsApi.Category]
    public let selectedCategory: KsApi.Category?
  }

  public struct SortOptions {
    public let sortOptions: [DiscoveryParams.Sort]
    public let selectedOption: DiscoveryParams.Sort
  }

  public struct ProjectStateOptions {
    public let stateOptions: [DiscoveryParams.State]
    public let selectedOption: DiscoveryParams.State
  }

  public let category: CategoryOptions
  public let sort: SortOptions
  public let projectState: ProjectStateOptions
}
