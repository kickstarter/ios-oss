@testable import KsApi
@testable import Library
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class SearchFiltersUseCaseTests: TestCase {
  private var useCase: SearchFiltersUseCase!

  private let selectedSort = TestObserver<DiscoveryParams.Sort, Never>()
  private let selectedCategory = TestObserver<KsApi.Category?, Never>()
  private let selectedState = TestObserver<DiscoveryParams.State, Never>()
  private let showCategoryFilters = TestObserver<SearchFilterCategoriesSheet, Never>()
  private let showSort = TestObserver<SearchSortSheet, Never>()
  private let pills = TestObserver<[SearchFilterPill], Never>()
  private let categoryPill = TestObserver<SearchFilterPill, Never>()
  private let sortPill = TestObserver<SearchFilterPill, Never>()

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
    self.useCase.dataOuputs.selectedState.observe(self.selectedState.observer)
    self.useCase.uiOutputs.showCategoryFilters.observe(self.showCategoryFilters.observer)
    self.useCase.uiOutputs.showSort.observe(self.showSort.observer)
    self.useCase.uiOutputs.pills.observe(self.pills.observer)
    self.useCase.uiOutputs.pills.map { pills in
      pills.first(where: { $0.filterType == .sort })
    }.skipNil().observe(self.sortPill.observer)
    self.useCase.uiOutputs.pills.map { pills in
      pills.first(where: { $0.filterType == .category })
    }.skipNil().observe(self.categoryPill.observer)
  }

  func test_category_onInitialSignal_isNil() {
    self.selectedCategory.assertDidNotEmitValue()

    self.initialObserver.send(value: ())

    self.selectedCategory.assertLastValue(nil)
  }

  func test_sort_onInitialSignal_isRecommended() {
    self.selectedSort.assertDidNotEmitValue()

    self.initialObserver.send(value: ())

    self.selectedSort.assertLastValue(.magic)
  }

  func test_state_onInitialSignal_isAll() {
    self.selectedState.assertDidNotEmitValue()

    self.initialObserver.send(value: ())

    self.selectedState.assertLastValue(.all)
  }

  func test_tappedSort_showsSortOptions() {
    self.initialObserver.send(value: ())

    self.showSort.assertDidNotEmitValue()

    self.useCase.inputs.tappedSort()

    self.showSort.assertDidEmitValue()

    if let sortOptions = self.showSort.lastValue {
      XCTAssertEqual(
        sortOptions.selectedOption,
        .magic,
        "First option, magic, should be selected by default"
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
    self.selectedSort.assertLastValue(.magic)

    self.useCase.inputs.tappedSort()
    self.showSort.assertDidEmitValue()

    self.useCase.inputs.selectedSortOption(.endingSoon)

    guard let newSelectedSort = self.selectedSort.lastValue else {
      XCTFail("There should be a new selected sort option")
      return
    }

    XCTAssertEqual(newSelectedSort, .endingSoon, "Sort value should change when new sort is selected")
  }

  func test_selectingState_updatesState() {
    self.initialObserver.send(value: ())

    self.selectedState.assertLastValue(.all)

    self.useCase.inputs.selectedProjectState(.late_pledge)

    guard let newSelectedState = self.selectedState.lastValue else {
      XCTFail("There should be a new selected state")
      return
    }

    XCTAssertEqual(newSelectedState, .late_pledge, "State value should change when new state is selected")
  }

  func test_selectingSort_updatesSortPill() {
    self.initialObserver.send(value: ())

    self.selectedSort.assertLastValue(.magic)

    self.sortPill.assertDidEmitValue()
    XCTAssertEqual(
      self.sortPill.lastValue?.isHighlighted,
      false,
      "Sort pill should not be highlighted when default sort is selected"
    )

    self.useCase.inputs.selectedSortOption(.endingSoon)
    XCTAssertEqual(
      self.sortPill.lastValue?.isHighlighted,
      true,
      "Sort pill should be highlighted when a non-default sort is selected"
    )
  }

  func test_selectingCategory_updatesCategoryPill() {
    self.initialObserver.send(value: ())
    self.categoriesObserver.send(value: [
      .art,
      .illustration,
      .documentary,
      .tabletopGames
    ])

    self.selectedCategory.assertLastValue(nil)
    self.categoryPill.assertDidEmitValue()

    guard let categoryPill = self.categoryPill.lastValue else {
      XCTFail("Category pill is missing.")
      return
    }

    XCTAssertEqual(
      categoryPill.isHighlighted, false,
      "Category pill should not be highlighted when no category is selected"
    )

    guard case let .dropdown(title) = categoryPill.buttonType else {
      XCTFail("Category pill is not a dropdown")
      return
    }

    XCTAssertEqual(
      title, "Category",
      "Category pill should have placeholder text when no category is selected"
    )

    self.useCase.inputs.selectedCategory(.illustration)

    guard let newCategoryPill = self.categoryPill.lastValue else {
      XCTFail("Category pill is missing.")
      return
    }

    XCTAssertEqual(
      newCategoryPill.isHighlighted,
      true,
      "Category pill should be highlighted category is selected"
    )

    guard case let .dropdown(newTitle) = newCategoryPill.buttonType else {
      XCTFail("Category pill is not a dropdown")
      return
    }

    XCTAssertEqual(
      newTitle,
      "Illustration",
      "Category pill should have selected category title when category is selected"
    )
  }

  func test_clearOptions_resetsSort_andClearsCategory() {
    self.initialObserver.send(value: ())
    self.categoriesObserver.send(value: [
      .art
    ])

    self.selectedSort.assertLastValue(.magic)
    self.selectedCategory.assertLastValue(nil)

    self.useCase.inputs.selectedSortOption(.popular)
    self.useCase.inputs.selectedCategory(.art)

    self.selectedSort.assertLastValue(.popular)
    self.selectedCategory.assertLastValue(.art)

    self.useCase.inputs.clearOptions()

    self.selectedSort.assertLastValue(.magic, "Sort should revert to default sort when options are cleared")
    self.selectedCategory.assertLastValue(nil, "Category should revert to nil when options are cleared")
  }
}
