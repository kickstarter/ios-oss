@testable import KsApi
@testable import KsApi_TestHelpers
@testable import Library
@testable import ReactiveExtensions_TestHelpers
import Prelude
import ReactiveCocoa
import Result
import UIKit
import XCTest

internal final class DiscoveryViewModelTests: TestCase {
  private let vm: DiscoveryViewModelType = DiscoveryViewModel()

  private let loadFilterIntoDataSource = TestObserver<DiscoveryParams, NoError>()
  private let configureDataSource = TestObserver<[DiscoveryParams.Sort], NoError>()
  private let filterLabelText = TestObserver<String, NoError>()
  private let goToDiscoveryFilters = TestObserver<SelectableRow, NoError>()
  private let navigateToSort = TestObserver<DiscoveryParams.Sort, NoError>()
  private let navigateDirection = TestObserver<UIPageViewControllerNavigationDirection, NoError>()
  private let selectSortPage = TestObserver<DiscoveryParams.Sort, NoError>()

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.loadFilterIntoDataSource.observe(self.loadFilterIntoDataSource.observer)
    self.vm.outputs.configurePagerDataSource.observe(self.configureDataSource.observer)
    self.vm.outputs.filterLabelText.observe(self.filterLabelText.observer)
    self.vm.outputs.goToDiscoveryFilters.observe(self.goToDiscoveryFilters.observer)
    self.vm.outputs.navigateToSort.map { $0.0 }.observe(self.navigateToSort.observer)
    self.vm.outputs.navigateToSort.map { $0.1 }.observe(self.navigateDirection.observer)
    self.vm.outputs.selectSortPage.observe(self.selectSortPage.observer)
  }

  func testConfigureDataSource() {
    self.configureDataSource.assertValueCount(0, "Data source doesn't configure immediately.")

    self.vm.inputs.viewDidLoad()

    self.configureDataSource.assertValueCount(1, "Data source configures after view loads.")
  }

  func testFilterLabelText() {
    let selectableRow = SelectableRow(isSelected: false, params: .defaults)

    self.filterLabelText.assertValueCount(0)

    self.vm.inputs.viewDidLoad()

    self.filterLabelText.assertValues(["Staff Picks"])

    self.vm.inputs.filterButtonTapped()
    self.vm.inputs.filtersSelected(row: selectableRow |> SelectableRow.lens.params.category .~ Category.art)

    self.filterLabelText.assertValues(["Staff Picks", "Art"])

    self.vm.inputs.filterButtonTapped()
    self.vm.inputs.filtersSelected(row: selectableRow |> SelectableRow.lens.params.starred .~ true)

    self.filterLabelText.assertValues(["Staff Picks", "Art", "Starred"])

    self.vm.inputs.filterButtonTapped()
    self.vm.inputs.filtersSelected(row: selectableRow |> SelectableRow.lens.params.social .~ true)

    self.filterLabelText.assertValues(["Staff Picks", "Art", "Starred", "Friends Backed"])

    self.vm.inputs.filterButtonTapped()
    self.vm.inputs.filtersSelected(row: selectableRow)

    self.filterLabelText.assertValues(["Staff Picks", "Art", "Starred", "Friends Backed", "Everything"])
  }

  func testGoToDiscoveryFilters() {
    let initialParams = .defaults
      |> DiscoveryParams.lens.staffPicks .~ true
      |> DiscoveryParams.lens.includePOTD .~ true
    let initialSelectedRow = SelectableRow(isSelected: true, params: initialParams)
    let selectableRow = SelectableRow(
      isSelected: false,
      params: .defaults |> DiscoveryParams.lens.category .~ Category.art
    )

    self.vm.inputs.viewDidLoad()

    self.vm.inputs.filterButtonTapped()
    self.goToDiscoveryFilters.assertValues([initialSelectedRow],
                                           "Go to discovery filters with initial params.")

    self.vm.inputs.filtersSelected(row: selectableRow)
    self.vm.inputs.filterButtonTapped()

    self.goToDiscoveryFilters.assertValues([initialSelectedRow, selectableRow],
                                           "Go to discovery filters with currently selected params.")
  }

  func testLoadFilterIntoDataSource() {
    let initialParams = .defaults
      |> DiscoveryParams.lens.staffPicks .~ true
      |> DiscoveryParams.lens.includePOTD .~ true
    let selectableRow = SelectableRow(
      isSelected: false,
      params: .defaults |> DiscoveryParams.lens.category .~ Category.art
    )

    self.vm.inputs.viewDidLoad()

    self.loadFilterIntoDataSource.assertValues([initialParams],
                                               "Initial params load into data source immediately.")

    self.vm.inputs.filterButtonTapped()
    self.vm.inputs.filtersSelected(row: selectableRow)

    self.loadFilterIntoDataSource.assertValues([initialParams, selectableRow.params],
                                               "New params load into data source after selecting.")
  }

  func testOrdering() {
    let test = TestObserver<String, NoError>()
    Signal.merge(
      self.vm.outputs.configurePagerDataSource.mapConst("configureDataSource"),
      self.vm.outputs.loadFilterIntoDataSource.mapConst("loadFilterIntoDataSource")
    ).observe(test.observer)

    self.vm.inputs.viewDidLoad()

    test.assertValues(["configureDataSource", "loadFilterIntoDataSource"],
                      "The data source should be configured first, and then the filter changed.")
  }

  /**
   Tests the ways in which a user can swipe between sorts and select sorts from the page.
   */
  func testNavigatingSorts() {
    self.vm.inputs.viewDidLoad()

    self.selectSortPage.assertValues([], "Nothing emits at first.")
    self.navigateToSort.assertValues([], "Nothing emits at first.")
    self.navigateDirection.assertValues([], "Nothing emits at first.")

    self.vm.inputs.willTransition(toPage: 1)

    self.selectSortPage.assertValues([], "Nothing emits when a swipe transition starts.")
    self.navigateToSort.assertValues([], "Nothing emits when a swipe transition starts.")
    self.navigateDirection.assertValues([], "Nothing emits when a swipe transition starts.")

    self.vm.inputs.pageTransition(completed: false)

    self.selectSortPage.assertValues([], "Nothing emits when a transition doesn't complete.")
    self.navigateToSort.assertValues([], "Nothing emits when a transition doesn't complete.")
    self.navigateDirection.assertValues([], "Nothing emits when a transition doesn't complete.")

    self.vm.inputs.willTransition(toPage: 1)

    self.selectSortPage.assertValues([], "Nothing emits when a swipe transition starts.")
    self.navigateToSort.assertValues([], "Nothing emits when a swipe transition starts.")
    self.navigateDirection.assertValues([], "Nothing emits when a swipe transition starts.")

    self.vm.inputs.pageTransition(completed: true)

    self.selectSortPage.assertValues([.Popular], "Select the popular page in the pager.")
    self.navigateToSort.assertValues([], "Don't navigate to a page.")
    self.navigateDirection.assertValues([], "Don't navigate to a page.")

    self.vm.inputs.willTransition(toPage: 2)
    self.vm.inputs.pageTransition(completed: true)

    self.selectSortPage.assertValues([.Popular, .Newest], "Select the newest page in the pager.")
    self.navigateToSort.assertValues([], "Navigate to the newest page.")
    self.navigateDirection.assertValues([], "Navigate forward to the page.")

    self.vm.inputs.sortPagerSelected(sort: .Magic)

    self.selectSortPage.assertValues([.Popular, .Newest, .Magic], "Select the magic page in the pager.")
    self.navigateToSort.assertValues([.Magic], "Navigate to the magic page.")
    self.navigateDirection.assertValues([.Reverse], "Navigate backwards to the page.")

    self.vm.inputs.sortPagerSelected(sort: .Magic)

    self.selectSortPage.assertValues([.Popular, .Newest, .Magic],
                                     "Selecting the same page again emits nothing new.")
    self.navigateToSort.assertValues([.Magic],
                                     "Selecting the same page again emits nothing new.")
    self.navigateDirection.assertValues([.Reverse],
                                        "Selecting the same page again emits nothing new.")
  }

  /**
   Tests that events are tracked correctly while swiping sorts and selecting sorts from the page.
   */
  func testSortSwipeEventTracking() {
    self.vm.inputs.viewDidLoad()

    XCTAssertEqual([], self.trackingClient.events)

    self.vm.inputs.willTransition(toPage: 1)

    XCTAssertEqual([], self.trackingClient.events, "No events tracked when starting a swipe transition.")

    self.vm.inputs.pageTransition(completed: false)

    XCTAssertEqual([], self.trackingClient.events, "No events tracked when the transition did not complete.")

    self.vm.inputs.willTransition(toPage: 1)

    XCTAssertEqual([], self.trackingClient.events, "Still no events tracked when starting transition.")

    self.vm.inputs.pageTransition(completed: true)

    XCTAssertEqual(["Discover Swiped Sorts"], self.trackingClient.events,
                   "Swipe event tracked once the transition completes.")
    XCTAssertEqual(["popularity"], self.trackingClient.properties(forKey: "discover_sort"),
                   "Correct sort is tracked.")

    self.vm.inputs.sortPagerSelected(sort: .Newest)

    XCTAssertEqual(["Discover Swiped Sorts", "Discover Pager Selected Sort"],
                   self.trackingClient.events,
                   "Event is tracked when a sort is chosen from the pager.")
    XCTAssertEqual(["popularity", "newest"],
                   self.trackingClient.properties(forKey: "discover_sort"),
                   "Correct sort is tracked.")

    self.vm.inputs.sortPagerSelected(sort: .Newest)

    XCTAssertEqual(["Discover Swiped Sorts", "Discover Pager Selected Sort"],
                   self.trackingClient.events,
                   "Selecting the same sort again does not track another event.")
    XCTAssertEqual(["popularity", "newest"],
                   self.trackingClient.properties(forKey: "discover_sort"))
  }
}
