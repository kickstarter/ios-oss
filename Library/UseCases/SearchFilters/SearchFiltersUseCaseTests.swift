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
  private let showFilters = TestObserver<(SearchFilterOptions, SearchFilterModalType), Never>()

  private let (initialSignal, initialObserver) = Signal<Void, Never>.pipe()
  private let (categoriesSignal, categoriesObserver) = Signal<[KsApi.Category], Never>.pipe()

  override func setUp() {
    super.setUp()

    self.useCase = SearchFiltersUseCase(
      initialSignal: self.initialSignal,
      categories: self.categoriesSignal
    )

    self.useCase.dataOutputs.selectedCategory.observe(self.selectedCategory.observer)
    self.useCase.dataOutputs.selectedSort.observe(self.selectedSort.observer)
    self.useCase.dataOutputs.selectedState.observe(self.selectedState.observer)
    self.useCase.uiOutputs.showFilters.observe(self.showFilters.observer)
  }

  func assert_selectedSort_isDefault() {
    self.selectedSort.assertLastValue(.magic, "Selected sort should be default value")
  }

  func assert_selectedProjectState_isDefault() {
    self.selectedState.assertLastValue(.all, "Selected project state should be default value")
  }

  func assert_selectedCategory_isDefault() {
    self.selectedCategory.assertLastValue(nil, "Selected category should be default value")
  }

  func test_category_onInitialSignal_isNil() {
    self.selectedCategory.assertDidNotEmitValue()

    self.initialObserver.send(value: ())

    self.assert_selectedCategory_isDefault()
  }

  func test_sort_onInitialSignal_isRecommended() {
    self.selectedSort.assertDidNotEmitValue()

    self.initialObserver.send(value: ())

    self.selectedSort.assertLastValue(.magic)
  }

  func test_projectState_onInitialSignal_isAll() {
    self.selectedState.assertDidNotEmitValue()

    self.initialObserver.send(value: ())

    self.assert_selectedProjectState_isDefault()
  }

  func test_tappedSort_showsSortOptions() {
    self.initialObserver.send(value: ())

    self.showFilters.assertDidNotEmitValue()

    self.useCase.inputs.tappedButton(forFilterType: .sort)

    self.showFilters.assertDidEmitValue()

    if let (options, type) = self.showFilters.lastValue {
      XCTAssertEqual(type, .sort, "Tapping sort button should show sort options")
      XCTAssertGreaterThan(options.sort.sortOptions.count, 0, "There should be multiple sort options")
    }

    XCTAssertEqual(
      self.useCase.uiOutputs.selectedFilters.sort,
      .magic,
      "First option, magic, should be selected by default"
    )
  }

  func test_tappedCategories_showsCategoryFilters() {
    self.initialObserver.send(value: ())
    self.categoriesObserver.send(value: [
      .art,
      .illustration,
      .documentary,
      .tabletopGames
    ])

    self.showFilters.assertDidNotEmitValue()

    self.useCase.inputs.tappedButton(forFilterType: .category)

    self.showFilters.assertDidEmitValue()

    if let (options, type) = self.showFilters.lastValue {
      XCTAssertEqual(type, .category, "Tapping category button should show category filters")
      XCTAssertEqual(
        options.category.categories.count,
        4,
        "The sheet should show the categories that were loaded"
      )
    }

    XCTAssertEqual(
      self.useCase.uiOutputs.selectedFilters.category,
      nil,
      "No category should be selected by default"
    )
  }

  func test_tappedProjectState_showsAllOptions() {
    self.initialObserver.send(value: ())

    self.showFilters.assertDidNotEmitValue()

    self.useCase.inputs.tappedButton(forFilterType: .projectState)

    self.showFilters.assertDidEmitValue()

    if let (options, type) = self.showFilters.lastValue {
      XCTAssertEqual(type, .allFilters, "Tapping project state button should show all options")
      XCTAssertGreaterThan(
        options.projectState.stateOptions.count,
        0,
        "There should be multiple project state options"
      )
    }

    XCTAssertEqual(
      self.useCase.uiOutputs.selectedFilters.projectState,
      .all,
      "First option, All, should be selected by default"
    )
  }

  func test_tappedAllFilters_showsAllOptions() {
    self.initialObserver.send(value: ())

    self.showFilters.assertDidNotEmitValue()

    self.useCase.inputs.tappedButton(forFilterType: .allFilters)

    self.showFilters.assertDidEmitValue()

    if let (_, type) = self.showFilters.lastValue {
      XCTAssertEqual(type, .allFilters, "Tapping all filter button should show all filters")
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

    self.showFilters.assertDidNotEmitValue()
    self.assert_selectedCategory_isDefault()

    self.useCase.inputs.tappedButton(forFilterType: .category)
    self.showFilters.assertDidEmitValue()

    self.useCase.inputs.selectedCategory(.art)

    guard let newCategory = self.selectedCategory.lastValue else {
      XCTFail("There should be a new selected category")
      return
    }

    XCTAssertEqual(newCategory, categories[0], "Should have selected the first category in the list")
  }

  func test_selectingSort_updatesSort() {
    self.initialObserver.send(value: ())

    self.showFilters.assertDidNotEmitValue()
    self.selectedSort.assertLastValue(.magic)

    self.useCase.inputs.tappedButton(forFilterType: .sort)
    self.showFilters.assertDidEmitValue()

    self.useCase.inputs.selectedSortOption(.endingSoon)

    guard let newSelectedSort = self.selectedSort.lastValue else {
      XCTFail("There should be a new selected sort option")
      return
    }

    XCTAssertEqual(newSelectedSort, .endingSoon, "Sort value should change when new sort is selected")
  }

  func test_selectingState_updatesState() {
    self.initialObserver.send(value: ())

    self.assert_selectedProjectState_isDefault()

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

    if let sortPill = self.useCase.uiOutputs.selectedFilters.sortPill {
      XCTAssertEqual(
        sortPill.isHighlighted,
        false,
        "Sort pill should not be highlighted when default sort is selected"
      )
    } else {
      XCTFail("Expected sort pill to be set")
    }

    self.useCase.inputs.selectedSortOption(.endingSoon)

    if let sortPill = self.useCase.uiOutputs.selectedFilters.sortPill {
      XCTAssertEqual(
        sortPill.isHighlighted,
        true,
        "Sort pill should be highlighted when a non-default sort is selected"
      )
    } else {
      XCTFail("Expected sort pill to be set")
    }
  }

  func test_selectingCategory_updatesCategoryPill() {
    self.initialObserver.send(value: ())
    self.categoriesObserver.send(value: [
      .art,
      .illustration,
      .documentary,
      .tabletopGames
    ])

    self.assert_selectedCategory_isDefault()

    guard let categoryPill = self.useCase.uiOutputs.selectedFilters.categoryPill else {
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

    guard let newCategoryPill = self.useCase.uiOutputs.selectedFilters.categoryPill else {
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

    self.assert_selectedSort_isDefault()
    self.assert_selectedCategory_isDefault()
    self.assert_selectedProjectState_isDefault()

    self.useCase.inputs.selectedSortOption(.popular)
    self.useCase.inputs.selectedCategory(.art)
    self.useCase.inputs.selectedProjectState(.late_pledge)

    self.selectedSort.assertLastValue(.popular)
    self.selectedCategory.assertLastValue(.art)
    self.selectedState.assertLastValue(.late_pledge)

    self.useCase.inputs.clearedQueryText()

    self.assert_selectedSort_isDefault()
    self.assert_selectedCategory_isDefault()
    self.assert_selectedProjectState_isDefault()
  }

  func test_resetFiltersForType_resetsOnlySpecificFilters() {
    self.initialObserver.send(value: ())
    self.categoriesObserver.send(value: [
      .art,
      .documentary,
      .documentarySpanish
    ])

    XCTAssertFalse(
      self.useCase.uiOutputs.selectedFilters.canReset(filter: .allFilters),
      "Reset should be disabled because no filters were set"
    )
    XCTAssertFalse(
      self.useCase.uiOutputs.selectedFilters.canReset(filter: .category),
      "Reset should be disabled because no category was set"
    )
    XCTAssertFalse(
      self.useCase.uiOutputs.selectedFilters.canReset(filter: .sort),
      "Reset should be disabled because no sort was set"
    )

    // Select some options
    self.useCase.inputs.selectedSortOption(.popular)
    self.selectedSort.assertLastValue(.popular)

    self.useCase.inputs.selectedCategory(.documentarySpanish)
    self.selectedCategory.assertLastValue(.documentarySpanish)

    self.useCase.inputs.selectedProjectState(.late_pledge)
    self.selectedState.assertLastValue(.late_pledge)

    XCTAssertTrue(
      self.useCase.uiOutputs.selectedFilters.canReset(filter: .allFilters),
      "Reset should be enabled because some filters were set"
    )
    XCTAssertTrue(
      self.useCase.uiOutputs.selectedFilters.canReset(filter: .category),
      "Reset should be enabled because some filters were set"
    )
    XCTAssertTrue(
      self.useCase.uiOutputs.selectedFilters.canReset(filter: .sort),
      "Reset should be enabled because some sort was set"
    )

    self.useCase.inputs.resetFilters(for: .category)
    self.assert_selectedCategory_isDefault()
    XCTAssertFalse(
      self.useCase.uiOutputs.selectedFilters.canReset(filter: .category),
      "Resetting the category should disable the reset button afterwards"
    )

    self.selectedSort.assertLastValue(.popular, "Resetting category shouldn't affect sort")
    self.selectedState.assertLastValue(.late_pledge, "Resetting category shouldn't affect project state")

    self.useCase.inputs.resetFilters(for: .allFilters)
    self.assert_selectedProjectState_isDefault()
    XCTAssertFalse(
      self.useCase.uiOutputs.selectedFilters.canReset(filter: .allFilters),
      "Resetting all filters should disable the reset button afterwards"
    )

    self.selectedSort.assertLastValue(
      .popular,
      "Sort isn't on the all filters page, so it shouldn't be reset by all filters"
    )
    self.assert_selectedCategory_isDefault()

    self.useCase.inputs.resetFilters(for: .sort)
    self.assert_selectedSort_isDefault()
    self.assert_selectedCategory_isDefault()
    self.assert_selectedProjectState_isDefault()

    XCTAssertFalse(self.useCase.uiOutputs.selectedFilters.canReset(filter: .allFilters))
    XCTAssertFalse(self.useCase.uiOutputs.selectedFilters.canReset(filter: .category))
    XCTAssertFalse(self.useCase.uiOutputs.selectedFilters.canReset(filter: .sort))
  }
}
