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
  func selectedSortOption(atIndex: Int)
  /// Call this when the user selects a new category.
  func selectedCategory(atIndex index: Int)
}

public protocol SearchFiltersUseCaseUIOutputs {
  /// Sends a model object which can be used to display category filter options. Only sends if `categories` have also been sent.
  var showCategoryFilters: Signal<SearchFilterCategoriesSheet, Never> { get }
  /// Sends a model object which can be used to display sort options.
  var showSort: Signal<SearchSortSheet, Never> { get }
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

    self.showCategoryFilters = self.selectedCategoryIndexProperty.producer
      .takeWhen(self.tappedCategoryFilterSignal)
      .combineLatest(with: categories)
      .map { selectedIdx, categories -> SearchFilterCategoriesSheet in
        let names = categories.map { $0.name }

        return SearchFilterCategoriesSheet(
          categoryNames: names,
          selectedIndex: selectedIdx
        )
      }

    self.showSort = self.selectedSortIndexProperty.producer
      .takeWhen(self.tappedSortSignal)
      .map { [sortOptions] selectedIdx -> SearchSortSheet in
        let names = sortOptions.map(sortOptionName(from:))

        return SearchSortSheet(sortNames: names, selectedIndex: selectedIdx)
      }

    self.selectedSort = Signal.merge(
      self.selectedSortIndexProperty.producer.takeWhen(initialSignal),
      self.selectedSortIndexProperty.signal
    )
    .map { [sortOptions] idx in
      sortOptions[idx]
    }

    // This bit of complication is here because we want this use case to emit a
    // selectedCategory of nil on the initial signal - even if no categories have been downloaded yet.
    // So if the index is nil, just immediately emit nil.

    let selectedCategoryIndex = Signal.merge(
      self.selectedCategoryIndexProperty.producer.takeWhen(initialSignal),
      self.selectedCategoryIndexProperty.signal
    )

    let categoryIsNilIfIndexIsNil: Signal<Category?, Never> = selectedCategoryIndex
      .filter { $0 == nil }
      .map { _ in
        nil
      }

    let categoryIfIndexIsNotNil: Signal<Category?, Never> = selectedCategoryIndex
      .skipNil()
      .combineLatest(with: categories)
      .map { idx, categories -> Category? in

        guard idx < categories.count else {
          assert(false, "Selected category is out of bounds. This shouldn't be possible.")
          return nil
        }

        return categories[idx]
      }

    self.selectedCategory = Signal.merge(
      categoryIsNilIfIndexIsNil,
      categoryIfIndexIsNotNil
    )
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

  fileprivate let selectedSortIndexProperty = MutableProperty<Int>(0)
  fileprivate let selectedCategoryIndexProperty = MutableProperty<Int?>(nil)

  // Used for some extra assertions to make sure categories have loaded.
  fileprivate let categoriesProperty = MutableProperty<[Category]>([])
  fileprivate let sortOptions = [
    DiscoveryParams.Sort.popular,
    DiscoveryParams.Sort.endingSoon,
    DiscoveryParams.Sort.magic,
    DiscoveryParams.Sort.newest
  ]

  public let showCategoryFilters: Signal<SearchFilterCategoriesSheet, Never>
  public let showSort: Signal<SearchSortSheet, Never>

  public var selectedSort: Signal<DiscoveryParams.Sort, Never>
  public var selectedCategory: Signal<Category?, Never>

  public func selectedSortOption(atIndex index: Int) {
    self.selectedSortIndexProperty.value = index
  }

  public func selectedCategory(atIndex index: Int) {
    if self.categoriesProperty.value.isEmpty {
      assert(false, "Tried to select a category before categories have downloaded.")
      return
    }

    self.selectedCategoryIndexProperty.value = index
  }

  public var inputs: SearchFiltersUseCaseInputs { return self }
  public var uiOutputs: SearchFiltersUseCaseUIOutputs { return self }
  public var dataOuputs: SearchFiltersUseCaseDataOutputs { return self }
}

// FIXME: These will be the data models used by the actual sort + filter models.
// For now, here's a couple simple structs that can be used to show a UIAlertController.
public struct SearchFilterCategoriesSheet {
  public let categoryNames: [String]
  public let selectedIndex: Int?
}

public struct SearchSortSheet {
  public let sortNames: [String]
  public let selectedIndex: Int
}

private func sortOptionName(from sort: DiscoveryParams.Sort) -> String {
  switch sort {
  case .endingSoon:
    return Strings.discovery_sort_types_end_date()
  case .magic:
    return Strings.discovery_sort_types_magic()
  case .newest:
    return Strings.discovery_sort_types_newest()
  case .popular:
    return Strings.discovery_sort_types_popularity()
  }
}
