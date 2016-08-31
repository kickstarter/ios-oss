@testable import KsApi
@testable import Library
@testable import ReactiveExtensions_TestHelpers
import Prelude
import ReactiveCocoa
import Result
import UIKit
import XCTest

internal final class DiscoveryViewModelTests: TestCase {
  private let vm: DiscoveryViewModelType = DiscoveryViewModel()

  private let configureDataSource = TestObserver<[DiscoveryParams.Sort], NoError>()
  private let configureNavigationHeader = TestObserver<DiscoveryParams, NoError>()
  private let loadFilterIntoDataSource = TestObserver<DiscoveryParams, NoError>()
  private let navigateToSort = TestObserver<DiscoveryParams.Sort, NoError>()
  private let navigateDirection = TestObserver<UIPageViewControllerNavigationDirection, NoError>()
  private let selectSortPage = TestObserver<DiscoveryParams.Sort, NoError>()
  private let updateSortPagerStyle = TestObserver<Int?, NoError>()

  let initialParams = .defaults
    |> DiscoveryParams.lens.staffPicks .~ true
    |> DiscoveryParams.lens.includePOTD .~ true

  let categoryParams = .defaults |> DiscoveryParams.lens.category .~ .art
  let subcategoryParams = .defaults |> DiscoveryParams.lens.category .~ .documentary
  let starredParams = .defaults |> DiscoveryParams.lens.starred .~ true

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.loadFilterIntoDataSource.observe(self.loadFilterIntoDataSource.observer)
    self.vm.outputs.configurePagerDataSource.observe(self.configureDataSource.observer)
    self.vm.outputs.navigateToSort.map { $0.0 }.observe(self.navigateToSort.observer)
    self.vm.outputs.navigateToSort.map { $0.1 }.observe(self.navigateDirection.observer)
    self.vm.outputs.selectSortPage.observe(self.selectSortPage.observer)
    self.vm.outputs.updateSortPagerStyle.observe(self.updateSortPagerStyle.observer)
    self.vm.outputs.configureNavigationHeader.observe(self.configureNavigationHeader.observer)
  }

  func testConfigureDataSource() {
    self.configureDataSource.assertValueCount(0, "Data source doesn't configure immediately.")

    self.vm.inputs.viewDidLoad()

    self.configureDataSource.assertValueCount(1, "Data source configures after view loads.")
  }

  func trackViewAppearedEvent() {
    self.vm.inputs.viewDidLoad()

    XCTAssertEqual([], self.trackingClient.events)

    self.vm.inputs.viewWillAppear(animated: false)

    XCTAssertEqual(["Viewed Discovery"], self.trackingClient.events)
    XCTAssertEqual(["magic"], self.trackingClient.properties(forKey: "discover_sort"))
    XCTAssertEqual([true], self.trackingClient.properties(forKey: "discover_staff_picks", as: Bool.self))

    self.vm.inputs.filter(withParams: categoryParams)

    XCTAssertEqual(["Viewed Discovery", "Viewed Discovery"], self.trackingClient.events)
    XCTAssertEqual(["magic", "magic"], self.trackingClient.properties(forKey: "discover_sort"))
    XCTAssertEqual([1], self.trackingClient.properties(forKey: "category_id", as: Int.self))

    self.vm.inputs.viewWillAppear(animated: true)

    XCTAssertEqual(["Viewed Discovery", "Viewed Discovery"], self.trackingClient.events, "Does not emit")
    XCTAssertEqual(["magic", "magic"], self.trackingClient.properties(forKey: "discover_sort"))
    XCTAssertEqual([1], self.trackingClient.properties(forKey: "category_id", as: Int.self))
  }

  func testLoadFilterIntoDataSource() {
    self.loadFilterIntoDataSource.assertValueCount(0)

    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: false)

    self.loadFilterIntoDataSource.assertValues([initialParams],
                                               "Initial params load into data source immediately.")

    self.vm.inputs.filter(withParams: starredParams)

    self.loadFilterIntoDataSource.assertValues([initialParams, starredParams],
                                               "New params load into data source after selecting.")
  }

  func testConfigureNavigationHeader() {
    self.configureNavigationHeader.assertValueCount(0)

    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: false)

    self.configureNavigationHeader.assertValues([initialParams])
  }

  func testOrdering() {
    let test = TestObserver<String, NoError>()
    Signal.merge(
      self.vm.outputs.configurePagerDataSource.mapConst("configureDataSource"),
      self.vm.outputs.loadFilterIntoDataSource.mapConst("loadFilterIntoDataSource")
    ).observe(test.observer)

    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: false)

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

    self.selectSortPage.assertValues([.popular], "Select the popular page in the pager.")
    self.navigateToSort.assertValues([], "Don't navigate to a page.")
    self.navigateDirection.assertValues([], "Don't navigate to a page.")

    self.vm.inputs.willTransition(toPage: 2)
    self.vm.inputs.pageTransition(completed: true)

    self.selectSortPage.assertValues([.popular, .newest], "Select the newest page in the pager.")
    self.navigateToSort.assertValues([], "Navigate to the newest page.")
    self.navigateDirection.assertValues([], "Navigate forward to the page.")

    self.vm.inputs.sortPagerSelected(sort: .magic)

    self.selectSortPage.assertValues([.popular, .newest, .magic], "Select the magic page in the pager.")
    self.navigateToSort.assertValues([.magic], "Navigate to the magic page.")
    self.navigateDirection.assertValues([.Reverse], "Navigate backwards to the page.")

    self.vm.inputs.sortPagerSelected(sort: .magic)

    self.selectSortPage.assertValues([.popular, .newest, .magic],
                                     "Selecting the same page again emits nothing new.")
    self.navigateToSort.assertValues([.magic],
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

    XCTAssertEqual(["Selected Discovery Sort"], self.trackingClient.events,
                   "Swipe event tracked once the transition completes.")
    XCTAssertEqual(["popularity"], self.trackingClient.properties(forKey: "discover_sort"),
                   "Correct sort is tracked.")
    XCTAssertEqual(["swipe"], self.trackingClient.properties(forKey: "gesture_type"))

    self.vm.inputs.sortPagerSelected(sort: .newest)

    XCTAssertEqual(["Selected Discovery Sort", "Selected Discovery Sort"],
                   self.trackingClient.events,
                   "Event is tracked when a sort is chosen from the pager.")
    XCTAssertEqual(["popularity", "newest"],
                   self.trackingClient.properties(forKey: "discover_sort"),
                   "Correct sort is tracked.")
    XCTAssertEqual(["swipe", "tap"], self.trackingClient.properties(forKey: "gesture_type"))

    self.vm.inputs.sortPagerSelected(sort: .newest)

    XCTAssertEqual(["Selected Discovery Sort", "Selected Discovery Sort"],
                   self.trackingClient.events,
                   "Selecting the same sort again does not track another event.")
    XCTAssertEqual(["popularity", "newest"],
                   self.trackingClient.properties(forKey: "discover_sort"))
  }

  func testUpdateSortPagerStyle() {
    self.vm.inputs.viewDidLoad()

    self.updateSortPagerStyle.assertValueCount(0)

    self.vm.inputs.filter(withParams: categoryParams)

    self.updateSortPagerStyle.assertValues([1], "Emits the category id")

    self.vm.inputs.filter(withParams: categoryParams)

    self.updateSortPagerStyle.assertValues([1], "Does not emit a repeat value.")

    self.vm.inputs.filter(withParams: subcategoryParams)

    self.updateSortPagerStyle.assertValues([1, 11], "Emits root category id.")
  }
}
