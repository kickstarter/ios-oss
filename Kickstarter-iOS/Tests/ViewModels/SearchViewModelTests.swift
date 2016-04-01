import Foundation
import XCTest
@testable import Kickstarter_iOS
@testable import KsApi
@testable import KsApi_TestHelpers
@testable import ReactiveExtensions
@testable import ReactiveExtensions_TestHelpers
import Models
import ReactiveCocoa
import Result
@testable import Library

final class SearchViewModelTests: XCTestCase {
  let service = MockService()
  let scheduler = TestScheduler()
  let trackingClient = MockTrackingClient()
  var vm: SearchViewModelType!

  override func setUp() {
    super.setUp()
    AppEnvironment.pushEnvironment(
      apiService: service,
      apiThrottleInterval: 1.0,
      debounceInterval: 1.0,
      koala: Koala(client: trackingClient),
      scheduler: scheduler
    )
  }

  override func tearDown() {
    super.tearDown()
    AppEnvironment.popEnvironment()
  }

  // Tests a standard flow of searching for projects.
  func testFlow() {
    withEnvironment(apiThrottleInterval: 0.0, debounceInterval: 1.0) {
      self.vm = SearchViewModel()

      let hasProjects = TestObserver<Bool, NoError>()
      vm.outputs.projects.map { $0.count > 0 }.observe(hasProjects.observer)

      let isPopularTitleVisible = TestObserver<Bool, NoError>()
      vm.outputs.isPopularTitleVisible.observe(isPopularTitleVisible.observer)

      hasProjects.assertDidNotEmitValue("No projects before view is visible.")
      isPopularTitleVisible.assertDidNotEmitValue("Popular title is not visible before view is visible.")
      XCTAssertEqual([], trackingClient.events, "No events tracked before view is visible.")

      vm.inputs.viewDidAppear()

      hasProjects.assertValues([true], "Projects emitted immediately upon view appearing.")
      isPopularTitleVisible.assertValues([true], "Popular title visible upon view appearing.")
      XCTAssertEqual(["Discover Search"], trackingClient.events, "The search view event tracked upon view appearing.")

      vm.inputs.searchTextChanged("skull graphic tee")

      hasProjects.assertValues([true, false], "Projects clear immediately upon entering search.")
      isPopularTitleVisible.assertValues([true, false], "Popular title hide immediately upon entering search.")

      scheduler.advanceByInterval(0.5)

      hasProjects.assertValues([true, false], "Projects don't emit after a little bit of time.")
      isPopularTitleVisible.assertValues([true, false], "Popular title visibility not change after a little bit of time.")

      scheduler.advanceByInterval(0.5)

      hasProjects.assertValues([true, false, true], "Projects emit after waiting enough time.")
      isPopularTitleVisible.assertValues([true, false], "Popular title visibility still not emit after time as passed")
      XCTAssertEqual(["Discover Search", "Discover Search Results"], trackingClient.events,
                     "A koala event is tracked for the search results.")
      XCTAssertEqual("skull graphic tee", trackingClient.properties.last!["search_term"] as? String)

      vm.inputs.searchTextChanged("")

      hasProjects.assertValues([true, false, true, false, true], "Clearing search clears projects and brings back popular projects.")
      isPopularTitleVisible.assertValues([true, false, true], "Clearing search brings back popular title.")
      XCTAssertEqual(["Discover Search", "Discover Search Results"], trackingClient.events)

      vm.inputs.viewDidAppear()

      hasProjects.assertValues([true, false, true, false, true],
                               "Leaving view and coming back doesn't load more projects.")
      isPopularTitleVisible.assertValues([true, false, true],
                                         "Leaving view and coming back doesn't change popular title")
      XCTAssertEqual(["Discover Search", "Discover Search Results"], trackingClient.events,
                     "Leaving view and coming back doesn't emit more koala events.")
    }
  }

  // Confirms that clearing search during an in-flight search doesn't cause search results and popular
  // projects to get mixed up.
  func testOrderingOfPopularAndDelayedSearches() {
    withEnvironment(apiThrottleInterval: 1.0, debounceInterval: 1.0) {
      self.vm = SearchViewModel()

      let projects = TestObserver<[Int], NoError>()
      vm.outputs.projects.map { $0.map { $0.id } }.observe(projects.observer)
      let hasProjects = TestObserver<Bool, NoError>()
      vm.outputs.projects.map { $0.count > 0 }.observe(hasProjects.observer)

      vm.inputs.viewDidAppear()

      hasProjects.assertValues([true], "Popular projects emit immediately.")
      let popularProjects = projects.values.last!

      vm.inputs.searchTextChanged("skull graphic tee")

      hasProjects.assertValues([true, false], "Clears projects immediately.")

      scheduler.advanceByInterval(1.5)

      hasProjects.assertValues([true, false], "Doesn't emit projects after a little time.")

      vm.inputs.searchTextChanged("")

      hasProjects.assertValues([true, false, true], "Brings back popular projets immediately.")
      projects.assertLastValue(popularProjects, "Brings back popular projects immediately.")

      scheduler.advanceByInterval(10.0)

      hasProjects.assertValues([true, false, true], "Doesn't search for projects after time enough time passes.")
      projects.assertLastValue(popularProjects, "Brings back popular projects immediately.")

      XCTAssertEqual(["Discover Search"], trackingClient.events)
    }
  }

  // Confirms that entering new search terms cancels previously in-flight API requests for projects,
  // and that ultimately only one set of projects is returned.
  func testCancelingOfSearchResultsWhenEnteringNewSearchTerms() {
    withEnvironment(apiThrottleInterval: 1.0, debounceInterval: 1.0) {
      self.vm = SearchViewModel()

      let projects = TestObserver<[Int], NoError>()
      vm.outputs.projects.map { $0.map { $0.id } }.observe(projects.observer)
      let hasProjects = TestObserver<Bool, NoError>()
      vm.outputs.projects.map { $0.count > 0 }.observe(hasProjects.observer)

      vm.inputs.viewDidAppear()

      hasProjects.assertValues([true], "Popular projects load immediately.")

      vm.inputs.searchTextChanged("skull")

      hasProjects.assertValues([true, false], "Projects clear after entering search term.")

      scheduler.advanceByInterval(0.5)

      hasProjects.assertValues([true, false], "No new projects load after waiting enough a little bit of time.")

      vm.inputs.searchTextChanged("skull graphic")

      hasProjects.assertValues([true, false], "No new projects load after entering new search term.")

      scheduler.advanceByInterval(0.5)

      hasProjects.assertValues([true, false], "No new projects load after entering new search term.")

      scheduler.advanceByInterval(1.0)

      hasProjects.assertValues([true, false], "No new projects load after waiting enough time for the API request to be made but not complete.")

      vm.inputs.searchTextChanged("skull graphic tee")

      hasProjects.assertValues([true, false], "Still no new projects after entering another search term.")

      // TODO: This is hacky right now. We need two `advanceByInterval`s cause we have to push through
      // the `debounce` scheduler AND the `delay` scheduler :/ We should find a better way...
      scheduler.advanceByInterval(1.0)
      scheduler.advanceByInterval(1.0)

      hasProjects.assertValues([true, false, true], "Search projects load after waiting enough time.")

      XCTAssertEqual(["Discover Search", "Discover Search Results"], trackingClient.events)
    }
  }
}
