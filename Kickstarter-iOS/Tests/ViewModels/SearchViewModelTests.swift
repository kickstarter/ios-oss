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

// swiftlint:disable function_body_length
final class SearchViewModelTests: TestCase {
  var vm: SearchViewModelType!

  // Tests a standard flow of searching for projects.
  func testFlow() {
    self.vm = SearchViewModel()

    let hasProjects = TestObserver<Bool, NoError>()
    vm.outputs.projects.map { !$0.isEmpty }.observe(hasProjects.observer)

    let isPopularTitleVisible = TestObserver<Bool, NoError>()
    vm.outputs.isPopularTitleVisible.observe(isPopularTitleVisible.observer)

    hasProjects.assertDidNotEmitValue("No projects before view is visible.")
    isPopularTitleVisible.assertDidNotEmitValue("Popular title is not visible before view is visible.")
    XCTAssertEqual([], trackingClient.events, "No events tracked before view is visible.")

    vm.inputs.viewDidAppear()
    scheduler.advance()

    hasProjects.assertValues([true], "Projects emitted immediately upon view appearing.")
    isPopularTitleVisible.assertValues([true], "Popular title visible upon view appearing.")
    XCTAssertEqual(["Discover Search"], trackingClient.events,
                   "The search view event tracked upon view appearing.")

    vm.inputs.searchTextChanged("skull graphic tee")

    hasProjects.assertValues([true, false], "Projects clear immediately upon entering search.")
    isPopularTitleVisible.assertValues([true, false],
                                       "Popular title hide immediately upon entering search.")

    scheduler.advance()

    hasProjects.assertValues([true, false, true], "Projects emit after waiting enough time.")
    isPopularTitleVisible.assertValues([true, false],
                                       "Popular title visibility still not emit after time has passed.")
    XCTAssertEqual(["Discover Search", "Discover Search Results"], trackingClient.events,
                   "A koala event is tracked for the search results.")
    XCTAssertEqual("skull graphic tee", trackingClient.properties.last!["search_term"] as? String)

    vm.inputs.searchTextChanged("")
    scheduler.advance()

    hasProjects.assertValues([true, false, true, false, true],
                             "Clearing search clears projects and brings back popular projects.")
    isPopularTitleVisible.assertValues([true, false, true],
                                       "Clearing search brings back popular title.")
    XCTAssertEqual(["Discover Search", "Discover Search Results"], trackingClient.events)

    vm.inputs.viewDidAppear()

    hasProjects.assertValues([true, false, true, false, true],
                             "Leaving view and coming back doesn't load more projects.")
    isPopularTitleVisible.assertValues([true, false, true],
                                       "Leaving view and coming back doesn't change popular title")
    XCTAssertEqual(["Discover Search", "Discover Search Results"], trackingClient.events,
                   "Leaving view and coming back doesn't emit more koala events.")
  }

  // Confirms that clearing search during an in-flight search doesn't cause search results and popular
  // projects to get mixed up.
  func testOrderingOfPopularAndDelayedSearches() {
    withEnvironment(debounceInterval: TestCase.interval) {
      self.vm = SearchViewModel()

      let projects = TestObserver<[Int], NoError>()
      vm.outputs.projects.map { $0.map { $0.id } }.observe(projects.observer)
      let hasProjects = TestObserver<Bool, NoError>()
      vm.outputs.projects.map { !$0.isEmpty }.observe(hasProjects.observer)

      vm.inputs.viewDidAppear()
      scheduler.advance()

      hasProjects.assertValues([true], "Popular projects emit immediately.")
      let popularProjects = projects.values.last!

      vm.inputs.searchTextChanged("skull graphic tee")

      hasProjects.assertValues([true, false], "Clears projects immediately.")

      scheduler.advanceByInterval(TestCase.interval / 2.0)

      hasProjects.assertValues([true, false], "Doesn't emit projects after a little time.")

      vm.inputs.searchTextChanged("")
      scheduler.advance()

      hasProjects.assertValues([true, false, true], "Brings back popular projets immediately.")
      projects.assertLastValue(popularProjects, "Brings back popular projects immediately.")

      scheduler.run()

      hasProjects.assertValues([true, false, true],
                               "Doesn't search for projects after time enough time passes.")
      projects.assertLastValue(popularProjects, "Brings back popular projects immediately.")

      XCTAssertEqual(["Discover Search"], trackingClient.events)
    }
  }

  // Confirms that entering new search terms cancels previously in-flight API requests for projects,
  // and that ultimately only one set of projects is returned.
  func testCancelingOfSearchResultsWhenEnteringNewSearchTerms() {
    withEnvironment(apiDelayInterval: TestCase.interval, debounceInterval: TestCase.interval) {
      self.vm = SearchViewModel()

      let projects = TestObserver<[Int], NoError>()
      vm.outputs.projects.map { $0.map { $0.id } }.observe(projects.observer)
      let hasProjects = TestObserver<Bool, NoError>()
      vm.outputs.projects.map { !$0.isEmpty }.observe(hasProjects.observer)

      vm.inputs.viewDidAppear()
      scheduler.advanceByInterval(TestCase.interval)

      hasProjects.assertValues([true], "Popular projects load immediately.")

      vm.inputs.searchTextChanged("skull")

      hasProjects.assertValues([true, false], "Projects clear after entering search term.")

      scheduler.advanceByInterval(TestCase.interval / 2.0)

      hasProjects.assertValues([true, false],
                               "No new projects load after waiting enough a little bit of time.")

      vm.inputs.searchTextChanged("skull graphic")

      hasProjects.assertValues([true, false], "No new projects load after entering new search term.")

      scheduler.advanceByInterval(TestCase.interval / 2.0)

      hasProjects.assertValues([true, false], "No new projects load after entering new search term.")

      // Wait enough time for debounce request to be made, but not enough time for it to finish.
      scheduler.advanceByInterval(TestCase.interval)

      hasProjects.assertValues([true, false],
                               "No projects emit after waiting enough time for API to request to be made")

      vm.inputs.searchTextChanged("skull graphic tee")

      hasProjects.assertValues([true, false], "Still no new projects after entering another search term.")

      // wait enough time for API request to be fired.
      scheduler.advanceByInterval(TestCase.interval)
      // wait enough time for API request to finish.
      scheduler.advanceByInterval(TestCase.interval)

      hasProjects.assertValues([true, false, true], "Search projects load after waiting enough time.")

      XCTAssertEqual(["Discover Search", "Discover Search Results"], trackingClient.events)
    }
  }
}
