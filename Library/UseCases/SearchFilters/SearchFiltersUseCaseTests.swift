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
  private let selectedLocation = TestObserver<Location?, Never>()
  private let selectedAmountRaisedBucket = TestObserver<DiscoveryParams.AmountRaisedBucket?, Never>()
  private let selectedGoalBucket = TestObserver<DiscoveryParams.GoalBucket?, Never>()
  private let selectedToggles = TestObserver<SearchFilterToggles, Never>()
  private let showFilters = TestObserver<SearchFilterModalType, Never>()

  private let (initialSignal, initialObserver) = Signal<Void, Never>.pipe()
  private let (categoriesSignal, categoriesObserver) = Signal<[KsApi.Category], Never>.pipe()
  private let (defaultLocationsSignal, defaultLocationsObserver) = Signal<[KsApi.Location], Never>.pipe()
  private let (suggestedLocationsSignal, suggestedLocationsObserver) = Signal<[KsApi.Location], Never>.pipe()

  override func setUp() {
    super.setUp()

    self.useCase = SearchFiltersUseCase(
      initialSignal: self.initialSignal,
      categories: self.categoriesSignal,
      defaultLocations: self.defaultLocationsSignal,
      suggestedLocations: self.suggestedLocationsSignal
    )

    self.useCase.dataOutputs.selectedCategory.map { $0.category }.observe(self.selectedCategory.observer)
    self.useCase.dataOutputs.selectedSort.observe(self.selectedSort.observer)
    self.useCase.dataOutputs.selectedState.observe(self.selectedState.observer)
    self.useCase.dataOutputs.selectedPercentRaisedBucket.observe(self.selectedPercentRaisedBucket.observer)
    self.useCase.dataOutputs.selectedLocation.observe(self.selectedLocation.observer)
    self.useCase.dataOutputs.selectedAmountRaisedBucket.observe(self.selectedAmountRaisedBucket.observer)
    self.useCase.dataOutputs.selectedGoalBucket.observe(self.selectedGoalBucket.observer)
    self.useCase.dataOutputs.selectedToggles.observe(self.selectedToggles.observer)
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

  func assert_selectedLocation_isDefault() {
    self.selectedLocation.assertLastValue(nil, "Selected location should be default value")
  }

  func assert_selectedAmountRaisedBucket_isDefault() {
    self.selectedAmountRaisedBucket.assertLastValue(nil, "Selected amount raised should be default value")
  }

  func assert_selectedGoalBucket_isDefault() {
    self.selectedAmountRaisedBucket.assertLastValue(nil, "Selected amount raised should be default value")
  }

  func assert_toggles_areDefaults() {
    if let toggles = self.selectedToggles.lastValue {
      XCTAssertFalse(toggles.following)
      XCTAssertFalse(toggles.projectsWeLove)
      XCTAssertFalse(toggles.recommended)
      XCTAssertFalse(toggles.savedProjects)
    } else {
      XCTFail("Expected some toggles to be set")
    }
  }

  func test_allFilters_onInitialSignal_areDefaults() {
    self.initialObserver.send(value: ())

    self.assertAllFilters_areSetToDefaults()
  }

  func test_sort_onInitialSignal_isRecommended() {
    self.selectedSort.assertDidNotEmitValue()

    self.initialObserver.send(value: ())

    self.selectedSort.assertLastValue(.magic)
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

  func test_tappedLocation_showsLocation() {
    self.initialObserver.send(value: ())

    self.defaultLocationsObserver.send(value: threeLocations)
    self.suggestedLocationsObserver.send(value: threeLocations)

    self.showFilters.assertDidNotEmitValue()

    self.useCase.inputs.tappedButton(forFilterType: .location)

    self.showFilters.assertDidEmitValue()

    if let type = self.showFilters.lastValue {
      XCTAssertEqual(type, .location, "Tapping percent raised button should percent raised options")
      XCTAssertEqual(
        self.useCase.uiOutputs.searchFilters.location.defaultLocations.count,
        3,
        "There should be three default locations set"
      )
      XCTAssertEqual(
        self.useCase.uiOutputs.searchFilters.location.suggestedLocations.count,
        3,
        "There should be three suggested locations set"
      )
    }

    self.assert_selectedLocation_isDefault()
  }

  func test_tappedAmountRaised_showsAmountRaised() {
    let amountRaisedOn = MockRemoteConfigClient()
    amountRaisedOn.features = [
      RemoteConfigFeature.searchFilterByAmountRaised.rawValue: true
    ]

    withEnvironment(remoteConfigClient: amountRaisedOn) {
      self.initialObserver.send(value: ())

      self.showFilters.assertDidNotEmitValue()

      self.useCase.inputs.tappedButton(forFilterType: .amountRaised)

      self.showFilters.assertDidEmitValue()

      if let type = self.showFilters.lastValue {
        XCTAssertEqual(type, .amountRaised, "Tapping amount raised button should amount raised options")
        XCTAssertGreaterThan(
          self.useCase.uiOutputs.searchFilters.amountRaised.buckets.count,
          0,
          "There should be multiple amount raised options"
        )
      }

      XCTAssertEqual(
        self.useCase.uiOutputs.searchFilters.amountRaised.selectedBucket,
        nil,
        "No option should be selected by default"
      )
    }
  }

  func test_tappedGoal_showsGoal() {
    self.initialObserver.send(value: ())

    self.showFilters.assertDidNotEmitValue()

    self.useCase.inputs.tappedButton(forFilterType: .goal)

    self.showFilters.assertDidEmitValue()

    if let type = self.showFilters.lastValue {
      XCTAssertEqual(type, .goal, "Tapping goal button should show goal options")
      XCTAssertGreaterThan(
        self.useCase.uiOutputs.searchFilters.goal.buckets.count,
        0,
        "There should be multiple goal options"
      )
    }

    XCTAssertEqual(
      self.useCase.uiOutputs.searchFilters.goal.selectedBucket,
      nil,
      "No option should be selected by default"
    )
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

    self.useCase.inputs.selectedFilter(.category(.rootCategory(.art)))

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

    self.useCase.inputs.selectedFilter(.sort(.endingSoon))

    guard let newSelectedSort = self.selectedSort.lastValue else {
      XCTFail("There should be a new selected sort option")
      return
    }

    XCTAssertEqual(newSelectedSort, .endingSoon, "Sort value should change when new sort is selected")
  }

  func test_selectingState_updatesState() {
    self.initialObserver.send(value: ())

    self.assert_selectedProjectState_isDefault()

    self.useCase.inputs.selectedFilter(.projectState(.late_pledge))

    guard let newSelectedState = self.selectedState.lastValue else {
      XCTFail("There should be a new selected state")
      return
    }

    XCTAssertEqual(newSelectedState, .late_pledge, "State value should change when new state is selected")
  }

  func test_selectingPercentRaisedBucket_updatesBucket() {
    self.initialObserver.send(value: ())

    self.assert_selectedPercentRaisedBucket_isDefault()

    self.useCase.inputs.selectedFilter(.percentRaised(.bucket_1))

    guard let newSelectedBucket = self.selectedPercentRaisedBucket.lastValue else {
      XCTFail("There should be a new selected bucket")
      return
    }

    XCTAssertEqual(newSelectedBucket, .bucket_1, "Percent raised value should change when bucket is selected")
  }

  func test_selectingAmountRaisedBucket_updatesBucket() {
    self.initialObserver.send(value: ())

    self.assert_selectedAmountRaisedBucket_isDefault()

    self.useCase.inputs.selectedFilter(.amountRaised(.bucket_3))

    guard let newSelectedBucket = self.selectedAmountRaisedBucket.lastValue else {
      XCTFail("There should be a new selected bucket")
      return
    }

    XCTAssertEqual(newSelectedBucket, .bucket_3, "Amount raised value should change when bucket is selected")
  }

  func test_selectingLocation_updatesLocation() {
    self.initialObserver.send(value: ())

    self.assert_selectedLocation_isDefault()

    let location = threeLocations[1]

    self.useCase.inputs.selectedFilter(.location(location))

    guard let newSelectedLocation = self.selectedLocation.lastValue else {
      XCTFail("There should be a new selected location")
      return
    }

    XCTAssertEqual(
      newSelectedLocation,
      location,
      "Selected location value should change when location is selected"
    )
  }

  func test_selectingToggles_updatesToggles() {
    self.initialObserver.send(value: ())

    self.assert_toggles_areDefaults()

    self.useCase.inputs.selectedFilter(.following(true))
    if let toggles = self.selectedToggles.lastValue {
      XCTAssertTrue(toggles.following)
      XCTAssertFalse(toggles.projectsWeLove)
      XCTAssertFalse(toggles.recommended)
      XCTAssertFalse(toggles.savedProjects)
    } else {
      XCTFail()
    }

    self.useCase.inputs.selectedFilter(.projectsWeLove(true))
    if let toggles = self.selectedToggles.lastValue {
      XCTAssertTrue(toggles.following)
      XCTAssertTrue(toggles.projectsWeLove)
      XCTAssertFalse(toggles.recommended)
      XCTAssertFalse(toggles.savedProjects)
    } else {
      XCTFail()
    }

    self.useCase.inputs.selectedFilter(.recommended(true))
    if let toggles = self.selectedToggles.lastValue {
      XCTAssertTrue(toggles.following)
      XCTAssertTrue(toggles.projectsWeLove)
      XCTAssertTrue(toggles.recommended)
      XCTAssertFalse(toggles.savedProjects)
    } else {
      XCTFail()
    }

    self.useCase.inputs.selectedFilter(.savedProjects(true))
    if let toggles = self.selectedToggles.lastValue {
      XCTAssertTrue(toggles.following)
      XCTAssertTrue(toggles.projectsWeLove)
      XCTAssertTrue(toggles.recommended)
      XCTAssertTrue(toggles.savedProjects)
    } else {
      XCTFail()
    }
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

    self.useCase.inputs.selectedFilter(.sort(.endingSoon))

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

    self.useCase.inputs.selectedFilter(.category(.subcategory(
      rootCategory: .art,
      subcategory: .illustration
    )))

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

    self.useCase.inputs.selectedFilter(.percentRaised(.bucket_2))

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
        DiscoveryParams.PercentRaisedBucket.bucket_2.pillTitle,
        "Dropdown should have description of selected % raised option in its title"
      )

    } else {
      XCTFail("Expected percent raised pill to be set")
    }
  }

  func test_selectingAmountRaised_updatesAmountRaisedPill() {
    let amountRaisedOn = MockRemoteConfigClient()
    amountRaisedOn.features = [
      RemoteConfigFeature.searchFilterByAmountRaised.rawValue: true
    ]

    withEnvironment(remoteConfigClient: amountRaisedOn) {
      self.initialObserver.send(value: ())

      self.assert_selectedAmountRaisedBucket_isDefault()

      if let pill = self.useCase.uiOutputs.searchFilters.amountRaisedPill {
        XCTAssertEqual(
          pill.isHighlighted,
          false,
          "Amount raised pill should not be highlighted when no bucket is selected"
        )
      } else {
        XCTFail("Expected percent raised pill to be set")
      }

      self.useCase.inputs.selectedFilter(.amountRaised(.bucket_3))

      if let pill = self.useCase.uiOutputs.searchFilters.amountRaisedPill {
        XCTAssertEqual(
          pill.isHighlighted,
          true,
          "Amount raised pill should be highlighted when a non-default option is selected"
        )

        guard case let .dropdown(title) = pill.buttonType else {
          XCTFail("Pill is not a dropdown")
          return
        }

        XCTAssertEqual(
          title,
          DiscoveryParams.AmountRaisedBucket.bucket_3.pillTitle,
          "Dropdown should have description of selected amount raised option in its title"
        )

      } else {
        XCTFail("Expected percent raised pill to be set")
      }
    }
  }

  func test_selectingLocation_updatesLocationPill() {
    let locationOn = MockRemoteConfigClient()
    locationOn.features = [
      RemoteConfigFeature.searchFilterByLocation.rawValue: true
    ]

    withEnvironment(remoteConfigClient: locationOn) {
      self.initialObserver.send(value: ())

      self.assert_selectedLocation_isDefault()

      if let pill = self.useCase.uiOutputs.searchFilters.locationPill {
        XCTAssertEqual(
          pill.isHighlighted,
          false,
          "Percent raised pill should not be highlighted when no location is selected"
        )
      } else {
        XCTFail("Expected location pill to be set")
      }

      let location = threeLocations[0]

      self.useCase.inputs.selectedFilter(.location(location))

      if let pill = self.useCase.uiOutputs.searchFilters.locationPill {
        XCTAssertEqual(
          pill.isHighlighted,
          true,
          "Location pill should be highlighted when a non-default option is selected"
        )

        guard case let .dropdown(title) = pill.buttonType else {
          XCTFail("Pill is not a dropdown")
          return
        }

        XCTAssertEqual(
          title,
          location.displayableName,
          "Dropdown should have description of selected location in its title"
        )

      } else {
        XCTFail("Expected location pill to be set")
      }
    }
  }

  func test_userLoggedIn_showsUserTogglePills() {
    let togglesOn = MockRemoteConfigClient()
    togglesOn.features = [
      RemoteConfigFeature.searchFilterByShowOnlyToggles.rawValue: true
    ]

    withEnvironment(currentUser: User.template, remoteConfigClient: togglesOn) {
      self.initialObserver.send(value: ())

      XCTAssertNotNil(self.useCase.uiOutputs.searchFilters.followingPill)
      XCTAssertNotNil(self.useCase.uiOutputs.searchFilters.projectsWeLovePill)
      XCTAssertNotNil(self.useCase.uiOutputs.searchFilters.recommendedPill)
      XCTAssertNotNil(self.useCase.uiOutputs.searchFilters.savedPill)
    }
  }

  func test_userLoggedOut_showsAnonymousTogglePills() {
    let togglesOn = MockRemoteConfigClient()
    togglesOn.features = [
      RemoteConfigFeature.searchFilterByShowOnlyToggles.rawValue: true
    ]

    withEnvironment(currentUser: nil, remoteConfigClient: togglesOn) {
      self.initialObserver.send(value: ())

      XCTAssertNil(self.useCase.uiOutputs.searchFilters.followingPill)
      XCTAssertNotNil(self.useCase.uiOutputs.searchFilters.projectsWeLovePill)
      XCTAssertNil(self.useCase.uiOutputs.searchFilters.recommendedPill)
      XCTAssertNil(self.useCase.uiOutputs.searchFilters.savedPill)
    }
  }

  func assert_selectedToggle_updatesTogglePill(
    _ type: SearchFilterPill.FilterType,
    onEvent event: SearchFilterEvent
  ) {
    let togglesOn = MockRemoteConfigClient()
    togglesOn.features = [
      RemoteConfigFeature.searchFilterByShowOnlyToggles.rawValue: true
    ]

    withEnvironment(currentUser: User.template, remoteConfigClient: togglesOn) {
      self.initialObserver.send(value: ())

      self.assert_toggles_areDefaults()

      if let pill = self.useCase.uiOutputs.searchFilters.pills.first(where: { $0.filterType == type }) {
        XCTAssertEqual(
          pill.isHighlighted,
          false,
          "Toggle pill should not be highlighted when toggle is off"
        )
      } else {
        XCTFail("Expected toggle pill to be set")
      }

      self.useCase.inputs.selectedFilter(event)

      if let pill = self.useCase.uiOutputs.searchFilters.pills.first(where: { $0.filterType == type }) {
        XCTAssertEqual(
          pill.isHighlighted,
          true,
          "Toggle pill should be highlighted when a non-default option is selected"
        )

      } else {
        XCTFail("Expected toggle pill to be set")
      }
    }
  }

  func test_selectingToggles_updatesTogglePills() {
    self.assert_selectedToggle_updatesTogglePill(.following, onEvent: .following(true))

    self.useCase.inputs.resetFilters(for: .allFilters)
    self.assert_selectedToggle_updatesTogglePill(.projectsWeLove, onEvent: .projectsWeLove(true))

    self.useCase.inputs.resetFilters(for: .allFilters)
    self.assert_selectedToggle_updatesTogglePill(.recommended, onEvent: .recommended(true))

    self.useCase.inputs.resetFilters(for: .allFilters)
    self.assert_selectedToggle_updatesTogglePill(.saved, onEvent: .savedProjects(true))
  }

  func test_tappingOnToggles_changesToggleValue_insteadOfShowingFilters() {
    let togglesOn = MockRemoteConfigClient()
    togglesOn.features = [
      RemoteConfigFeature.searchFilterByShowOnlyToggles.rawValue: true
    ]

    withEnvironment(currentUser: User.template, remoteConfigClient: togglesOn) {
      self.initialObserver.send(value: ())
      self.assert_toggles_areDefaults()

      self.useCase.inputs.tappedButton(forFilterType: .following)
      self.useCase.inputs.tappedButton(forFilterType: .projectsWeLove)
      self.useCase.inputs.tappedButton(forFilterType: .recommended)
      self.useCase.inputs.tappedButton(forFilterType: .saved)

      if let toggles = self.selectedToggles.lastValue {
        XCTAssertTrue(toggles.following)
        XCTAssertTrue(toggles.projectsWeLove)
        XCTAssertTrue(toggles.recommended)
        XCTAssertTrue(toggles.savedProjects)
      }

      self.useCase.inputs.tappedButton(forFilterType: .following)
      self.useCase.inputs.tappedButton(forFilterType: .projectsWeLove)
      self.useCase.inputs.tappedButton(forFilterType: .recommended)
      self.useCase.inputs.tappedButton(forFilterType: .saved)

      if let toggles = self.selectedToggles.lastValue {
        XCTAssertFalse(toggles.following)
        XCTAssertFalse(toggles.projectsWeLove)
        XCTAssertFalse(toggles.recommended)
        XCTAssertFalse(toggles.savedProjects)
      }

      self.showFilters.assertDidNotEmitValue("Tapping on a toggle filter shouldn't show any filter modals")
    }
  }

  func setAllFilters_toNonDefault_andAssert() {
    self.categoriesObserver.send(value: [
      .art,
      .documentary,
      .documentarySpanish
    ])

    self.useCase.inputs.selectedFilter(.category(.rootCategory(.art)))
    self.selectedCategory.assertLastValue(.art)

    self.useCase.inputs.selectedFilter(.projectState(.late_pledge))
    self.selectedState.assertLastValue(.late_pledge)

    self.useCase.inputs.selectedFilter(.percentRaised(.bucket_2))
    self.selectedPercentRaisedBucket.assertLastValue(.bucket_2)

    self.useCase.inputs.selectedFilter(.following(true))
    self.useCase.inputs.selectedFilter(.projectsWeLove(true))
    self.useCase.inputs.selectedFilter(.savedProjects(true))
    self.useCase.inputs.selectedFilter(.recommended(true))

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
    self.assert_selectedLocation_isDefault()
    self.assert_selectedAmountRaisedBucket_isDefault()
    self.assert_toggles_areDefaults()

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

    self.useCase.inputs.selectedFilter(.sort(.endingSoon))
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

private let threeLocations = [
  Location(
    country: "US",
    displayableName: "Somerville, MA",
    id: 1,
    localizedName: "Somerville, MA",
    name: "Somerville, MA"
  ),
  Location(
    country: "US",
    displayableName: "Cambridge, MA",
    id: 2,
    localizedName: "Cambridge, MA",
    name: "Cambridge, MA"
  ),
  Location(
    country: "US",
    displayableName: "Allston, MA",
    id: 3,
    localizedName: "Allston, MA",
    name: "Allston, MA"
  )
]
