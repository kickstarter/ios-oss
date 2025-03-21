@testable import KsApi
@testable import Library
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class SearchFiltersUseCaseTests: TestCase {
  private var useCase: SearchFiltersUseCase!

  private let selectedSort = TestObserver<DiscoveryParams.Sort, Never>()
  private let selectedCategory = TestObserver<KsApi.Category?, Never>()
  private let showCategoryFilters = TestObserver<SearchFilterCategoriesSheet, Never>()
  private let showSort = TestObserver<SearchSortSheet, Never>()

  private let (initialSignal, initialObserver) = Signal<Void, Never>.pipe()
  private let (categoriesSignal, categoriesObserver) = Signal<[KsApi.Category], Never>.pipe()

  override func setUp() {
    super.setUp()

    self.useCase = SearchFiltersUseCase(
      initialSignal: self.initialSignal,
      categories: self.categoriesSignal
    )

    self.useCase.dataOuputs.selectedCategory.observe(self.selectedCategory.observer)
    self.useCase.dataOuputs.selectedSort.observe(self.selectedSort.observer)
    self.useCase.uiOutputs.showCategoryFilters.observe(self.showCategoryFilters.observer)
    self.useCase.uiOutputs.showSort.observe(self.showSort.observer)
  }

  func test_category_onInitialSignal_isNil() {
    self.selectedCategory.assertDidNotEmitValue()

    self.initialObserver.send(value: ())

    self.selectedCategory.assertLastValue(nil)
  }

  func test_sort_onInitialSignal_isPopular() {
    self.selectedSort.assertDidNotEmitValue()

    self.initialObserver.send(value: ())

    self.selectedSort.assertLastValue(.popular)
  }

  func test_tappedSort_showsSortOptions() {
    self.initialObserver.send(value: ())

    self.showSort.assertDidNotEmitValue()

    self.useCase.inputs.tappedSort()

    self.showSort.assertDidEmitValue()

    if let sortOptions = self.showSort.lastValue {
      XCTAssertEqual(
        sortOptions.selectedOption,
        .popular,
        "First option, popular, should be selected by default"
      )
      XCTAssertGreaterThan(sortOptions.sortOptions.count, 0, "There should be multiple sort options")
    }
  }

  func test_tappedCategories_showsCategoryFilters() {
    self.initialObserver.send(value: ())
    self.categoriesObserver.send(value: [
      .art,
      .illustration,
      .documentary,
      .tabletopGames
    ])

    self.showCategoryFilters.assertDidNotEmitValue()

    self.useCase.inputs.tappedCategoryFilter()

    self.showCategoryFilters.assertDidEmitValue()

    if let categoryOptions = self.showCategoryFilters.lastValue {
      XCTAssertEqual(categoryOptions.selectedCategory, nil, "No category should be selected by default")
      XCTAssertEqual(
        categoryOptions.categories.count,
        4,
        "The sheet should show categories that were loaded"
      )
    }
  }

  func test_selectingCategory_updatesCategory() {
    self.initialObserver.send(value: ())

    let categories: [KsApi.Category] = [
      .art,
      .illustration,
      .documentary,
      .tabletopGames
    ]

    self.categoriesObserver.send(value: categories)

    self.showCategoryFilters.assertDidNotEmitValue()
    self.selectedCategory.assertLastValue(nil)

    self.useCase.inputs.tappedCategoryFilter()
    self.showCategoryFilters.assertDidEmitValue()

    self.useCase.inputs.selectedCategory(.art)

    guard let newCategory = self.selectedCategory.lastValue else {
      XCTFail("There should be a new selected category")
      return
    }

    XCTAssertEqual(newCategory, categories[0], "Should have selected the first category in the list")
  }

  func test_selectingSort_updatesSort() {
    self.initialObserver.send(value: ())

    self.showSort.assertDidNotEmitValue()
    self.selectedSort.assertLastValue(.popular)

    self.useCase.inputs.tappedSort()
    self.showSort.assertDidEmitValue()

    self.useCase.inputs.selectedSortOption(.endingSoon)

    guard let newSelectedSort = self.selectedSort.lastValue else {
      XCTFail("There should be a new selected sort option")
      return
    }

    XCTAssertEqual(newSelectedSort, .endingSoon, "Sort value should change when new sort is selected")
  }
}
