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
}

public final class SearchFiltersUseCase: SearchFiltersUseCaseType, SearchFiltersUseCaseInputs,
  SearchFiltersUseCaseUIOutputs, SearchFiltersUseCaseDataOutputs {
  public init(initialSignal: Signal<Void, Never>) {
    let sortOptions: [DiscoveryParams.Sort] = [
      DiscoveryParams.Sort.popular,
      DiscoveryParams.Sort.endingSoon,
      DiscoveryParams.Sort.magic,
      DiscoveryParams.Sort.newest
    ]

    self.categoriesUseCase = FetchCategoriesUseCase(initialSignal: initialSignal)

    let sortNames = sortOptions.map(sortOptionName(from:))

    self.showCategoryFilters = self.selectedCategoryFilterProperty.signal
      .takeWhen(self.tappedCategoryFilterSignal)
      .combineLatest(with: self.categoriesUseCase.categories)
      .map { categoryId, categories -> SearchFilterCategoriesSheet? in
        let names = categories.map { $0.name }
        let selectedIdx = categories.firstIndex(where: { $0.intID == categoryId })

        return SearchFilterCategoriesSheet(
          categoryNames: names,
          selectedIndex: selectedIdx
        )
      }
      .skipNil()

    // TODO: Signal problems here. Really want to compose this better.

    self.showSort = self.selectedSortProperty.producer
      .takeWhen(self.tappedSortSignal)
      .map { sort -> SearchSortSheet? in
        guard let selectedIndex = sortOptions.firstIndex(of: sort) else {
          return nil
        }
        return SearchSortSheet(sortNames: sortNames, selectedIndex: selectedIndex)
      }
      .skipNil()
  }

  fileprivate let sortOptions: [DiscoveryParams.Sort] = [
    DiscoveryParams.Sort.popular,
    DiscoveryParams.Sort.endingSoon,
    DiscoveryParams.Sort.magic,
    DiscoveryParams.Sort.newest
  ]

  fileprivate let (tappedSortSignal, tappedSortObserver) = Signal<Void, Never>.pipe()
  public func tappedSort() {
    self.tappedSortObserver.send(value: ())
  }

  fileprivate let (tappedCategoryFilterSignal, tappedCategoryFilterObserver) = Signal<Void, Never>.pipe()
  public func tappedCategoryFilter() {
    self.tappedCategoryFilterObserver.send(value: ())
  }

  fileprivate let categoriesUseCase: FetchCategoriesUseCase

  fileprivate let selectedSortProperty = MutableProperty<DiscoveryParams.Sort>(.popular)
  fileprivate let selectedCategoryFilterProperty = MutableProperty<Int?>(nil)

  public let showCategoryFilters: Signal<SearchFilterCategoriesSheet, Never>
  public let showSort: Signal<SearchSortSheet, Never>

  public var selectedSort: Signal<DiscoveryParams.Sort, Never> {
    return self.selectedSortProperty.signal
  }

  public func selectedSortOption(atIndex index: Int) {
    let newSort = self.sortOptions[index]
    self.selectedSortProperty.value = newSort
  }

  public var inputs: SearchFiltersUseCaseInputs { return self }
  public var uiOutputs: SearchFiltersUseCaseUIOutputs { return self }
  public var dataOuputs: SearchFiltersUseCaseDataOutputs { return self }
}
