import KsApi
import ReactiveSwift

public protocol SearchFiltersUseCaseType {
  var inputs: SearchFiltersUseCaseInputs { get }
  var uiOutputs: SearchFiltersUseCaseUIOutputs { get }
  var dataOuputs: SearchFiltersUseCaseDataOutputs { get }
}

public protocol SearchFiltersUseCaseInputs {
  /// Call this when the user taps on a button to show the sort options.
  func tappedSort()
  /// Call this when the user taps on a button to show the category filters.
  func tappedCategoryFilter()
  /// Call this when the user selects a new sort option.
  func selectedSortOption(_ sort: DiscoveryParams.Sort)
  /// Call this when the user selects a new category.
  func selectedCategory(_ category: KsApi.Category?)
  /// Call this when the clears their query and the sort options should reset.
  func clearOptions()
}

public protocol SearchFiltersUseCaseUIOutputs {
  /// Sends a model object which can be used to display category filter options. Only sends if `categories` have also been sent.
  var showCategoryFilters: Signal<SearchFilterCategoriesSheet, Never> { get }
  /// Sends a model object which can be used to display sort options.
  var showSort: Signal<SearchSortSheet, Never> { get }

  // FIXME: MBL-2250
  // Wait! Before you add more pill configurations, refactor this.
  // The pills should be a more dynamic piece of UI, but I hard-coded the
  // two pills we needed to start.

  /// Whether or not to highlight the Sort option.
  var isSortPillHighlighted: Signal<Bool, Never> { get }

  /// The title for the category pill.
  var categoryPillTitle: Signal<String, Never> { get }

  /// Whether or not to highlight the Category option.
  var isCategoryPillHighlighted: Signal<Bool, Never> { get }
}

public protocol SearchFiltersUseCaseDataOutputs {
  /// The currently selected sort option. Defaults to `.popular`. Default value only sent after `initialSignal` occurs.
  var selectedSort: Signal<DiscoveryParams.Sort, Never> { get }
  /// The currently selected category. Defaults to nil. Default value only sent after `initialSignal` occurs.
  var selectedCategory: Signal<Category?, Never> { get }
}

public final class SearchFiltersUseCase: SearchFiltersUseCaseType, SearchFiltersUseCaseInputs,
  SearchFiltersUseCaseUIOutputs, SearchFiltersUseCaseDataOutputs {
  /// @param initialSignal - An initial signal pulse. Must be sent once for default values of `selectedSort` and `selectedCategory` to emit.
  /// @param categories - A list of possible filter categories. Must be sent for `showCategoryFilters` and `selectedSortOption` to work.

  public init(initialSignal: Signal<Void, Never>, categories: Signal<[KsApi.Category], Never>) {
    self.categoriesProperty <~ categories

    self.showCategoryFilters = self.selectedCategoryProperty.producer
      .takeWhen(self.tappedCategoryFilterSignal)
      .combineLatest(with: categories)
      .map { selectedCategory, categories -> SearchFilterCategoriesSheet in

        SearchFilterCategoriesSheet(
          categories: categories,
          selectedCategory: selectedCategory
        )
      }

    self.showSort = self.selectedSortProperty.producer
      .takeWhen(self.tappedSortSignal)
      .map { [sortOptions] sort -> SearchSortSheet in
        SearchSortSheet(sortOptions: sortOptions, selectedOption: sort)
      }

    self.selectedSort = Signal.merge(
      self.selectedSortProperty.producer.takeWhen(initialSignal),
      self.selectedSortProperty.signal
    )

    self.selectedCategory = Signal.merge(
      self.selectedCategoryProperty.producer.takeWhen(initialSignal),
      self.selectedCategoryProperty.signal
    )

    self.isSortPillHighlighted = self.selectedSort
      .map { sort in sort != SearchFiltersUseCase.defaultSortOption }

    self.categoryPillTitle = self.selectedCategory.map { category in
      if let name = category?.name {
        return name
      }

      return Strings.Category()
    }

    self.isCategoryPillHighlighted = self.selectedCategory.map { $0 != nil }
  }

  fileprivate let (tappedSortSignal, tappedSortObserver) = Signal<Void, Never>.pipe()
  public func tappedSort() {
    self.tappedSortObserver.send(value: ())
  }

  fileprivate let (tappedCategoryFilterSignal, tappedCategoryFilterObserver) = Signal<Void, Never>.pipe()
  public func tappedCategoryFilter() {
    if self.categoriesProperty.value.isEmpty {
      assert(false, "Tried to show category filter before categories have downloaded.")
      return
    }
    self.tappedCategoryFilterObserver.send(value: ())
  }

  fileprivate let selectedSortProperty = MutableProperty<DiscoveryParams.Sort>(
    SearchFiltersUseCase
      .defaultSortOption
  )
  fileprivate let selectedCategoryProperty = MutableProperty<Category?>(nil)

  // Used for some extra sanity assertions.
  fileprivate let categoriesProperty = MutableProperty<[Category]>([])

  fileprivate static let defaultSortOption = DiscoveryParams.Sort.magic

  fileprivate let sortOptions = [
    DiscoveryParams.Sort.magic, // aka Recommended
    DiscoveryParams.Sort.popular,
    DiscoveryParams.Sort.newest,
    DiscoveryParams.Sort.endingSoon,
    DiscoveryParams.Sort.most_funded,
    DiscoveryParams.Sort.most_backed
  ]

  public let showCategoryFilters: Signal<SearchFilterCategoriesSheet, Never>
  public let showSort: Signal<SearchSortSheet, Never>

  public let isSortPillHighlighted: Signal<Bool, Never>
  public let categoryPillTitle: Signal<String, Never>
  public let isCategoryPillHighlighted: Signal<Bool, Never>

  public var selectedSort: Signal<DiscoveryParams.Sort, Never>
  public var selectedCategory: Signal<Category?, Never>

  public func clearOptions() {
    self.selectedSortProperty.value = SearchFiltersUseCase.defaultSortOption
    self.selectedCategoryProperty.value = nil
  }

  public func selectedSortOption(_ sort: DiscoveryParams.Sort) {
    assert(
      self.sortOptions.contains(sort),
      "Selected a sort option that isn't actually available in SearchFiltersUseCase."
    )

    self.selectedSortProperty.value = sort
  }

  public func selectedCategory(_ maybeCategory: Category?) {
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

  public var inputs: SearchFiltersUseCaseInputs { return self }
  public var uiOutputs: SearchFiltersUseCaseUIOutputs { return self }
  public var dataOuputs: SearchFiltersUseCaseDataOutputs { return self }
}

public struct SearchFilterCategoriesSheet {
  public let categories: [KsApi.Category]
  public let selectedCategory: Category?
}

public struct SearchSortSheet {
  public let sortOptions: [DiscoveryParams.Sort]
  public let selectedOption: DiscoveryParams.Sort
}
