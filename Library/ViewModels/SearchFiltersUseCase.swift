import KsApi
import ReactiveSwift

public struct SearchFilterCategoriesSheet {
  let categoryNames: [String]
  let selectedIndex: Int?
}

public struct SearchSortSheet {
  let sortNames: [String]
  let selectedIndex: Int
}

public protocol SearchFiltersUseCaseType {
  var inputs: SearchFiltersUseCaseInputs { get }
  var uiOutputs: SearchFiltersUseCaseUIOutputs { get }
  var dataOuputs: SearchFiltersUseCaseDataOutputs { get }
}

public protocol SearchFiltersUseCaseInputs {
  func tappedSort()
  func tappedCategoryFilter()
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

public protocol SearchFiltersUseCaseDataOutputs {}

public final class SearchFiltersUseCase: SearchFiltersUseCaseType, SearchFiltersUseCaseInputs,
  SearchFiltersUseCaseUIOutputs, SearchFiltersUseCaseDataOutputs {
  public init(initialSignal: Signal<Void, Never>) {
    self.categoriesUseCase = FetchCategoriesUseCase(initialSignal: initialSignal)

    let sortOptions: [DiscoveryParams.Sort] = [
      DiscoveryParams.Sort.endingSoon,
      DiscoveryParams.Sort.magic,
      DiscoveryParams.Sort.popular,
      DiscoveryParams.Sort.newest
    ]

    let sortNames = sortOptions.map(sortOptionName(from:))

    self.showSort = self.selectedSortProperty.signal
      .takeWhen(self.tappedSortSignal)
      .map { sort -> SearchSortSheet? in
        guard let selectedIndex = sortOptions.firstIndex(of: sort) else {
          return nil
        }
        return SearchSortSheet(sortNames: sortNames, selectedIndex: selectedIndex)
      }
      .skipNil()

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
  }

  fileprivate let (tappedSortSignal, tappedSortObserver) = Signal<Void, Never>.pipe()
  public func tappedSort() {
    self.tappedSortObserver.send(value: ())
  }

  fileprivate let (tappedCategoryFilterSignal, tappedCategoryFilterObserver) = Signal<Void, Never>.pipe()
  public func tappedCategoryFilter() {
    self.tappedCategoryFilterObserver.send(value: ())
  }

  fileprivate let categoriesUseCase: FetchCategoriesUseCase

  fileprivate let selectedSortProperty = MutableProperty<DiscoveryParams.Sort>(.magic)
  fileprivate let selectedCategoryFilterProperty = MutableProperty<Int?>(nil)

  public let showCategoryFilters: Signal<SearchFilterCategoriesSheet, Never>
  public let showSort: Signal<SearchSortSheet, Never>

  public var inputs: SearchFiltersUseCaseInputs { return self }
  public var uiOutputs: SearchFiltersUseCaseUIOutputs { return self }
  public var dataOuputs: SearchFiltersUseCaseDataOutputs { return self }
}
