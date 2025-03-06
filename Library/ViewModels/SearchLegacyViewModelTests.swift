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

  override func setUp() {
    super.setUp()
    self.vm.outputs.changeSearchFieldFocus.map(first).observe(self.changeSearchFieldFocusFocused.observer)
    self.vm.outputs.changeSearchFieldFocus.map(second).observe(self.changeSearchFieldFocusAnimated.observer)
    self.vm.outputs.goToProject.map { _, _, refTag in refTag }.observe(self.goToRefTag.observer)
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
  }

  func testSearchPopularFeatured_RefTag() {
    let projects = (0...10).map { idx in .template |> Project.lens.id .~ (idx + 42) }
    let response = .template |> DiscoveryEnvelope.lens.projects .~ projects

    withEnvironment(apiService: MockService(fetchDiscoveryResponse: response)) {
      self.vm.inputs.viewWillAppear(animated: true)
      self.scheduler.advance()
      self.vm.inputs.tapped(project: projects[0])

      self.goToRefTag.assertValues([RefTag.searchPopularFeatured])
    }
  }

  func testSearchPopular_RefTag() {
    let projects = (0...10).map { idx in .template |> Project.lens.id .~ (idx + 42) }
    let response = .template |> DiscoveryEnvelope.lens.projects .~ projects

    withEnvironment(apiService: MockService(fetchDiscoveryResponse: response)) {
      self.vm.inputs.viewWillAppear(animated: true)
      self.scheduler.advance()
      self.vm.inputs.tapped(project: projects[8])

      self.goToRefTag.assertValues([RefTag.searchPopular])
    }
  }

  func testSearchFeatured_RefTag() {
    let projects = (0...10).map { idx in .template |> Project.lens.id .~ (idx + 42) }
    let response = .template |> DiscoveryEnvelope.lens.projects .~ projects
    let searchProjects = (20...30).map { idx in .template |> Project.lens.id .~ (idx + 42) }
    let searchResponse = .template |> DiscoveryEnvelope.lens.projects .~ searchProjects

    withEnvironment(apiService: MockService(fetchDiscoveryResponse: response)) {
      self.vm.inputs.viewWillAppear(animated: true)
      self.scheduler.advance()

      withEnvironment(apiService: MockService(fetchDiscoveryResponse: searchResponse)) {
        self.vm.inputs.searchFieldDidBeginEditing()
        self.vm.inputs.searchTextChanged("robots")
        self.scheduler.advance()
        self.vm.inputs.tapped(project: searchProjects[0])

        self.goToRefTag.assertValues([RefTag.searchFeatured])
      }
    }
  }

  func testSearch_RefTag() {
    let projects = (0...10).map { idx in .template |> Project.lens.id .~ (idx + 42) }
    let response = .template |> DiscoveryEnvelope.lens.projects .~ projects
    let searchProjects = (20...30).map { idx in .template |> Project.lens.id .~ (idx + 42) }
    let searchResponse = .template |> DiscoveryEnvelope.lens.projects .~ searchProjects

    withEnvironment(apiService: MockService(fetchDiscoveryResponse: response)) {
      self.vm.inputs.viewWillAppear(animated: true)
      self.scheduler.advance()

      withEnvironment(apiService: MockService(fetchDiscoveryResponse: searchResponse)) {
        self.vm.inputs.searchFieldDidBeginEditing()
        self.vm.inputs.searchTextChanged("robots")
        self.scheduler.advance()
        self.vm.inputs.tapped(project: searchProjects[2])

        self.goToRefTag.assertValues([RefTag.search])
      }
    }
  }

  func testProjectCardClicked() {
    let projects = (0...10).map { idx in .template |> Project.lens.id .~ (idx + 42) }
    let response = .template |> DiscoveryEnvelope.lens.projects .~ projects
    let searchProjects = (20...30).map { idx in .template |> Project.lens.id .~ (idx + 42) }
    let searchResponse = .template |> DiscoveryEnvelope.lens.projects .~ searchProjects

    withEnvironment(apiService: MockService(fetchDiscoveryResponse: response)) {
      self.vm.inputs.viewWillAppear(animated: true)
      self.scheduler.advance()

      withEnvironment(apiService: MockService(fetchDiscoveryResponse: searchResponse)) {
        self.vm.inputs.searchFieldDidBeginEditing()
        self.vm.inputs.searchTextChanged("robots")
        self.scheduler.advance()
        self.vm.inputs.tapped(project: searchProjects[0])

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
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: true)
    self.popularLoaderIndicatorIsAnimating.assertValues([true])

    self.scheduler.advance()

    self.popularLoaderIndicatorIsAnimating.assertValues([true, false])

    self.vm.inputs.searchTextChanged("b")

    self.popularLoaderIndicatorIsAnimating.assertValues([true, false])

    self.scheduler.advance()

    self.popularLoaderIndicatorIsAnimating.assertValues([true, false])
  }

  func testSearchLoaderIndicatorIsAnimating() {
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

  func testShowNoSearchResults() {
    let projects = [
      .template |> Project.lens.id .~ 1,
      .template |> Project.lens.id .~ 3,
      .template |> Project.lens.id .~ 4,
      .template |> Project.lens.id .~ 5
    ]
    let response = .template |> DiscoveryEnvelope.lens.projects .~ projects

    withEnvironment(apiService: MockService(fetchDiscoveryResponse: response)) {
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

      let searchResponse = .template |> DiscoveryEnvelope.lens.projects .~ []

      withEnvironment(apiService: MockService(fetchDiscoveryResponse: searchResponse)) {
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

    withEnvironment(debounceInterval: debounceDelay) {
      let projects = TestObserver<[Int], Never>()
      self.vm.outputs.projects.map { $0.map { $0.id } }.observe(projects.observer)

      self.vm.inputs.viewWillAppear(animated: true)
      self.scheduler.advance(by: apiDelay)

      self.hasProjects.assertValues([true], "Popular projects emit immediately.")
      let popularProjects = projects.values.last!

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

    withEnvironment(apiDelayInterval: apiDelay, debounceInterval: debounceDelay) {
      let projects = TestObserver<[Int], Never>()
      self.vm.outputs.projects.map { $0.map { $0.id } }.observe(projects.observer)

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
    self.vm.inputs.viewWillAppear(animated: true)
    self.vm.inputs.searchFieldDidBeginEditing()

    self.resignFirstResponder.assertValueCount(0)

    self.vm.inputs.searchTextEditingDidEnd()

    self.resignFirstResponder.assertValueCount(1)
  }

  func testSlowTyping() {
    let apiDelay = DispatchTimeInterval.seconds(2)
    let debounceDelay = DispatchTimeInterval.seconds(1)

    withEnvironment(apiDelayInterval: apiDelay, debounceInterval: debounceDelay) {
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
    self.vm.inputs.viewWillAppear(animated: true)

    XCTAssertEqual(["Page Viewed"], self.segmentTrackingClient.events)

    let segmentClientProps = self.segmentTrackingClient.properties.last

    XCTAssertEqual("search", segmentClientProps?["context_page"] as? String)
    XCTAssertEqual("", segmentClientProps?["discover_search_term"] as? String)
    XCTAssertEqual(0, segmentClientProps?["discover_search_results_count"] as? Int)
  }

  func testSearchPageViewed_ReturningAfterSearching() {
    let searchResponse = DiscoveryEnvelope.template

    withEnvironment(apiService: MockService(fetchDiscoveryResponse: searchResponse)) {
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
