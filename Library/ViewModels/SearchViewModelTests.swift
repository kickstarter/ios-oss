// swiftlint:disable force_unwrapping
import Foundation
import XCTest
@testable import KsApi
@testable import ReactiveExtensions
@testable import ReactiveExtensions_TestHelpers
import KsApi
import ReactiveSwift
import Result
@testable import Library
import Prelude

internal final class SearchViewModelTests: TestCase {
  fileprivate let vm: SearchViewModelType! = SearchViewModel()

  fileprivate let changeSearchFieldFocusFocused = TestObserver<Bool, NoError>()
  fileprivate let changeSearchFieldFocusAnimated = TestObserver<Bool, NoError>()
  fileprivate let goToRefTag = TestObserver<RefTag, NoError>()
  private let hasAddedProjects = TestObserver<Bool, NoError>()
  fileprivate let hasProjects = TestObserver<Bool, NoError>()
  fileprivate let isPopularTitleVisible = TestObserver<Bool, NoError>()
  fileprivate let popularLoaderIndicatorIsAnimating = TestObserver<Bool, NoError>()
  fileprivate var noProjects = TestObserver<Bool, NoError>()
  fileprivate let resignFirstResponder = TestObserver<(), NoError>()
  private let scrollToProjectRow = TestObserver<Int, NoError>()
  fileprivate let searchFieldText = TestObserver<String, NoError>()
  fileprivate let searchLoaderIndicatorIsAnimating = TestObserver<Bool, NoError>()
  fileprivate let showEmptyState = TestObserver<Bool, NoError>()
  fileprivate let showEmptyStateParams = TestObserver<DiscoveryParams, NoError>()

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
    self.vm.outputs.scrollToProjectRow.observe(self.scrollToProjectRow.observer)
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
      self.vm.inputs.viewWillAppear(animated: false)
      self.scheduler.advance()
      self.vm.inputs.tapped(project: projects[0])

      self.goToRefTag.assertValues([RefTag.searchPopularFeatured])
    }
  }

  func testSearchPopular_RefTag() {
    let projects = (0...10).map { idx in .template |> Project.lens.id .~ (idx + 42) }
    let response = .template |> DiscoveryEnvelope.lens.projects .~ projects

    withEnvironment(apiService: MockService(fetchDiscoveryResponse: response)) {
      self.vm.inputs.viewWillAppear(animated: false)
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
      self.vm.inputs.viewWillAppear(animated: false)
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
      self.vm.inputs.viewWillAppear(animated: false)
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

  func testCancelSearchField_WithTextChange() {
    self.vm.inputs.viewWillAppear(animated: false)
    self.vm.inputs.searchFieldDidBeginEditing()
    self.vm.inputs.searchTextChanged("a")
    self.vm.inputs.cancelButtonPressed()

    XCTAssertEqual(["Discover Search", "Viewed Search", "Cleared Search Term"], self.trackingClient.events)

    self.vm.inputs.searchFieldDidBeginEditing()
    self.vm.inputs.cancelButtonPressed()

    XCTAssertEqual(["Discover Search", "Viewed Search", "Cleared Search Term"],
                   self.trackingClient.events,
                   "Cancel event not tracked for empty search term.")
  }

  func testCancelSearchField_WithFocusChange() {
    self.vm.inputs.viewWillAppear(animated: false)
    self.vm.inputs.searchFieldDidBeginEditing()
    self.vm.inputs.searchTextChanged("a")

    self.scheduler.advance()

    XCTAssertEqual(["Discover Search", "Viewed Search", "Discover Search Results", "Loaded Search Results"],
                   self.trackingClient.events)

    self.vm.inputs.searchTextEditingDidEnd()

    XCTAssertEqual(["Discover Search", "Viewed Search", "Discover Search Results", "Loaded Search Results"],
                   self.trackingClient.events, "No additional events tracked on focus change.")

    self.vm.inputs.searchFieldDidBeginEditing()
    self.vm.inputs.cancelButtonPressed()

    XCTAssertEqual(
      ["Discover Search", "Viewed Search", "Discover Search Results", "Loaded Search Results",
        "Cleared Search Term"],
      self.trackingClient.events, "Cancel event tracked."
    )
  }

  func testCancelSearchField_WithoutTextChange() {
    self.vm.inputs.viewWillAppear(animated: false)
    self.vm.inputs.searchFieldDidBeginEditing()
    self.vm.inputs.cancelButtonPressed()

    XCTAssertEqual(["Discover Search", "Viewed Search"],
                   self.trackingClient.events,
                   "Canceling empty search does not trigger koala event.")
  }

  func testChangeSearchFieldFocus() {
    self.vm.inputs.viewWillAppear(animated: false)

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
    self.vm.inputs.viewWillAppear(animated: false)
    self.vm.inputs.searchFieldDidBeginEditing()
    self.vm.inputs.searchTextChanged("b")
    self.vm.inputs.clearSearchText()

    XCTAssertEqual(["Discover Search", "Viewed Search", "Cleared Search Term"], self.trackingClient.events)
  }

  func testPopularLoaderIndicatorIsAnimating() {
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: false)
    self.popularLoaderIndicatorIsAnimating.assertValues([true])

    self.scheduler.advance()

    self.popularLoaderIndicatorIsAnimating.assertValues([true, false])

    self.vm.inputs.searchTextChanged("b")

    self.popularLoaderIndicatorIsAnimating.assertValues([true, false])

    self.scheduler.advance()

    self.popularLoaderIndicatorIsAnimating.assertValues([true, false])
  }

  func testSearchLoaderIndicatorIsAnimating() {
    self.vm.inputs.viewWillAppear(animated: false)
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
    XCTAssertEqual([], self.trackingClient.events, "No events tracked before view is visible.")

    self.vm.inputs.viewWillAppear(animated: false)

    self.isPopularTitleVisible.assertValues([])

    self.scheduler.advance()

    self.hasProjects.assertValues([true], "Projects emitted immediately upon view appearing.")
    self.isPopularTitleVisible.assertValues([true], "Popular title visible upon view appearing.")
    XCTAssertEqual(["Discover Search", "Viewed Search"], self.trackingClient.events,
                   "The search view event tracked upon view appearing.")
    XCTAssertEqual([true, nil],
                   self.trackingClient.properties(forKey: Koala.DeprecatedKey, as: Bool.self))

    self.vm.inputs.searchTextChanged("skull graphic tee")

    self.hasProjects.assertValues([true, false], "Projects clear immediately upon entering search.")
    self.isPopularTitleVisible.assertValues([true, false],
                                            "Popular title hide immediately upon entering search.")

    self.scheduler.advance()

    self.hasProjects.assertValues([true, false, true], "Projects emit after waiting enough time.")
    self.isPopularTitleVisible.assertValues([true, false],
                                            "Popular title visibility still not emit after time has passed.")
    XCTAssertEqual(["Discover Search", "Viewed Search", "Discover Search Results", "Loaded Search Results"],
                   self.trackingClient.events,
                   "A koala event is tracked for the search results.")
    XCTAssertEqual([true, nil, true, nil],
                   self.trackingClient.properties(forKey: Koala.DeprecatedKey, as: Bool.self))
    XCTAssertEqual("skull graphic tee", self.trackingClient.properties.last!["search_term"] as? String)

    self.vm.inputs.willDisplayRow(7, outOf: 10)
    self.scheduler.advance()

    XCTAssertEqual(
      [
        "Discover Search", "Viewed Search", "Discover Search Results", "Loaded Search Results",
        "Discover Search Results Load More", "Loaded More Search Results"
      ],
      self.trackingClient.events,
      "A koala event is tracked for the search results.")
    XCTAssertEqual([true, nil, true, nil, true, nil],
                   self.trackingClient.properties(forKey: Koala.DeprecatedKey, as: Bool.self))
    XCTAssertEqual("skull graphic tee", self.trackingClient.properties.last!["search_term"] as? String)

    self.vm.inputs.searchTextChanged("")
    self.scheduler.advance()

    self.hasProjects.assertValues([true, false, true, false, true],
                             "Clearing search clears projects and brings back popular projects.")
    self.isPopularTitleVisible.assertValues([true, false, true],
                                            "Clearing search brings back popular title.")
    XCTAssertEqual(
      [
        "Discover Search", "Viewed Search", "Discover Search Results", "Loaded Search Results",
        "Discover Search Results Load More", "Loaded More Search Results"
      ],
      self.trackingClient.events)

    self.vm.inputs.viewWillAppear(animated: false)

    self.hasProjects.assertValues([true, false, true, false, true],
                             "Leaving view and coming back doesn't load more projects.")
    self.isPopularTitleVisible.assertValues([true, false, true],
                                            "Leaving view and coming back doesn't change popular title")
    XCTAssertEqual(
      [
        "Discover Search", "Viewed Search", "Discover Search Results", "Loaded Search Results",
        "Discover Search Results Load More", "Loaded More Search Results", "Discover Search", "Viewed Search"
      ],
      self.trackingClient.events)
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
      XCTAssertEqual([], self.trackingClient.events, "No events tracked before view is visible.")

      self.vm.inputs.viewWillAppear(animated: false)

      self.isPopularTitleVisible.assertValues([])

      self.scheduler.advance()

      self.hasProjects.assertValues([true], "Projects emitted immediately upon view appearing.")
      self.isPopularTitleVisible.assertValues([true], "Popular title visible upon view appearing.")
      XCTAssertEqual(["Discover Search", "Viewed Search"], self.trackingClient.events,
                     "The search view event tracked upon view appearing.")
      XCTAssertEqual([true, nil],
                     self.trackingClient.properties(forKey: Koala.DeprecatedKey, as: Bool.self))

      self.vm.inputs.searchTextChanged("skull graphic tee")

      self.hasProjects.assertValues([true, false], "Projects clear immediately upon entering search.")
      self.isPopularTitleVisible.assertValues([true, false],
                                              "Popular title hide immediately upon entering search.")

      self.scheduler.advance()

      self.hasProjects.assertValues([true, false, true], "Projects emit after waiting enough time.")
      self.isPopularTitleVisible.assertValues([true, false],
                                            "Popular title visibility still not emit after time has passed.")
      XCTAssertEqual(["Discover Search", "Viewed Search", "Discover Search Results", "Loaded Search Results"],
                     self.trackingClient.events,
                     "A koala event is tracked for the search results.")
      XCTAssertEqual([true, nil, true, nil],
                     self.trackingClient.properties(forKey: Koala.DeprecatedKey, as: Bool.self))
      XCTAssertEqual("skull graphic tee", self.trackingClient.properties.last!["search_term"] as? String)

      let searchResponse = .template |> DiscoveryEnvelope.lens.projects .~ []

      withEnvironment(apiService: MockService(fetchDiscoveryResponse: searchResponse)) {
        self.hasProjects.assertValues([true, false, true], "No projects before view is visible.")

        self.vm.inputs.searchTextChanged("abcdefgh")

        self.hasProjects.assertValues([true, false, true, false],
                                      "Projects clear immediately upon entering search.")
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
      let projects = TestObserver<[Int], NoError>()
      self.vm.outputs.projects.map { $0.map { $0.id } }.observe(projects.observer)

      self.vm.inputs.viewWillAppear(animated: false)
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

      self.hasProjects.assertValues([true, false, true],
                               "Doesn't search for projects after time enough time passes.")
      projects.assertLastValue(popularProjects, "Brings back popular projects immediately.")

      XCTAssertEqual(["Discover Search", "Viewed Search"], self.trackingClient.events)
    }
  }

  // Confirms that entering new search terms cancels previously in-flight API requests for projects,
  // and that ultimately only one set of projects is returned.
  func testCancelingOfSearchResultsWhenEnteringNewSearchTerms() {
    let apiDelay = DispatchTimeInterval.seconds(2)
    let debounceDelay = DispatchTimeInterval.seconds(1)

    withEnvironment(apiDelayInterval: apiDelay, debounceInterval: debounceDelay) {
      let projects = TestObserver<[Int], NoError>()
      self.vm.outputs.projects.map { $0.map { $0.id } }.observe(projects.observer)

      self.vm.inputs.viewWillAppear(animated: false)
      self.scheduler.advance(by: apiDelay)

      self.hasProjects.assertValues([true], "Popular projects load immediately.")

      self.vm.inputs.searchTextChanged("skull")

      self.hasProjects.assertValues([true, false], "Projects clear after entering search term.")

      // wait a little bit of time, but not enough to complete the debounce
      self.scheduler.advance(by: debounceDelay.halved())

      self.hasProjects.assertValues([true, false],
                                    "No new projects load after waiting enough a little bit of time.")

      self.vm.inputs.searchTextChanged("skull graphic")

      self.hasProjects.assertValues([true, false], "No new projects load after entering new search term.")

      // wait a little bit of time, but not enough to complete the debounce
      self.scheduler.advance(by: debounceDelay.halved())

      self.hasProjects.assertValues([true, false], "No new projects load after entering new search term.")

      // Wait enough time for debounced request to be made, but not enough time for it to finish.
      self.scheduler.advance(by: debounceDelay.halved())

      self.hasProjects.assertValues(
        [true, false], "No projects emit after waiting enough time for API to request to be made")

      self.vm.inputs.searchTextChanged("skull graphic tee")

      self.hasProjects.assertValues([true, false],
                                    "Still no new projects after entering another search term.")

      // wait enough time for API request to be fired.
      self.scheduler.advance(by: debounceDelay + apiDelay)

      self.hasProjects.assertValues([true, false, true], "Search projects load after waiting enough time.")
      XCTAssertEqual(["Discover Search", "Viewed Search", "Discover Search Results", "Loaded Search Results"],
                     self.trackingClient.events)

      // run out the scheduler
      self.scheduler.run()

      self.hasProjects.assertValues([true, false, true], "Nothing new is emitted.")
      XCTAssertEqual(["Discover Search", "Viewed Search", "Discover Search Results", "Loaded Search Results"],
                     self.trackingClient.events,
                     "Nothing new is tracked.")
    }
  }

  func testSearchFieldText() {
    self.vm.inputs.viewWillAppear(animated: false)
    self.vm.inputs.searchFieldDidBeginEditing()

    self.searchFieldText.assertValues([])

    self.vm.inputs.searchTextChanged("HELLO")

    self.searchFieldText.assertValues([])

    self.vm.inputs.cancelButtonPressed()

    self.searchFieldText.assertValues([""])
    XCTAssertEqual(["Discover Search", "Viewed Search", "Cleared Search Term"], self.trackingClient.events)
  }

  func testSearchFieldEditingDidEnd() {
    self.vm.inputs.viewWillAppear(animated: false)
    self.vm.inputs.searchFieldDidBeginEditing()

    self.resignFirstResponder.assertValueCount(0)

    self.vm.inputs.searchTextEditingDidEnd()

    self.resignFirstResponder.assertValueCount(1)
  }

  func testSlowTyping() {
    let apiDelay = DispatchTimeInterval.seconds(2)
    let debounceDelay = DispatchTimeInterval.seconds(1)

    withEnvironment(apiDelayInterval: apiDelay, debounceInterval: debounceDelay) {
      self.vm.inputs.viewWillAppear(animated: false)
      self.scheduler.advance(by: apiDelay)

      self.vm.inputs.searchFieldDidBeginEditing()

      XCTAssertEqual(["Discover Search", "Viewed Search"], self.trackingClient.events)

      self.vm.inputs.searchTextChanged("d")
      self.scheduler.advance(by: apiDelay + debounceDelay)

      XCTAssertEqual(
        ["Discover Search", "Viewed Search", "Discover Search Results", "Loaded Search Results"],
        self.trackingClient.events)

      self.vm.inputs.searchTextChanged("do")
      self.scheduler.advance(by: apiDelay + debounceDelay)

      XCTAssertEqual(
        [
          "Discover Search", "Viewed Search", "Discover Search Results", "Loaded Search Results",
          "Discover Search Results", "Loaded Search Results"
        ],
        self.trackingClient.events)

      self.vm.inputs.searchTextChanged("dog")
      self.scheduler.advance(by: apiDelay + debounceDelay)

      XCTAssertEqual(
        [
          "Discover Search", "Viewed Search", "Discover Search Results", "Loaded Search Results",
          "Discover Search Results", "Loaded Search Results", "Discover Search Results",
          "Loaded Search Results"
        ],
        self.trackingClient.events)

      self.vm.inputs.searchTextChanged("dogs")
      self.scheduler.advance(by: apiDelay + debounceDelay)

      XCTAssertEqual(
        [
          "Discover Search", "Viewed Search", "Discover Search Results", "Loaded Search Results",
          "Discover Search Results", "Loaded Search Results", "Discover Search Results",
          "Loaded Search Results", "Discover Search Results", "Loaded Search Results"
        ],
        self.trackingClient.events)
    }
  }

  func testScrollAndUpdateProjects_ViaProjectNavigator() {
    let playlist = (0...10).map { idx in .template |> Project.lens.id .~ (idx + 42) }
    let projectEnv = .template
      |> DiscoveryEnvelope.lens.projects .~ playlist

    let playlist2 = (0...20).map { idx in .template |> Project.lens.id .~ (idx + 82) }
    let projectEnv2 = .template
      |> DiscoveryEnvelope.lens.projects .~ playlist2

    withEnvironment(apiService: MockService(fetchDiscoveryResponse: projectEnv)) {
      self.vm.inputs.viewWillAppear(animated: false)

      self.scheduler.advance()

      self.vm.inputs.willDisplayRow(0, outOf: playlist.count)
      self.vm.inputs.willDisplayRow(1, outOf: playlist.count)
      self.vm.inputs.willDisplayRow(2, outOf: playlist.count)
      self.vm.inputs.willDisplayRow(3, outOf: playlist.count)
      self.vm.inputs.willDisplayRow(4, outOf: playlist.count)
      self.vm.inputs.willDisplayRow(5, outOf: playlist.count)

      self.hasAddedProjects.assertValues([true], "Projects are loaded.")

      self.vm.inputs.searchFieldDidBeginEditing()
      self.vm.inputs.searchTextChanged("robots")

      self.hasAddedProjects.assertValues([true, false], "Empty array emits.")

      self.scheduler.advance()

      self.vm.inputs.willDisplayRow(0, outOf: playlist.count)
      self.vm.inputs.willDisplayRow(1, outOf: playlist.count)
      self.vm.inputs.willDisplayRow(2, outOf: playlist.count)
      self.vm.inputs.willDisplayRow(3, outOf: playlist.count)
      self.vm.inputs.willDisplayRow(4, outOf: playlist.count)
      self.vm.inputs.willDisplayRow(5, outOf: playlist.count)

      self.hasAddedProjects.assertValues([true, false, true], "New projects are loaded.")

      self.vm.inputs.tapped(project: playlist[4])
      self.vm.inputs.transitionedToProject(at: 5, outOf: playlist.count)

      self.scrollToProjectRow.assertValues([5])

      self.vm.inputs.transitionedToProject(at: 6, outOf: playlist.count)

      self.scrollToProjectRow.assertValues([5, 6])

      self.vm.inputs.transitionedToProject(at: 7, outOf: playlist.count)

      self.scrollToProjectRow.assertValues([5, 6, 7])

      withEnvironment(apiService: MockService(fetchDiscoveryResponse: projectEnv2)) {
        self.vm.inputs.transitionedToProject(at: 8, outOf: playlist.count)

        self.scheduler.advance()

        self.scrollToProjectRow.assertValues([5, 6, 7, 8])

        self.hasAddedProjects.assertValues([true, false, true, true], "Paginated projects are loaded.")

        self.vm.inputs.transitionedToProject(at: 7, outOf: playlist2.count)

        self.scrollToProjectRow.assertValues([5, 6, 7, 8, 7])
      }
    }
  }
}
