import Foundation
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class SearchViewModelTests: TestCase {
  fileprivate let vm: SearchViewModelType! = SearchViewModel()

  fileprivate let changeSearchFieldFocusFocused = TestObserver<Bool, Never>()
  fileprivate let changeSearchFieldFocusAnimated = TestObserver<Bool, Never>()
  fileprivate let goToRefTag = TestObserver<RefTag, Never>()
  private let hasAddedProjects = TestObserver<Bool, Never>()
  fileprivate let hasProjects = TestObserver<Bool, Never>()
  fileprivate let isPopularTitleVisible = TestObserver<Bool, Never>()
  fileprivate let popularLoaderIndicatorIsAnimating = TestObserver<Bool, Never>()
  fileprivate var noProjects = TestObserver<Bool, Never>()
  fileprivate let resignFirstResponder = TestObserver<(), Never>()
  fileprivate let searchFieldText = TestObserver<String, Never>()
  fileprivate let searchLoaderIndicatorIsAnimating = TestObserver<Bool, Never>()
  fileprivate let showEmptyState = TestObserver<Bool, Never>()
  fileprivate let showEmptyStateParams = TestObserver<DiscoveryParams, Never>()
  fileprivate let showSort = TestObserver<SearchSortSheet, Never>()
  fileprivate let showCategoryFilters = TestObserver<SearchFilterCategoriesSheet, Never>()
  fileprivate let showFilters = TestObserver<Bool, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.changeSearchFieldFocus.map(first).observe(self.changeSearchFieldFocusFocused.observer)
    self.vm.outputs.changeSearchFieldFocus.map(second).observe(self.changeSearchFieldFocusAnimated.observer)
    self.vm.outputs.goToProject.map { _, refTag in refTag }.observe(self.goToRefTag.observer)
    self.vm.outputs.isPopularTitleVisible.observe(self.isPopularTitleVisible.observer)
    self.vm.outputs.popularLoaderIndicatorIsAnimating.observe(self.popularLoaderIndicatorIsAnimating.observer)
    self.vm.outputs.projects.map { !$0.isEmpty }.skipRepeats(==).observe(self.hasProjects.observer)
    self.vm.outputs.projects.map { $0.isEmpty }.skipRepeats(==).observe(self.noProjects.observer)
    self.vm.outputs.resignFirstResponder.observe(self.resignFirstResponder.observer)
    self.vm.outputs.searchFieldText.observe(self.searchFieldText.observer)
    self.vm.outputs.searchLoaderIndicatorIsAnimating.observe(self.searchLoaderIndicatorIsAnimating.observer)
    self.vm.outputs.showEmptyState.map(second).observe(self.showEmptyState.observer)
    self.vm.outputs.showEmptyState.map(first).observe(self.showEmptyStateParams.observer)

    self.vm.outputs.projects
      .map { $0.count }
      .combinePrevious(0)
      .map { prev, next in next > prev }
      .observe(self.hasAddedProjects.observer)

    self.vm.outputs.showFilters.observe(self.showFilters.observer)
    self.vm.outputs.showSort.observe(self.showSort.observer)
    self.vm.outputs.showCategoryFilters.observe(self.showCategoryFilters.observer)
  }

  func testSearchPopularFeatured_RefTag() {
    let response = [(
      GraphAPI.SearchQuery.self,
      GraphAPI.SearchQuery.Data.fiveResults
    )]

    withEnvironment(apiService: MockService(fetchGraphQLResponses: response)) {
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.viewWillAppear(animated: true)
      self.scheduler.advance()
      self.vm.inputs.tapped(projectAtIndex: 0)

      self.goToRefTag.assertValues([RefTag.searchPopularFeatured])
    }
  }

  func testSearchPopular_RefTag() {
    let response = [(
      GraphAPI.SearchQuery.self,
      GraphAPI.SearchQuery.Data.fiveResults
    )]

    withEnvironment(apiService: MockService(fetchGraphQLResponses: response)) {
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.viewWillAppear(animated: true)
      self.scheduler.advance()
      self.vm.inputs.tapped(projectAtIndex: 4)

      self.goToRefTag.assertValues([RefTag.searchPopular])
    }
  }

  func testSearchFeatured_RefTag() {
    let popularResponse = [(
      GraphAPI.SearchQuery.self,
      GraphAPI.SearchQuery.Data.fiveResults
    )]

    let searchResponse = [(
      GraphAPI.SearchQuery.self,
      GraphAPI.SearchQuery.Data.differentFiveResults
    )]

    withEnvironment(apiService: MockService(fetchGraphQLResponses: popularResponse)) {
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.viewWillAppear(animated: true)
      self.scheduler.advance()

      withEnvironment(apiService: MockService(fetchGraphQLResponses: searchResponse)) {
        self.vm.inputs.searchFieldDidBeginEditing()
        self.vm.inputs.searchTextChanged("robots")
        self.scheduler.advance()
        self.vm.inputs.tapped(projectAtIndex: 0)

        self.goToRefTag.assertValues([RefTag.searchFeatured])
      }
    }
  }

  func testSearch_RefTag() {
    let popularResponse = [(
      GraphAPI.SearchQuery.self,
      GraphAPI.SearchQuery.Data.fiveResults
    )]

    let searchResponse = [(
      GraphAPI.SearchQuery.self,
      GraphAPI.SearchQuery.Data.differentFiveResults
    )]

    withEnvironment(apiService: MockService(fetchGraphQLResponses: popularResponse)) {
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.viewWillAppear(animated: true)
      self.scheduler.advance()

      withEnvironment(apiService: MockService(fetchGraphQLResponses: searchResponse)) {
        self.vm.inputs.searchFieldDidBeginEditing()
        self.vm.inputs.searchTextChanged("robots")
        self.scheduler.advance()
        self.vm.inputs.tapped(projectAtIndex: 2)

        self.goToRefTag.assertValues([RefTag.search])
      }
    }
  }

  func testProjectCardClicked() {
    let popularResponse = [(
      GraphAPI.SearchQuery.self,
      GraphAPI.SearchQuery.Data.fiveResults
    )]

    let searchResponse = [(
      GraphAPI.SearchQuery.self,
      GraphAPI.SearchQuery.Data.differentFiveResults
    )]

    withEnvironment(apiService: MockService(fetchGraphQLResponses: popularResponse)) {
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.viewWillAppear(animated: true)
      self.scheduler.advance()

      withEnvironment(apiService: MockService(fetchGraphQLResponses: searchResponse)) {
        self.vm.inputs.searchFieldDidBeginEditing()
        self.vm.inputs.searchTextChanged("robots")
        self.scheduler.advance()
        self.vm.inputs.tapped(projectAtIndex: 0)

        XCTAssertEqual(
          self.segmentTrackingClient.events.last,
          "CTA Clicked"
        )

        let segmentProperties = self.segmentTrackingClient.properties.last

        XCTAssertEqual("search", segmentProperties?["context_page"] as? String)
        XCTAssertEqual("results", segmentProperties?["context_type"] as? String)
        XCTAssertEqual("project", segmentProperties?["context_cta"] as? String)
        XCTAssertEqual("search_results", segmentProperties?["context_location"] as? String)
      }
    }
  }

  func testCancelSearchField() {
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: true)

    XCTAssertEqual(["Page Viewed"], self.segmentTrackingClient.events, "Impression tracked")

    self.vm.inputs.searchFieldDidBeginEditing()
    self.vm.inputs.searchTextChanged("a")
    self.vm.inputs.cancelButtonPressed()

    XCTAssertEqual(
      ["Page Viewed"],
      self.segmentTrackingClient.events,
      "Search input and cancel not tracked"
    )
  }

  func testChangeSearchFieldFocus() {
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: true)

    self.changeSearchFieldFocusFocused.assertValues([false])
    self.changeSearchFieldFocusAnimated.assertValues([false])

    self.vm.inputs.searchFieldDidBeginEditing()

    self.changeSearchFieldFocusFocused.assertValues([false, true])
    self.changeSearchFieldFocusAnimated.assertValues([false, true])
    self.resignFirstResponder.assertValueCount(0)

    self.vm.inputs.cancelButtonPressed()

    self.changeSearchFieldFocusFocused.assertValues([false, true, false])
    self.changeSearchFieldFocusAnimated.assertValues([false, true, true])
    self.resignFirstResponder.assertValueCount(1)
  }

  func testClearSearchText() {
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: true)
    self.vm.inputs.searchFieldDidBeginEditing()
    self.vm.inputs.searchTextChanged("b")
    self.vm.inputs.clearSearchText()

    XCTAssertEqual(
      ["Page Viewed"],
      self.segmentTrackingClient.events,
      "Clear search text not tracked"
    )
  }

  func testPopularLoaderIndicatorIsAnimating() {
    self.popularLoaderIndicatorIsAnimating.assertDidNotEmitValue()

    self.vm.inputs.viewDidLoad()
    self.popularLoaderIndicatorIsAnimating.assertLastValue(true)

    self.vm.inputs.viewWillAppear(animated: true)
    self.popularLoaderIndicatorIsAnimating.assertLastValue(true)

    self.scheduler.advance()

    self.popularLoaderIndicatorIsAnimating.assertLastValue(false)

    self.vm.inputs.searchTextChanged("b")

    self.popularLoaderIndicatorIsAnimating.assertLastValue(false)

    self.scheduler.advance()

    self.popularLoaderIndicatorIsAnimating.assertLastValue(false)
  }

  func testSearchLoaderIndicatorIsAnimating() {
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: true)
    self.searchLoaderIndicatorIsAnimating.assertDidNotEmitValue()

    self.scheduler.advance()

    self.searchLoaderIndicatorIsAnimating.assertDidNotEmitValue()

    self.vm.inputs.searchTextChanged("b")

    self.searchLoaderIndicatorIsAnimating.assertValues([true])

    self.scheduler.advance()

    self.searchLoaderIndicatorIsAnimating.assertValues([true, false])
  }

  // Tests a standard flow of searching for projects.
  func testFlow() {
    let popularResponse = [(
      GraphAPI.SearchQuery.self,
      GraphAPI.SearchQuery.Data.fiveResults
    )]

    let searchResponse = [(
      GraphAPI.SearchQuery.self,
      GraphAPI.SearchQuery.Data.differentFiveResults
    )]

    withEnvironment(apiService: MockService(fetchGraphQLResponses: popularResponse)) {
      self.vm.inputs.viewDidLoad()

      self.hasProjects.assertDidNotEmitValue("No projects before view is visible.")
      self.isPopularTitleVisible.assertDidNotEmitValue("Popular title is not visible before view is visible.")
      XCTAssertEqual([], self.segmentTrackingClient.events, "No events tracked before view is visible.")
      self.vm.inputs.viewWillAppear(animated: true)
      self.isPopularTitleVisible.assertValues([])

      self.scheduler.advance()

      self.hasProjects.assertValues([true], "Projects emitted immediately upon view appearing.")
      self.isPopularTitleVisible.assertValues([true], "Popular title visible upon view appearing.")

      XCTAssertEqual(
        ["Page Viewed"], self.segmentTrackingClient.events,
        "The search view event tracked upon view appearing."
      )

      self.vm.inputs.searchTextChanged("skull graphic tee")

      self.hasProjects.assertValues([true, false], "Projects clear immediately upon entering search.")
      self.isPopularTitleVisible.assertValues(
        [true, false],
        "Popular title hide immediately upon entering search."
      )
    }

    withEnvironment(apiService: MockService(fetchGraphQLResponses: searchResponse)) {
      self.scheduler.advance()

      self.hasProjects.assertValues([true, false, true], "Projects emit after waiting enough time.")
      self.isPopularTitleVisible.assertValues(
        [true, false],
        "Popular title visibility still not emit after time has passed."
      )

      XCTAssertEqual(
        ["Page Viewed", "Page Viewed"],
        self.segmentTrackingClient.events,
        "An event is tracked for the search results."
      )
      XCTAssertEqual(
        "skull graphic tee",
        self.segmentTrackingClient.properties.last?["discover_search_term"] as? String
      )

      self.vm.inputs.willDisplayRow(7, outOf: 10)
      self.scheduler.advance()

      XCTAssertEqual(
        ["Page Viewed", "Page Viewed"],
        self.segmentTrackingClient.events,
        "An event is tracked for the search results."
      )
      XCTAssertEqual(
        ["", "skull graphic tee"],
        self.segmentTrackingClient.properties(forKey: "discover_search_term")
      )

      self.vm.inputs.searchTextChanged("")
      self.scheduler.advance()

      self.hasProjects.assertValues(
        [true, false, true, false, true],
        "Clearing search clears projects and brings back popular projects."
      )
      self.isPopularTitleVisible.assertValues(
        [true, false, true],
        "Clearing search brings back popular title."
      )

      XCTAssertEqual(
        ["Page Viewed", "Page Viewed"],
        self.segmentTrackingClient.events,
        "Doesn't track empty queries"
      )

      self.vm.inputs.viewWillAppear(animated: true)

      self.hasProjects.assertValues(
        [true, false, true, false, true],
        "Leaving view and coming back doesn't load more projects."
      )
      self.isPopularTitleVisible.assertValues(
        [true, false, true],
        "Leaving view and coming back doesn't change popular title"
      )

      XCTAssertEqual(
        ["Page Viewed", "Page Viewed", "Page Viewed"],
        self.segmentTrackingClient.events
      )
    }
  }

  // Tests a flow of searching and updating the sort
  func test_flow_sort() {
    let popularResponse = [(
      GraphAPI.SearchQuery.self,
      GraphAPI.SearchQuery.Data.fiveResults
    )]

    let searchResponse = [(
      GraphAPI.SearchQuery.self,
      GraphAPI.SearchQuery.Data.differentFiveResults
    )]

    withEnvironment(apiService: MockService(fetchGraphQLResponses: popularResponse)) {
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.viewWillAppear(animated: true)

      self.scheduler.advance()

      self.hasProjects.assertValues([true], "Projects emitted immediately upon view appearing.")
      self.isPopularTitleVisible.assertValues([true], "Popular title visible upon view appearing.")
      XCTAssertEqual(self.segmentTrackingClient.events.count, 1, "One event after the popular results load.")
      self.showFilters.assertLastValue(false, "Filter header should be hidden for popular results.")

      self.vm.inputs.searchTextChanged("dogs")

      self.hasProjects.assertValues([true, false], "Projects clear immediately upon entering search.")
      self.showFilters.assertLastValue(false, "Filter header should be hidden when a search is loading.")
    }

    withEnvironment(apiService: MockService(fetchGraphQLResponses: searchResponse)) {
      self.scheduler.advance()

      self.hasProjects.assertLastValue(true, "Projects emit after waiting enough time.")
      self.showFilters.assertLastValue(
        true,
        "Filter header should appear when there are search results to filter."
      )
      XCTAssertEqual(
        self.segmentTrackingClient.events.count,
        2,
        "A second event after the search results load."
      )
      XCTAssertEqual(
        self.segmentTrackingClient.properties(forKey: "discover_sort").last,
        "popular",
        "Selected sort should be in tracking properties"
      )

      self.showSort.assertDidNotEmitValue()
      self.showCategoryFilters.assertDidNotEmitValue()

      self.vm.inputs.tappedSort()
      self.showSort.assertDidEmitValue()

      guard let sortSheet = self.showSort.lastValue else {
        XCTFail("Sort sheet should have been shown after tappedSort was called")
        return
      }

      XCTAssertTrue(sortSheet.sortNames.count > 1, "Sort sheet should have multiple sort options")
      XCTAssertTrue(sortSheet.selectedIndex == 0, "Sort sheet should have first option selected by default")

      self.vm.inputs.selectedSortOption(atIndex: 1)

      self.hasProjects.assertLastValue(false, "Projects clear when new sort option is chosen")
      self.searchLoaderIndicatorIsAnimating.assertLastValue(
        true,
        "Loading spinner should show after new sort option is chosen"
      )
      self.showFilters.assertLastValue(false, "Filter header should hide while the page is loading")

      self.scheduler.advance()

      self.hasProjects.assertLastValue(true, "New projects with new sort option should load")
      self.showFilters.assertLastValue(
        true,
        "Filter header should appear when there are search results to filter."
      )

      XCTAssertEqual(
        self.segmentTrackingClient.events.count,
        3,
        "A third event after the sort updates and results reload."
      )

      XCTAssertEqual(
        "Page Viewed",
        self.segmentTrackingClient.events.last,
        "An event is tracked for the search results."
      )

      XCTAssertEqual(
        self.segmentTrackingClient.properties(forKey: "discover_sort").last,
        "ending_soon",
        "Selected sort should be in tracking properties"
      )
    }
  }

  // Tests a flow of searching and updating the sort
  func test_flow_filterByCategory() {
    let popularResponse = [(
      GraphAPI.SearchQuery.self,
      GraphAPI.SearchQuery.Data.fiveResults
    )]

    let searchResponse = [(
      GraphAPI.SearchQuery.self,
      GraphAPI.SearchQuery.Data.differentFiveResults
    )]

    let categoriesResponse = RootCategoriesEnvelope(rootCategories: [
      .art,
      .filmAndVideo,
      .illustration,
      .documentary
    ])

    let mockService = MockService(
      fetchGraphQLResponses: popularResponse,
      fetchGraphCategoriesResult: .success(categoriesResponse)
    )

    withEnvironment(apiService: mockService) {
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.viewWillAppear(animated: true)

      self.scheduler.advance()

      self.hasProjects.assertValues([true], "Projects emitted immediately upon view appearing.")
      self.isPopularTitleVisible.assertValues([true], "Popular title visible upon view appearing.")
      XCTAssertEqual(self.segmentTrackingClient.events.count, 1, "One event after the popular results load.")
      self.showFilters.assertLastValue(false, "Filter header should be hidden for popular results.")

      self.vm.inputs.searchTextChanged("dogs")

      self.hasProjects.assertValues([true, false], "Projects clear immediately upon entering search.")
      self.showFilters.assertLastValue(false, "Filter header should be hidden when a search is loading.")
    }

    withEnvironment(apiService: MockService(fetchGraphQLResponses: searchResponse)) {
      self.scheduler.advance()

      self.hasProjects.assertLastValue(true, "Projects emit after waiting enough time.")
      self.showFilters.assertLastValue(
        true,
        "Filter header should appear when there are search results to filter."
      )
      XCTAssertEqual(
        self.segmentTrackingClient.events.count,
        2,
        "A second event after the search results load."
      )

      XCTAssertNil(
        self.segmentTrackingClient.properties(forKey: "discover_category_name").last.flatMap { $0 },
        "Selected category should be in tracking properties, but it should be nil because no category was selected yet"
      )

      self.showSort.assertDidNotEmitValue()
      self.showCategoryFilters.assertDidNotEmitValue()

      self.vm.inputs.tappedCategoryFilter()
      self.showCategoryFilters.assertDidEmitValue()

      guard let categorySheet = self.showCategoryFilters.lastValue else {
        XCTFail("Category sheet should have been shown after tappedCategoryFilters was called")
        return
      }

      XCTAssertTrue(categorySheet.categoryNames.count == 4, "Category sheet should have 4 options")
      XCTAssertTrue(
        categorySheet.selectedIndex.isNil,
        "Category sheet should have empty option selected by default"
      )

      self.vm.inputs.selectedCategory(atIndex: 0)

      self.hasProjects.assertLastValue(false, "Projects clear when new category filter is chosen")
      self.searchLoaderIndicatorIsAnimating.assertLastValue(
        true,
        "Loading spinner should show after new category filter is chosen"
      )
      self.showFilters.assertLastValue(false, "Filter header should hide while the page is loading")

      self.scheduler.advance()

      self.hasProjects.assertLastValue(true, "New projects with new category filter should load")
      self.showFilters.assertLastValue(
        true,
        "Filter header should appear when there are search results to filter."
      )

      XCTAssertEqual(
        self.segmentTrackingClient.events.count,
        3,
        "A third event after the sort updates and results reload."
      )

      XCTAssertEqual(
        "Page Viewed",
        self.segmentTrackingClient.events.last,
        "An event is tracked for the search results."
      )

      XCTAssertEqual(
        self.segmentTrackingClient.properties(forKey: "discover_category_name").last,
        "Art",
        "Selected category should be in tracking properties"
      )
    }
  }

  func testShowNoSearchResults() {
    let popularResponse = [(
      GraphAPI.SearchQuery.self,
      GraphAPI.SearchQuery.Data.differentFiveResults
    )]

    withEnvironment(apiService: MockService(fetchGraphQLResponses: popularResponse)) {
      self.vm.inputs.viewDidLoad()

      self.hasProjects.assertDidNotEmitValue("No projects before view is visible.")
      self.isPopularTitleVisible.assertDidNotEmitValue("Popular title is not visible before view is visible.")
      XCTAssertEqual([], self.segmentTrackingClient.events, "No events tracked before view is visible.")

      self.vm.inputs.viewWillAppear(animated: true)

      self.isPopularTitleVisible.assertValues([])

      self.scheduler.advance()

      self.hasProjects.assertValues([true], "Projects emitted immediately upon view appearing.")
      self.isPopularTitleVisible.assertValues([true], "Popular title visible upon view appearing.")

      XCTAssertEqual(
        ["Page Viewed"], self.segmentTrackingClient.events,
        "The search view event tracked upon view appearing."
      )

      self.vm.inputs.searchTextChanged("skull graphic tee")

      self.hasProjects.assertValues([true, false], "Projects clear immediately upon entering search.")
      self.isPopularTitleVisible.assertValues(
        [true, false],
        "Popular title hide immediately upon entering search."
      )

      self.scheduler.advance()

      self.hasProjects.assertValues([true, false, true], "Projects emit after waiting enough time.")
      self.isPopularTitleVisible.assertValues(
        [true, false],
        "Popular title visibility still not emit after time has passed."
      )

      XCTAssertEqual(
        ["Page Viewed", "Page Viewed"],
        self.segmentTrackingClient.events,
        "An event is tracked for the search results."
      )
      XCTAssertEqual(
        ["", "skull graphic tee"],
        self.segmentTrackingClient.properties(forKey: "discover_search_term")
      )

      XCTAssertEqual(
        [0, 200],
        self.segmentTrackingClient.properties(forKey: "discover_search_results_count", as: Int.self)
      )

      let emptyResponse = [(
        GraphAPI.SearchQuery.self,
        GraphAPI.SearchQuery.Data.emptyResults
      )]

      withEnvironment(apiService: MockService(fetchGraphQLResponses: emptyResponse)) {
        self.hasProjects.assertValues([true, false, true], "No projects before view is visible.")

        self.vm.inputs.searchTextChanged("abcdefgh")

        self.hasProjects.assertValues(
          [true, false, true, false],
          "Projects clear immediately upon entering search."
        )
        self.showEmptyState.assertValues([], "No query for project yet.")

        self.scheduler.advance()

        self.hasProjects.assertValues([true, false, true, false], "No Projects to emit.")
        self.showEmptyState.assertValues([true], "No Projects Found.")

        self.vm.inputs.searchTextChanged("abcdefghasfdsafd")

        self.hasProjects.assertValues([true, false, true, false])
        self.showEmptyState.assertValues([true, false])

        self.scheduler.advance()

        self.hasProjects.assertValues([true, false, true, false])
        self.showEmptyState.assertValues([true, false, true])
      }

      self.vm.inputs.searchTextChanged("")

      self.hasProjects.assertValues([true, false, true, false, true])
      self.showEmptyState.assertValues([true, false, true, false])
      self.isPopularTitleVisible.assertValues([true, false, true])
    }
  }

  // Confirms that clearing search during an in-flight search doesn't cause search results and popular
  // projects to get mixed up.
  func testOrderingOfPopularAndDelayedSearches() {
    let apiDelay = TestCase.interval
    let debounceDelay = TestCase.interval
    let popularResponse = [(
      GraphAPI.SearchQuery.self,
      GraphAPI.SearchQuery.Data.differentFiveResults
    )]

    withEnvironment(
      apiService: MockService(fetchGraphQLResponses: popularResponse),
      debounceInterval: debounceDelay
    ) {
      let projects = TestObserver<[String], Never>()
      self.vm.outputs.projects.map { $0.map { $0.name } }.observe(projects.observer)

      self.vm.inputs.viewDidLoad()
      self.vm.inputs.viewWillAppear(animated: true)
      self.scheduler.advance(by: apiDelay)

      self.hasProjects.assertValues([true], "Popular projects emit immediately.")
      guard let popularProjects = projects.values.last else {
        XCTFail("Expected popular project")
        return
      }

      self.vm.inputs.searchTextChanged("skull graphic tee")

      self.hasProjects.assertValues([true, false], "Clears projects immediately.")

      self.scheduler.advance(by: debounceDelay.halved())

      self.hasProjects.assertValues([true, false], "Doesn't emit projects after a little time.")

      self.vm.inputs.searchTextChanged("")

      self.hasProjects.assertValues([true, false, true], "Brings back popular projets immediately.")
      projects.assertLastValue(popularProjects, "Brings back popular projects immediately.")

      self.scheduler.run()

      self.hasProjects.assertValues(
        [true, false, true],
        "Doesn't search for projects after time enough time passes."
      )
      projects.assertLastValue(popularProjects, "Brings back popular projects immediately.")

      XCTAssertEqual(["Page Viewed"], self.segmentTrackingClient.events)
    }
  }

  // Confirms that entering new search terms cancels previously in-flight API requests for projects,
  // and that ultimately only one set of projects is returned.
  func testCancelingOfSearchResultsWhenEnteringNewSearchTerms() {
    let apiDelay = DispatchTimeInterval.seconds(2)
    let debounceDelay = DispatchTimeInterval.seconds(1)
    let popularResponse = [(
      GraphAPI.SearchQuery.self,
      GraphAPI.SearchQuery.Data.differentFiveResults
    )]

    withEnvironment(
      apiService: MockService(fetchGraphQLResponses: popularResponse),
      apiDelayInterval: apiDelay,
      debounceInterval: debounceDelay
    ) {
      let projects = TestObserver<[String], Never>()
      self.vm.outputs.projects.map { $0.map { $0.name } }.observe(projects.observer)

      self.vm.inputs.viewDidLoad()
      self.vm.inputs.viewWillAppear(animated: true)
      self.scheduler.advance(by: apiDelay)

      self.hasProjects.assertValues([true], "Popular projects load immediately.")

      self.vm.inputs.searchTextChanged("skull")

      self.hasProjects.assertValues([true, false], "Projects clear after entering search term.")

      // wait a little bit of time, but not enough to complete the debounce
      self.scheduler.advance(by: debounceDelay.halved())

      self.hasProjects.assertValues(
        [true, false],
        "No new projects load after waiting enough a little bit of time."
      )

      self.vm.inputs.searchTextChanged("skull graphic")

      self.hasProjects.assertValues([true, false], "No new projects load after entering new search term.")

      // wait a little bit of time, but not enough to complete the debounce
      self.scheduler.advance(by: debounceDelay.halved())

      self.hasProjects.assertValues([true, false], "No new projects load after entering new search term.")

      // Wait enough time for debounced request to be made, but not enough time for it to finish.
      self.scheduler.advance(by: debounceDelay.halved())

      self.hasProjects.assertValues(
        [true, false], "No projects emit after waiting enough time for API to request to be made"
      )

      self.vm.inputs.searchTextChanged("skull graphic tee")

      self.hasProjects.assertValues(
        [true, false],
        "Still no new projects after entering another search term."
      )

      // wait enough time for API request to be fired.
      self.scheduler.advance(by: debounceDelay + apiDelay)

      self.hasProjects.assertValues([true, false, true], "Search projects load after waiting enough time.")

      XCTAssertEqual(
        ["Page Viewed", "Page Viewed"],
        self.segmentTrackingClient.events
      )

      // run out the scheduler
      self.scheduler.run()

      self.hasProjects.assertValues([true, false, true], "Nothing new is emitted.")

      XCTAssertEqual(
        ["Page Viewed", "Page Viewed"],
        self.segmentTrackingClient.events,
        "Nothing new is tracked."
      )
    }
  }

  func testSearchFieldText() {
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: true)
    self.vm.inputs.searchFieldDidBeginEditing()

    self.searchFieldText.assertValueCount(0)

    self.vm.inputs.searchTextChanged("HELLO")

    self.searchFieldText.assertValueCount(0)

    self.vm.inputs.cancelButtonPressed()

    self.searchFieldText.assertValues([""])

    XCTAssertEqual(["Page Viewed"], self.segmentTrackingClient.events)
  }

  func testSearchFieldEditingDidEnd() {
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: true)
    self.vm.inputs.searchFieldDidBeginEditing()

    self.resignFirstResponder.assertValueCount(0)

    self.vm.inputs.searchTextEditingDidEnd()

    self.resignFirstResponder.assertValueCount(1)
  }

  func testSlowTyping() {
    let apiDelay = DispatchTimeInterval.seconds(2)
    let debounceDelay = DispatchTimeInterval.seconds(1)
    let popularResponse = [(
      GraphAPI.SearchQuery.self,
      GraphAPI.SearchQuery.Data.differentFiveResults
    )]

    withEnvironment(
      apiService: MockService(fetchGraphQLResponses: popularResponse),
      apiDelayInterval: apiDelay,
      debounceInterval: debounceDelay
    ) {
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.viewWillAppear(animated: true)
      self.scheduler.advance(by: apiDelay)

      self.vm.inputs.searchFieldDidBeginEditing()

      XCTAssertEqual(["Page Viewed"], self.segmentTrackingClient.events)
      XCTAssertEqual([""], self.segmentTrackingClient.properties(forKey: "discover_search_term"))

      self.vm.inputs.searchTextChanged("d")
      self.scheduler.advance(by: apiDelay + debounceDelay)

      XCTAssertEqual(
        ["Page Viewed", "Page Viewed"],
        self.segmentTrackingClient.events
      )
      XCTAssertEqual(["", "d"], self.segmentTrackingClient.properties(forKey: "discover_search_term"))

      self.vm.inputs.searchTextChanged("do")
      self.scheduler.advance(by: apiDelay + debounceDelay)

      XCTAssertEqual(
        ["Page Viewed", "Page Viewed", "Page Viewed"],
        self.segmentTrackingClient.events
      )
      XCTAssertEqual(["", "d", "do"], self.segmentTrackingClient.properties(forKey: "discover_search_term"))

      self.vm.inputs.searchTextChanged("dog")
      self.scheduler.advance(by: apiDelay + debounceDelay)

      XCTAssertEqual(
        ["Page Viewed", "Page Viewed", "Page Viewed", "Page Viewed"],
        self.segmentTrackingClient.events
      )
      XCTAssertEqual(
        ["", "d", "do", "dog"],
        self.segmentTrackingClient.properties(forKey: "discover_search_term")
      )

      self.vm.inputs.searchTextChanged("dogs")
      self.scheduler.advance(by: apiDelay + debounceDelay)

      XCTAssertEqual(
        [
          "Page Viewed",
          "Page Viewed",
          "Page Viewed",
          "Page Viewed",
          "Page Viewed"
        ],
        self.segmentTrackingClient.events
      )
      XCTAssertEqual(
        ["", "d", "do", "dog", "dogs"],
        self.segmentTrackingClient.properties(forKey: "discover_search_term")
      )
    }
  }

  func testSearchPageViewed_BeforeSearching() {
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: true)

    XCTAssertEqual(["Page Viewed"], self.segmentTrackingClient.events)

    let segmentClientProps = self.segmentTrackingClient.properties.last

    XCTAssertEqual("search", segmentClientProps?["context_page"] as? String)
    XCTAssertEqual("", segmentClientProps?["discover_search_term"] as? String)
    XCTAssertEqual(0, segmentClientProps?["discover_search_results_count"] as? Int)
  }

  func testSearchPageViewed_ReturningAfterSearching() {
    let searchResponse = [(
      GraphAPI.SearchQuery.self,
      GraphAPI.SearchQuery.Data.fiveResults
    )]

    withEnvironment(apiService: MockService(fetchGraphQLResponses: searchResponse)) {
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.viewWillAppear(animated: true)
      self.scheduler.advance()

      self.vm.inputs.searchTextChanged("maverick")
      self.scheduler.advance()

      self.vm.inputs.viewWillAppear(animated: true)

      let segmentClientProps = self.segmentTrackingClient.properties.last

      XCTAssertEqual("maverick", segmentClientProps?["discover_search_term"] as? String)
      XCTAssertEqual(200, segmentClientProps?["discover_search_results_count"] as? Int)
    }
  }
}

internal extension GraphAPI.SearchQuery.Data {
  static var fiveResults: GraphAPI.SearchQuery.Data {
    let url = Bundle(for: SearchViewModelTests.self).url(
      forResource: "SearchQuery_FiveResults",
      withExtension: "json"
    )
    return try! Self(fromResource: url!)
  }

  static var differentFiveResults: GraphAPI.SearchQuery.Data {
    let url = Bundle(for: SearchViewModelTests.self).url(
      forResource: "SearchQuery_AnotherFiveResults",
      withExtension: "json"
    )
    return try! Self(fromResource: url!)
  }

  static var emptyResults: GraphAPI.SearchQuery.Data {
    let url = Bundle(for: SearchViewModelTests.self).url(
      forResource: "SearchQuery_EmptyResults",
      withExtension: "json"
    )
    return try! Self(fromResource: url!)
  }
}
