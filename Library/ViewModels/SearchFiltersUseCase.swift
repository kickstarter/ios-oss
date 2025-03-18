import KsApi
import ReactiveSwift

public struct SearchFilterCategoriesSheet {
  public let categoryNames: [String]
  public let selectedIndex: Int?
}

public struct SearchSortSheet {
  public let sortNames: [String]
  public let selectedIndex: Int
}

public protocol SearchFiltersUseCaseType {
  var inputs: SearchFiltersUseCaseInputs { get }
  var uiOutputs: SearchFiltersUseCaseUIOutputs { get }
  var dataOuputs: SearchFiltersUseCaseDataOutputs { get }
}

public protocol SearchFiltersUseCaseInputs {
  func tappedSort()
  func tappedCategoryFilter()

  func selectedSortOption(atIndex: Int)
}

public protocol SearchFiltersUseCaseUIOutputs {
  var showCategoryFilters: Signal<SearchFilterCategoriesSheet, Never> { get }
  var showSort: Signal<SearchSortSheet, Never> { get }
}

private func sortOptionName(from sort: DiscoveryParams.Sort) -> String {
  // TODO: translations
  switch sort {
  case .endingSoon:
    return "Ending Soon"
  case .magic:
    return "Magic"
  case .newest:
    return "Newest"
  case .popular:
    return "Popular"
  }
}

public protocol SearchFiltersUseCaseDataOutputs {
  var selectedSort: Signal<DiscoveryParams.Sort, Never> { get }
  var selectedCategory: Signal<Category?, Never> { get }
}

public final class SearchFiltersUseCase: SearchFiltersUseCaseType, SearchFiltersUseCaseInputs,
  SearchFiltersUseCaseUIOutputs, SearchFiltersUseCaseDataOutputs {
  public init(initialSignal: Signal<Void, Never>) {
    self.initialSignal = initialSignal

    self.sortOptions = [
      DiscoveryParams.Sort.popular,
      DiscoveryParams.Sort.endingSoon,
      DiscoveryParams.Sort.magic,
      DiscoveryParams.Sort.newest
    ]

    self.categoriesUseCase = FetchCategoriesUseCase(initialSignal: initialSignal)

    self.showCategoryFilters = self.selectedCategoryIndexProperty.producer
      .takeWhen(self.tappedCategoryFilterSignal)
      .combineLatest(with: self.categoriesUseCase.categories)
      .map { selectedIdx, categories -> SearchFilterCategoriesSheet? in
        let names = categories.map { $0.name }

        return SearchFilterCategoriesSheet(
          categoryNames: names,
          selectedIndex: selectedIdx
        )
      }
      .skipNil()

    self.showSort = self.selectedSortIndexProperty.producer
      .takeWhen(self.tappedSortSignal)
      .map { [sortOptions] selectedIdx -> SearchSortSheet? in
        let names = sortOptions.map(sortOptionName(from:))

        return SearchSortSheet(sortNames: names, selectedIndex: selectedIdx)
      }
      .skipNil()

    self.selectedSort = Signal.merge(
      self.selectedSortIndexProperty.producer.takeWhen(self.initialSignal),
      self.selectedSortIndexProperty.signal
    )
    .map { [sortOptions] idx in
      sortOptions[idx]
    }

    self.selectedCategory = Signal.merge(
      self.selectedCategoryIndexProperty.producer.takeWhen(self.initialSignal),
      self.selectedCategoryIndexProperty.signal
    )
    .combineLatest(with: self.categoriesUseCase.categories)
    .map { idx, categories in
      guard let idx = idx else {
        return nil
      }

      return categories[idx]
    }
  }

  fileprivate let sortOptions: [DiscoveryParams.Sort]
  fileprivate let initialSignal: Signal<Void, Never>

  fileprivate let (tappedSortSignal, tappedSortObserver) = Signal<Void, Never>.pipe()
  public func tappedSort() {
    self.tappedSortObserver.send(value: ())
  }

  fileprivate let (tappedCategoryFilterSignal, tappedCategoryFilterObserver) = Signal<Void, Never>.pipe()
  public func tappedCategoryFilter() {
    self.tappedCategoryFilterObserver.send(value: ())
  }

  fileprivate let categoriesUseCase: FetchCategoriesUseCase

  fileprivate let selectedSortIndexProperty = MutableProperty<Int>(0)
  fileprivate let selectedCategoryIndexProperty = MutableProperty<Int?>(nil)

  public let showCategoryFilters: Signal<SearchFilterCategoriesSheet, Never>
  public let showSort: Signal<SearchSortSheet, Never>

  public var selectedSort: Signal<DiscoveryParams.Sort, Never>
  public var selectedCategory: Signal<Category?, Never>

  public func selectedSortOption(atIndex index: Int) {
    self.selectedSortIndexProperty.value = index
  }

  public func selectedCategory(atIndex index: Int) {
    self.selectedCategoryIndexProperty.value = index
  }

  public var inputs: SearchFiltersUseCaseInputs { return self }
  public var uiOutputs: SearchFiltersUseCaseUIOutputs { return self }
  public var dataOuputs: SearchFiltersUseCaseDataOutputs { return self }
}
