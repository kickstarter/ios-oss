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
  private let selectedPercentRaisedBucket = TestObserver<DiscoveryParams.PercentRaisedBucket?, Never>()
  private let showFilters = TestObserver<SearchFilterModalType, Never>()

  private let (initialSignal, initialObserver) = Signal<Void, Never>.pipe()
  private let (categoriesSignal, categoriesObserver) = Signal<[KsApi.Category], Never>.pipe()

  override func setUp() {
    super.setUp()

    self.useCase = SearchFiltersUseCase(
      initialSignal: self.initialSignal,
      categories: self.categoriesSignal
    )

    self.useCase.dataOutputs.selectedCategory.map { $0.category }.observe(self.selectedCategory.observer)
    self.useCase.dataOutputs.selectedSort.observe(self.selectedSort.observer)
    self.useCase.dataOutputs.selectedState.observe(self.selectedState.observer)
    self.useCase.dataOutputs.selectedPercentRaisedBucket.observe(self.selectedPercentRaisedBucket.observer)
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

  func assert_selectedPercentRaisedBucket_isDefault() {
    self.selectedPercentRaisedBucket.assertLastValue(nil, "Selected % raised should be default value")
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

  func test_selectedPercentRaisedBucket_onInitialSignal_isNil() {
    self.selectedPercentRaisedBucket.assertDidNotEmitValue()

    self.initialObserver.send(value: ())

    self.assert_selectedPercentRaisedBucket_isDefault()
  }

  func test_tappedSort_showsSortOptions() {
    self.initialObserver.send(value: ())

    self.showFilters.assertDidNotEmitValue()

    self.useCase.inputs.tappedButton(forFilterType: .sort)

    self.showFilters.assertDidEmitValue()

    if let type = self.showFilters.lastValue {
      XCTAssertEqual(type, .sort, "Tapping sort button should show sort options")
      XCTAssertGreaterThan(
        self.useCase.uiOutputs.searchFilters.sort.sortOptions.count,
        0,
        "There should be multiple sort options"
      )
    }

    XCTAssertEqual(
      self.useCase.uiOutputs.searchFilters.sort.selectedSort,
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

    if let type = self.showFilters.lastValue {
      XCTAssertEqual(type, .category, "Tapping category button should show category filters")
      XCTAssertEqual(
        self.useCase.uiOutputs.searchFilters.category.categories.count,
        4,
        "The sheet should show the categories that were loaded"
      )
    }

    XCTAssertEqual(
      self.useCase.uiOutputs.searchFilters.category.selectedCategory,
      .none,
      "No category should be selected by default"
    )
  }

  func test_tappedProjectState_showsAllOptions() {
    self.initialObserver.send(value: ())

    self.showFilters.assertDidNotEmitValue()

    self.useCase.inputs.tappedButton(forFilterType: .projectState)

    self.showFilters.assertDidEmitValue()

    if let type = self.showFilters.lastValue {
      XCTAssertEqual(type, .allFilters, "Tapping project state button should show all options")
      XCTAssertGreaterThan(
        self.useCase.uiOutputs.searchFilters.projectState.stateOptions.count,
        0,
        "There should be multiple project state options"
      )
    }

    XCTAssertEqual(
      self.useCase.uiOutputs.searchFilters.projectState.selectedProjectState,
      .all,
      "First option, All, should be selected by default"
    )
  }

  func test_tappedPercentRaised_showsPercentRaised() {
    self.initialObserver.send(value: ())

    self.showFilters.assertDidNotEmitValue()

    self.useCase.inputs.tappedButton(forFilterType: .percentRaised)

    self.showFilters.assertDidEmitValue()

    if let type = self.showFilters.lastValue {
      XCTAssertEqual(type, .percentRaised, "Tapping percent raised button should percent raised options")
      XCTAssertGreaterThan(
        self.useCase.uiOutputs.searchFilters.percentRaised.buckets.count,
        0,
        "There should be multiple percent raised options"
      )
    }

    XCTAssertEqual(
      self.useCase.uiOutputs.searchFilters.percentRaised.selectedBucket,
      nil,
      "No option should be selected by default"
    )
  }

  func test_tappedAllFilters_showsAllOptions() {
    self.initialObserver.send(value: ())

    self.showFilters.assertDidNotEmitValue()

    self.useCase.inputs.tappedButton(forFilterType: .allFilters)

    self.showFilters.assertDidEmitValue()

    if let type = self.showFilters.lastValue {
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

    self.useCase.inputs.selectedCategory(.rootCategory(.art))

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

  func test_selectingPercentRaisedBucket_updatesBucket() {
    self.initialObserver.send(value: ())

    self.assert_selectedPercentRaisedBucket_isDefault()

    self.useCase.inputs.selectedPercentRaisedBucket(.bucket_1)

    guard let newSelectedBucket = self.selectedPercentRaisedBucket.lastValue else {
      XCTFail("There should be a new selected bucket")
      return
    }

    XCTAssertEqual(newSelectedBucket, .bucket_1, "Percent raised value should change when bucket is selected")
  }

  func test_selectingSort_updatesSortPill() {
    self.initialObserver.send(value: ())

    self.selectedSort.assertLastValue(.magic)

    if let sortPill = self.useCase.uiOutputs.searchFilters.sortPill {
      XCTAssertEqual(
        sortPill.isHighlighted,
        false,
        "Sort pill should not be highlighted when default sort is selected"
      )
    } else {
      XCTFail("Expected sort pill to be set")
    }

    self.useCase.inputs.selectedSortOption(.endingSoon)

    if let sortPill = self.useCase.uiOutputs.searchFilters.sortPill {
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

    guard let categoryPill = self.useCase.uiOutputs.searchFilters.categoryPill else {
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

    self.useCase.inputs.selectedCategory(.subcategory(rootCategory: .art, subcategory: .illustration))

    guard let newCategoryPill = self.useCase.uiOutputs.searchFilters.categoryPill else {
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

  func test_selectingPercentRaised_updatesPercentRaisedPill() {
    let mockConfigClient = MockRemoteConfigClient()
    mockConfigClient.features = [
      RemoteConfigFeature.searchFilterByPercentRaised.rawValue: true
    ]

    withEnvironment(remoteConfigClient: mockConfigClient) {
      self.initialObserver.send(value: ())

      self.assert_selectedPercentRaisedBucket_isDefault()

      if let pill = self.useCase.uiOutputs.searchFilters.percentRaisedPill {
        XCTAssertEqual(
          pill.isHighlighted,
          false,
          "Percent raised pill should not be highlighted when no bucket is selected"
        )
      } else {
        XCTFail("Expected percent raised pill to be set")
      }

      self.useCase.inputs.selectedPercentRaisedBucket(.bucket_2)

      if let pill = self.useCase.uiOutputs.searchFilters.percentRaisedPill {
        XCTAssertEqual(
          pill.isHighlighted,
          true,
          "Percent raised pill should be highlighted when a non-default option is selected"
        )

        guard case let .dropdown(title) = pill.buttonType else {
          XCTFail("Pill is not a dropdown")
          return
        }

        XCTAssertEqual(
          title,
          DiscoveryParams.PercentRaisedBucket.bucket_2.title,
          "Dropdown should have description of selected % raised option in its title"
        )

      } else {
        XCTFail("Expected percent raised pill to be set")
      }
    }
  }

  func setAllFilters_toNonDefault_andAssert() {
    self.categoriesObserver.send(value: [
      .art,
      .documentary,
      .documentarySpanish
    ])

    self.useCase.inputs.selectedCategory(.rootCategory(.art))
    self.selectedCategory.assertLastValue(.art)

    self.useCase.inputs.selectedProjectState(.late_pledge)
    self.selectedState.assertLastValue(.late_pledge)

    self.useCase.inputs.selectedPercentRaisedBucket(.bucket_2)
    self.selectedPercentRaisedBucket.assertLastValue(.bucket_2)

    for type in SearchFilterModalType.allCases {
      if type == .sort {
        // Sort is a special case and not a "filter" per se
        return
      }
      XCTAssertTrue(
        self.useCase.uiOutputs.searchFilters.has(filter: type),
        "Expected setAllFilters_toNonDefault_andAssert to set non-default value for \(type)"
      )
    }
  }

  func assertAllFilters_areSetToDefaults() {
    self.assert_selectedCategory_isDefault()
    self.assert_selectedProjectState_isDefault()
    self.assert_selectedPercentRaisedBucket_isDefault()

    for type in SearchFilterModalType.allCases {
      if type == .sort {
        // Sort is a special case and not a "filter" per se
        return
      }
      XCTAssertFalse(
        self.useCase.uiOutputs.searchFilters.has(filter: type),
        "Expected default value to be set for \(type)"
      )
    }
  }

  func test_clearQueryText_resetsSort_andClearsFilters() {
    self.initialObserver.send(value: ())
    self.categoriesObserver.send(value: [
      .art
    ])

    self.assert_selectedSort_isDefault()
    self.assertAllFilters_areSetToDefaults()

    self.useCase.inputs.selectedSortOption(.endingSoon)
    self.setAllFilters_toNonDefault_andAssert()

    self.useCase.inputs.clearedQueryText()

    self.assert_selectedSort_isDefault()
    self.assertAllFilters_areSetToDefaults()
  }

  func test_resetAllFilters_resetsAllFilters() {
    self.initialObserver.send(value: ())
    self.categoriesObserver.send(value: [
      .art,
      .documentary,
      .documentarySpanish
    ])

    self.setAllFilters_toNonDefault_andAssert()

    XCTAssertTrue(self.useCase.searchFilters.canReset(filter: .allFilters))

    self.useCase.resetFilters(for: .allFilters)

    self.assertAllFilters_areSetToDefaults()
  }

  func test_resetFiltersForType_resetsOnlySpecificFilters() {
    self.initialObserver.send(value: ())

    for type in SearchFilterModalType.allCases {
      XCTAssertFalse(
        self.useCase.uiOutputs.searchFilters.canReset(filter: type),
        "Reset should be disabled because no filters were set"
      )
    }

    let filterTypes = [SearchFilterModalType.category, SearchFilterModalType.percentRaised]

    for type in filterTypes {
      self.setAllFilters_toNonDefault_andAssert()

      XCTAssertTrue(self.useCase.uiOutputs.searchFilters.has(filter: type))
      XCTAssertTrue(self.useCase.uiOutputs.searchFilters.canReset(filter: type))
      self.useCase.inputs.resetFilters(for: type)
      XCTAssertFalse(
        self.useCase.uiOutputs.searchFilters.has(filter: type),
        "Resetting filter of type \(type) should have set it back to its default value"
      )

      // Make sure the other filters didn't get reset, too
      for otherFilterType in filterTypes {
        if otherFilterType == type {
          continue
        }
        XCTAssertTrue(
          self.useCase.uiOutputs.searchFilters.canReset(filter: otherFilterType),
          "Resetting a filter of type \(type) should not have reset the filter of type \(otherFilterType)"
        )
      }
    }
  }
}
