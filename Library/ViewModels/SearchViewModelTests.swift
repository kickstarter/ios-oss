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
  }

  func testSearchPopularFeatured_RefTag() {
    let response = [(
      GraphAPI.SearchQuery.self,
      GraphAPI.SearchQuery.Data.fiveResults
    )]

    withEnvironment(apiService: MockService(fetchGraphQLResponses: response)) {
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
    let popularResponse = [(
      GraphAPI.SearchQuery.self,
      GraphAPI.SearchQuery.Data.fiveResults
    )]

    let searchResponse = [(
      GraphAPI.SearchQuery.self,
      GraphAPI.SearchQuery.Data.differentFiveResults
    )]

    withEnvironment(apiService: MockService(fetchGraphQLResponses: popularResponse)) {
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

  func testShowNoSearchResults() {
    let popularResponse = [(
      GraphAPI.SearchQuery.self,
      GraphAPI.SearchQuery.Data.differentFiveResults
    )]

    withEnvironment(apiService: MockService(fetchGraphQLResponses: popularResponse)) {
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
    let popularResponse = [(
      GraphAPI.SearchQuery.self,
      GraphAPI.SearchQuery.Data.differentFiveResults
    )]

    withEnvironment(
      apiService: MockService(fetchGraphQLResponses: popularResponse),
      apiDelayInterval: apiDelay,
      debounceInterval: debounceDelay
    ) {
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
    let searchResponse = [(
      GraphAPI.SearchQuery.self,
      GraphAPI.SearchQuery.Data.fiveResults
    )]

    withEnvironment(apiService: MockService(fetchGraphQLResponses: searchResponse)) {
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

private extension GraphAPI.SearchQuery.Data {
  static var fiveResults: GraphAPI.SearchQuery.Data {
    let jsonString = """
    {
        "projects": {
          "__typename": "ProjectsConnectionWithTotalCount",
          "nodes": [
            {
              "__typename": "Project",
              "projectId": "UHJvamVjdC0xMDk4NTM3OTEx",
              "name": "The Partisan Necropolis - by Chris Leslie and Oggi Tomic",
              "projectState": "LIVE",
              "image": {
                "__typename": "Photo",
                "id": "UGhvdG8tNDM0MzE4OTI=",
                "url": "https://i-dev.kickstarter.com/assets/043/431/892/52beab139339f438b1e609daf6c14278_original.jpg?anim=false&fit=cover&gravity=auto&height=576&origin=ugc-qa&q=92&v=1703087143&width=1024&sig=i3htIuXplHrKvYMXqEXT1saIn96sl7MzZzK%2BpaG%2BOCU%3D"
              },
              "goal": {
                "__typename": "Money",
                "amount": "20900.0",
                "currency": "GBP",
                "symbol": "£"
              },
              "pledged": {
                "__typename": "Money",
                "amount": "6602.0",
                "currency": "GBP",
                "symbol": "£"
              },
              "isLaunched": true,
              "projectPrelaunchActivated": false,
              "deadlineAt": 1707066000,
              "projectLaunchedAt": 1703244289,
              "isWatched": false,
              "addOns": {
                "__typename": "ProjectRewardConnection",
                "totalCount": 0
              },
              "backersCount": 62,
              "backing": null,
              "category": {
                "__typename": "Category",
                "analyticsName": "Documentary",
                "parentCategory": {
                  "__typename": "Category",
                  "analyticsName": "Film & Video",
                  "id": "Q2F0ZWdvcnktMTE="
                }
              },
              "commentsCount": 0,
              "country": {
                "__typename": "Country",
                "code": "GB"
              },
              "creator": {
                "__typename": "User",
                "id": "VXNlci0yMTE2NTEzODY3",
                "createdProjects": {
                  "__typename": "UserCreatedProjectsConnection",
                  "totalCount": 1
                }
              },
              "currency": "GBP",
              "launchedAt": 1703244289,
              "pid": 1098537911,
              "isInPostCampaignPledgingPhase": false,
              "percentFunded": 31,
              "isPrelaunchActivated": false,
              "projectTags": [],
              "postCampaignPledgingEnabled": false,
              "rewards": {
                "__typename": "ProjectRewardConnection",
                "totalCount": 17
              },
              "state": "LIVE",
              "video": {
                "__typename": "Video",
                "id": "VmlkZW8tMTI2NTQ5Ng=="
              },
              "fxRate": 1.29579502,
              "usdExchangeRate": 1.29579502,
              "posts": {
                "__typename": "PostConnection",
                "totalCount": 1
              }
            },
            {
              "__typename": "Project",
              "projectId": "UHJvamVjdC0yMDI0OTQ4NTM0",
              "name": "Bass Fiddler: Nate Sabat's Debut Solo Record",
              "projectState": "LIVE",
              "image": {
                "__typename": "Photo",
                "id": "UGhvdG8tNDM0ODA3MDg=",
                "url": "https://i-dev.kickstarter.com/assets/043/480/708/daa93d9da2d167db5387653731644490_original.jpg?anim=false&fit=cover&gravity=auto&height=576&origin=ugc-qa&q=92&v=1703693618&width=1024&sig=aq%2FIF47i0dA%2FS6iDhgXASMqJTjQ0m6fk0gDV0wpf1U8%3D"
              },
              "goal": {
                "__typename": "Money",
                "amount": "10000.0",
                "currency": "USD",
                "symbol": "$"
              },
              "pledged": {
                "__typename": "Money",
                "amount": "6126.0",
                "currency": "USD",
                "symbol": "$"
              },
              "isLaunched": true,
              "projectPrelaunchActivated": true,
              "deadlineAt": 1709355540,
              "projectLaunchedAt": 1705452766,
              "isWatched": false,
              "addOns": {
                "__typename": "ProjectRewardConnection",
                "totalCount": 0
              },
              "backersCount": 86,
              "backing": null,
              "category": {
                "__typename": "Category",
                "analyticsName": "Country & Folk",
                "parentCategory": {
                  "__typename": "Category",
                  "analyticsName": "Music",
                  "id": "Q2F0ZWdvcnktMTQ="
                }
              },
              "commentsCount": 0,
              "country": {
                "__typename": "Country",
                "code": "US"
              },
              "creator": {
                "__typename": "User",
                "id": "VXNlci0xMDc4MTkwNTc0",
                "createdProjects": {
                  "__typename": "UserCreatedProjectsConnection",
                  "totalCount": 1
                }
              },
              "currency": "USD",
              "launchedAt": 1705452766,
              "pid": 2024948534,
              "isInPostCampaignPledgingPhase": false,
              "percentFunded": 61,
              "isPrelaunchActivated": true,
              "projectTags": [],
              "postCampaignPledgingEnabled": false,
              "rewards": {
                "__typename": "ProjectRewardConnection",
                "totalCount": 10
              },
              "state": "LIVE",
              "video": {
                "__typename": "Video",
                "id": "VmlkZW8tMTI2NjA4Mg=="
              },
              "fxRate": 1,
              "usdExchangeRate": 1,
              "posts": {
                "__typename": "PostConnection",
                "totalCount": 2
              }
            },
            {
              "__typename": "Project",
              "projectId": "UHJvamVjdC04MzM3MTM1MTc=",
              "name": "Squirrels The Card Game",
              "projectState": "LIVE",
              "image": {
                "__typename": "Photo",
                "id": "UGhvdG8tNDM2NzA2Njg=",
                "url": "https://i-dev.kickstarter.com/assets/043/670/668/3b06fd9ce5d05b7faaf50147259f4958_original.jpg?anim=false&fit=cover&gravity=auto&height=576&origin=ugc-qa&q=92&v=1705359778&width=1024&sig=2IRoQHXS6DtEczHJyG5OoQNXV4C3WCEliZh8n6WQUdE%3D"
              },
              "goal": {
                "__typename": "Money",
                "amount": "1000.0",
                "currency": "USD",
                "symbol": "$"
              },
              "pledged": {
                "__typename": "Money",
                "amount": "9762.0",
                "currency": "USD",
                "symbol": "$"
              },
              "isLaunched": true,
              "projectPrelaunchActivated": true,
              "deadlineAt": 1708606801,
              "projectLaunchedAt": 1706014801,
              "isWatched": false,
              "addOns": {
                "__typename": "ProjectRewardConnection",
                "totalCount": 1
              },
              "backersCount": 242,
              "backing": null,
              "category": {
                "__typename": "Category",
                "analyticsName": "Tabletop Games",
                "parentCategory": {
                  "__typename": "Category",
                  "analyticsName": "Games",
                  "id": "Q2F0ZWdvcnktMTI="
                }
              },
              "commentsCount": 45,
              "country": {
                "__typename": "Country",
                "code": "US"
              },
              "creator": {
                "__typename": "User",
                "id": "VXNlci0xNzE5ODcyNjg3",
                "createdProjects": {
                  "__typename": "UserCreatedProjectsConnection",
                  "totalCount": 28
                }
              },
              "currency": "USD",
              "launchedAt": 1706014801,
              "pid": 833713517,
              "isInPostCampaignPledgingPhase": false,
              "percentFunded": 976,
              "isPrelaunchActivated": true,
              "projectTags": [],
              "postCampaignPledgingEnabled": false,
              "rewards": {
                "__typename": "ProjectRewardConnection",
                "totalCount": 6
              },
              "state": "LIVE",
              "video": {
                "__typename": "Video",
                "id": "VmlkZW8tMTI2OTg1Ng=="
              },
              "fxRate": 1,
              "usdExchangeRate": 1,
              "posts": {
                "__typename": "PostConnection",
                "totalCount": 0
              }
            },
            {
              "__typename": "Project",
              "projectId": "UHJvamVjdC0xNTM0NTM4Nzc2",
              "name": "New Single Project of The Year: Shine On From Lashanda Lee",
              "projectState": "LIVE",
              "image": {
                "__typename": "Photo",
                "id": "UGhvdG8tNDM2NTg1MDg=",
                "url": "https://i-dev.kickstarter.com/assets/043/658/508/110aea3135f7e617557397c636ae4e27_original.png?anim=false&fit=cover&gravity=auto&height=576&origin=ugc-qa&q=92&v=1705279373&width=1024&sig=aqbnSg7Hx6t5Kk2QtpsH8n58p3S8bYlNHxib016x0pw%3D"
              },
              "goal": {
                "__typename": "Money",
                "amount": "11111.0",
                "currency": "USD",
                "symbol": "$"
              },
              "pledged": {
                "__typename": "Money",
                "amount": "1.0",
                "currency": "USD",
                "symbol": "$"
              },
              "isLaunched": true,
              "projectPrelaunchActivated": true,
              "deadlineAt": 1709657781,
              "projectLaunchedAt": 1705337781,
              "isWatched": false,
              "addOns": {
                "__typename": "ProjectRewardConnection",
                "totalCount": 0
              },
              "backersCount": 1,
              "backing": null,
              "category": {
                "__typename": "Category",
                "analyticsName": "World Music",
                "parentCategory": {
                  "__typename": "Category",
                  "analyticsName": "Music",
                  "id": "Q2F0ZWdvcnktMTQ="
                }
              },
              "commentsCount": 0,
              "country": {
                "__typename": "Country",
                "code": "US"
              },
              "creator": {
                "__typename": "User",
                "id": "VXNlci05NDI4NTA4OTg=",
                "createdProjects": {
                  "__typename": "UserCreatedProjectsConnection",
                  "totalCount": 1
                }
              },
              "currency": "USD",
              "launchedAt": 1705337781,
              "pid": 1534538776,
              "isInPostCampaignPledgingPhase": false,
              "percentFunded": 0,
              "isPrelaunchActivated": true,
              "projectTags": [],
              "postCampaignPledgingEnabled": false,
              "rewards": {
                "__typename": "ProjectRewardConnection",
                "totalCount": 5
              },
              "state": "LIVE",
              "video": {
                "__typename": "Video",
                "id": "VmlkZW8tMTI2ODc1MQ=="
              },
              "fxRate": 1,
              "usdExchangeRate": 1,
              "posts": {
                "__typename": "PostConnection",
                "totalCount": 0
              }
            },
            {
              "__typename": "Project",
              "projectId": "UHJvamVjdC0yNDg0NTQ2NTU=",
              "name": "From the Mountain Top - JG Crawford's New Album",
              "projectState": "LIVE",
              "image": {
                "__typename": "Photo",
                "id": "UGhvdG8tNDMzODg4MTU=",
                "url": "https://i-dev.kickstarter.com/assets/043/388/815/f8bc76aabf00bb1fa4642aabd36da03c_original.jpg?anim=false&fit=cover&gravity=auto&height=576&origin=ugc-qa&q=92&v=1702649546&width=1024&sig=%2FGRb6MMCqeB4Ls74Sx%2BcsvkUwODxqk%2FjLMsBwTcAnZk%3D"
              },
              "goal": {
                "__typename": "Money",
                "amount": "20000.0",
                "currency": "USD",
                "symbol": "$"
              },
              "pledged": {
                "__typename": "Money",
                "amount": "4281.0",
                "currency": "USD",
                "symbol": "$"
              },
              "isLaunched": true,
              "projectPrelaunchActivated": true,
              "deadlineAt": 1706979723,
              "projectLaunchedAt": 1704387723,
              "isWatched": false,
              "addOns": {
                "__typename": "ProjectRewardConnection",
                "totalCount": 0
              },
              "backersCount": 31,
              "backing": null,
              "category": {
                "__typename": "Category",
                "analyticsName": "Rock",
                "parentCategory": {
                  "__typename": "Category",
                  "analyticsName": "Music",
                  "id": "Q2F0ZWdvcnktMTQ="
                }
              },
              "commentsCount": 0,
              "country": {
                "__typename": "Country",
                "code": "US"
              },
              "creator": {
                "__typename": "User",
                "id": "VXNlci0xOTg2MjYwNjM4",
                "createdProjects": {
                  "__typename": "UserCreatedProjectsConnection",
                  "totalCount": 1
                }
              },
              "currency": "USD",
              "launchedAt": 1704387723,
              "pid": 248454655,
              "isInPostCampaignPledgingPhase": false,
              "percentFunded": 21,
              "isPrelaunchActivated": true,
              "projectTags": [],
              "postCampaignPledgingEnabled": false,
              "rewards": {
                "__typename": "ProjectRewardConnection",
                "totalCount": 5
              },
              "state": "LIVE",
              "video": {
                "__typename": "Video",
                "id": "VmlkZW8tMTI2NTY1NQ=="
              },
              "fxRate": 1,
              "usdExchangeRate": 1,
              "posts": {
                "__typename": "PostConnection",
                "totalCount": 0
              }
            }
          ],
          "totalCount": 200,
          "pageInfo": {
            "__typename": "PageInfo",
            "endCursor": "eyJpbmRleCI6NCwic2VlZCI6MjkwMzEzM30=",
            "hasNextPage": true
          }
        }
      }
    """

    return try! Self(jsonString: jsonString)
  }

  static var differentFiveResults: GraphAPI.SearchQuery.Data {
    let jsonString = """
      {
          "projects": {
            "__typename": "ProjectsConnectionWithTotalCount",
            "nodes": [
              {
                "__typename": "Project",
                "projectId": "UHJvamVjdC0xODQzNTI2NjA2",
                "name": "Dewey's 100th Birthday",
                "projectState": "LIVE",
                "image": {
                  "__typename": "Photo",
                  "id": "UGhvdG8tNDM4MjM3MTI=",
                  "url": "https://i-dev.kickstarter.com/assets/043/823/712/9fd6cf1c44054bb45a6dd213a3adb1db_original.jpg?anim=false&fit=cover&gravity=auto&height=576&origin=ugc-qa&q=92&v=1706547042&width=1024&sig=d48oLfh%2FhYS%2Fh73zOsT3tpBRfXvPnwyn4%2B02t9rRwQA%3D"
                },
                "goal": {
                  "__typename": "Money",
                  "amount": "5000.0",
                  "currency": "USD",
                  "symbol": "$"
                },
                "pledged": {
                  "__typename": "Money",
                  "amount": "1156.0",
                  "currency": "USD",
                  "symbol": "$"
                },
                "isLaunched": true,
                "projectPrelaunchActivated": false,
                "deadlineAt": 1709146451,
                "projectLaunchedAt": 1706554451,
                "isWatched": false,
                "addOns": {
                  "__typename": "ProjectRewardConnection",
                  "totalCount": 0
                },
                "backersCount": 26,
                "backing": null,
                "category": {
                  "__typename": "Category",
                  "analyticsName": "Country & Folk",
                  "parentCategory": {
                    "__typename": "Category",
                    "analyticsName": "Music",
                    "id": "Q2F0ZWdvcnktMTQ="
                  }
                },
                "commentsCount": 0,
                "country": {
                  "__typename": "Country",
                  "code": "US"
                },
                "creator": {
                  "__typename": "User",
                  "id": "VXNlci05NDU2MzE0NzI=",
                  "createdProjects": {
                    "__typename": "UserCreatedProjectsConnection",
                    "totalCount": 1
                  }
                },
                "currency": "USD",
                "launchedAt": 1706554451,
                "pid": 1843526606,
                "isInPostCampaignPledgingPhase": false,
                "percentFunded": 23,
                "isPrelaunchActivated": false,
                "projectTags": [],
                "postCampaignPledgingEnabled": false,
                "rewards": {
                  "__typename": "ProjectRewardConnection",
                  "totalCount": 6
                },
                "state": "LIVE",
                "video": {
                  "__typename": "Video",
                  "id": "VmlkZW8tMTI3MTMwNg=="
                },
                "fxRate": 1,
                "usdExchangeRate": 1,
                "posts": {
                  "__typename": "PostConnection",
                  "totalCount": 0
                }
              },
              {
                "__typename": "Project",
                "projectId": "UHJvamVjdC04MzM3MTM1MTc=",
                "name": "Squirrels The Card Game",
                "projectState": "LIVE",
                "image": {
                  "__typename": "Photo",
                  "id": "UGhvdG8tNDM2NzA2Njg=",
                  "url": "https://i-dev.kickstarter.com/assets/043/670/668/3b06fd9ce5d05b7faaf50147259f4958_original.jpg?anim=false&fit=cover&gravity=auto&height=576&origin=ugc-qa&q=92&v=1705359778&width=1024&sig=2IRoQHXS6DtEczHJyG5OoQNXV4C3WCEliZh8n6WQUdE%3D"
                },
                "goal": {
                  "__typename": "Money",
                  "amount": "1000.0",
                  "currency": "USD",
                  "symbol": "$"
                },
                "pledged": {
                  "__typename": "Money",
                  "amount": "9762.0",
                  "currency": "USD",
                  "symbol": "$"
                },
                "isLaunched": true,
                "projectPrelaunchActivated": true,
                "deadlineAt": 1708606801,
                "projectLaunchedAt": 1706014801,
                "isWatched": false,
                "addOns": {
                  "__typename": "ProjectRewardConnection",
                  "totalCount": 1
                },
                "backersCount": 242,
                "backing": null,
                "category": {
                  "__typename": "Category",
                  "analyticsName": "Tabletop Games",
                  "parentCategory": {
                    "__typename": "Category",
                    "analyticsName": "Games",
                    "id": "Q2F0ZWdvcnktMTI="
                  }
                },
                "commentsCount": 45,
                "country": {
                  "__typename": "Country",
                  "code": "US"
                },
                "creator": {
                  "__typename": "User",
                  "id": "VXNlci0xNzE5ODcyNjg3",
                  "createdProjects": {
                    "__typename": "UserCreatedProjectsConnection",
                    "totalCount": 28
                  }
                },
                "currency": "USD",
                "launchedAt": 1706014801,
                "pid": 833713517,
                "isInPostCampaignPledgingPhase": false,
                "percentFunded": 976,
                "isPrelaunchActivated": true,
                "projectTags": [],
                "postCampaignPledgingEnabled": false,
                "rewards": {
                  "__typename": "ProjectRewardConnection",
                  "totalCount": 6
                },
                "state": "LIVE",
                "video": {
                  "__typename": "Video",
                  "id": "VmlkZW8tMTI2OTg1Ng=="
                },
                "fxRate": 1,
                "usdExchangeRate": 1,
                "posts": {
                  "__typename": "PostConnection",
                  "totalCount": 0
                }
              },
              {
                "__typename": "Project",
                "projectId": "UHJvamVjdC05ODY5NzM0MTM=",
                "name": "Zero Day War",
                "projectState": "LIVE",
                "image": {
                  "__typename": "Photo",
                  "id": "UGhvdG8tNDMxMDE3Njc=",
                  "url": "https://i-dev.kickstarter.com/assets/043/101/767/8b627f88d7dc85bebede1fa7f413ccc1_original.png?anim=false&fit=cover&gravity=auto&height=576&origin=ugc-qa&q=92&v=1700249512&width=1024&sig=VoPOSpmvD%2Bo03SvtkyeaSykG8RIn7iZzTGZz7iWf4Tw%3D"
                },
                "goal": {
                  "__typename": "Money",
                  "amount": "10000.0",
                  "currency": "USD",
                  "symbol": "$"
                },
                "pledged": {
                  "__typename": "Money",
                  "amount": "9375.0",
                  "currency": "USD",
                  "symbol": "$"
                },
                "isLaunched": true,
                "projectPrelaunchActivated": true,
                "deadlineAt": 1707620400,
                "projectLaunchedAt": 1705413681,
                "isWatched": false,
                "addOns": {
                  "__typename": "ProjectRewardConnection",
                  "totalCount": 3
                },
                "backersCount": 124,
                "backing": null,
                "category": {
                  "__typename": "Category",
                  "analyticsName": "Tabletop Games",
                  "parentCategory": {
                    "__typename": "Category",
                    "analyticsName": "Games",
                    "id": "Q2F0ZWdvcnktMTI="
                  }
                },
                "commentsCount": 11,
                "country": {
                  "__typename": "Country",
                  "code": "US"
                },
                "creator": {
                  "__typename": "User",
                  "id": "VXNlci0yMTAzMDY4NDY1",
                  "createdProjects": {
                    "__typename": "UserCreatedProjectsConnection",
                    "totalCount": 14
                  }
                },
                "currency": "USD",
                "launchedAt": 1705413681,
                "pid": 986973413,
                "isInPostCampaignPledgingPhase": false,
                "percentFunded": 93,
                "isPrelaunchActivated": true,
                "projectTags": [],
                "postCampaignPledgingEnabled": false,
                "rewards": {
                  "__typename": "ProjectRewardConnection",
                  "totalCount": 3
                },
                "state": "LIVE",
                "video": {
                  "__typename": "Video",
                  "id": "VmlkZW8tMTI2NzM0Nw=="
                },
                "fxRate": 1,
                "usdExchangeRate": 1,
                "posts": {
                  "__typename": "PostConnection",
                  "totalCount": 3
                }
              },
              {
                "__typename": "Project",
                "projectId": "UHJvamVjdC0xNzU2NzY1NTgz",
                "name": "Hollywood Dream Project",
                "projectState": "LIVE",
                "image": {
                  "__typename": "Photo",
                  "id": "UGhvdG8tNDM1OTIzMzE=",
                  "url": "https://i-dev.kickstarter.com/assets/043/592/331/24c795d150aa6ff564df001ef380b942_original.jpg?anim=false&fit=cover&gravity=auto&height=576&origin=ugc-qa&q=92&v=1704753683&width=1024&sig=402wJ%2FY3lkGX%2BdPINfSnhnVia77826QUSUB6tAyRKMA%3D"
                },
                "goal": {
                  "__typename": "Money",
                  "amount": "10000.0",
                  "currency": "USD",
                  "symbol": "$"
                },
                "pledged": {
                  "__typename": "Money",
                  "amount": "1005.0",
                  "currency": "USD",
                  "symbol": "$"
                },
                "isLaunched": true,
                "projectPrelaunchActivated": false,
                "deadlineAt": 1709941058,
                "projectLaunchedAt": 1704757058,
                "isWatched": false,
                "addOns": {
                  "__typename": "ProjectRewardConnection",
                  "totalCount": 0
                },
                "backersCount": 6,
                "backing": null,
                "category": {
                  "__typename": "Category",
                  "analyticsName": "Hip-Hop",
                  "parentCategory": {
                    "__typename": "Category",
                    "analyticsName": "Music",
                    "id": "Q2F0ZWdvcnktMTQ="
                  }
                },
                "commentsCount": 0,
                "country": {
                  "__typename": "Country",
                  "code": "US"
                },
                "creator": {
                  "__typename": "User",
                  "id": "VXNlci0xNzU1NTc3NjI3",
                  "createdProjects": {
                    "__typename": "UserCreatedProjectsConnection",
                    "totalCount": 1
                  }
                },
                "currency": "USD",
                "launchedAt": 1704757058,
                "pid": 1756765583,
                "isInPostCampaignPledgingPhase": false,
                "percentFunded": 10,
                "isPrelaunchActivated": false,
                "projectTags": [],
                "postCampaignPledgingEnabled": false,
                "rewards": {
                  "__typename": "ProjectRewardConnection",
                  "totalCount": 1
                },
                "state": "LIVE",
                "video": {
                  "__typename": "Video",
                  "id": "VmlkZW8tMTI2Nzc5Mg=="
                },
                "fxRate": 1,
                "usdExchangeRate": 1,
                "posts": {
                  "__typename": "PostConnection",
                  "totalCount": 0
                }
              },
              {
                "__typename": "Project",
                "projectId": "UHJvamVjdC0xNjcyMDU5Mjc=",
                "name": "Make 100: Cards For Connection",
                "projectState": "LIVE",
                "image": {
                  "__typename": "Photo",
                  "id": "UGhvdG8tNDM0MjU4OTI=",
                  "url": "https://i-dev.kickstarter.com/assets/043/425/892/f9c908ca00815476109ff34ba6720247_original.jpg?anim=false&fit=cover&gravity=auto&height=576&origin=ugc-qa&q=92&v=1703028143&width=1024&sig=UzHpDjEPyvhT%2BY2gaGbwF%2BNG85XOVWEAJN0mGkyQmuo%3D"
                },
                "goal": {
                  "__typename": "Money",
                  "amount": "3300.0",
                  "currency": "USD",
                  "symbol": "$"
                },
                "pledged": {
                  "__typename": "Money",
                  "amount": "1965.0",
                  "currency": "USD",
                  "symbol": "$"
                },
                "isLaunched": true,
                "projectPrelaunchActivated": true,
                "deadlineAt": 1707973140,
                "projectLaunchedAt": 1706036441,
                "isWatched": false,
                "addOns": {
                  "__typename": "ProjectRewardConnection",
                  "totalCount": 2
                },
                "backersCount": 41,
                "backing": null,
                "category": {
                  "__typename": "Category",
                  "analyticsName": "Illustration",
                  "parentCategory": {
                    "__typename": "Category",
                    "analyticsName": "Art",
                    "id": "Q2F0ZWdvcnktMQ=="
                  }
                },
                "commentsCount": 0,
                "country": {
                  "__typename": "Country",
                  "code": "US"
                },
                "creator": {
                  "__typename": "User",
                  "id": "VXNlci0zNDk4MzkxMjU=",
                  "createdProjects": {
                    "__typename": "UserCreatedProjectsConnection",
                    "totalCount": 7
                  }
                },
                "currency": "USD",
                "launchedAt": 1706036441,
                "pid": 167205927,
                "isInPostCampaignPledgingPhase": false,
                "percentFunded": 59,
                "isPrelaunchActivated": true,
                "projectTags": [
                  {
                    "__typename": "Tag",
                    "name": "Make 100"
                  }
                ],
                "postCampaignPledgingEnabled": false,
                "rewards": {
                  "__typename": "ProjectRewardConnection",
                  "totalCount": 4
                },
                "state": "LIVE",
                "video": {
                  "__typename": "Video",
                  "id": "VmlkZW8tMTI3MDEzMg=="
                },
                "fxRate": 1,
                "usdExchangeRate": 1,
                "posts": {
                  "__typename": "PostConnection",
                  "totalCount": 2
                }
              }
            ],
            "totalCount": 200,
            "pageInfo": {
              "__typename": "PageInfo",
              "endCursor": "eyJpbmRleCI6NCwic2VlZCI6MjkwMzEzNH0=",
              "hasNextPage": true
            }
          }
        }
    """

    return try! Self(jsonString: jsonString)
  }

  static var emptyResults: GraphAPI.SearchQuery.Data {
    let jsonString = """
    {
        "projects": {
          "__typename": "ProjectsConnectionWithTotalCount",
          "nodes": [],
          "totalCount": 0,
          "pageInfo": {
            "__typename": "PageInfo",
            "endCursor": null,
            "hasNextPage": false
          }
        }
      }
    """
    return try! Self(jsonString: jsonString)
  }
}
