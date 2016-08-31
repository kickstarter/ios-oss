@testable import ReactiveExtensions_TestHelpers
@testable import KsApi
@testable import Library
@testable import Prelude
import ReactiveCocoa
import Result
import XCTest

// A whole bunch of data to play around with in tests.
private let selectableRowTemplate = SelectableRow(isSelected: false,
                                                  params: .defaults)
private let expandableRowTemplate = ExpandableRow(isExpanded: false,
                                                  params: .defaults,
                                                  selectableRows: [])

private let staffPicksRow = selectableRowTemplate
  |> SelectableRow.lens.params.staffPicks .~ true
  |> SelectableRow.lens.params.includePOTD .~ true
private let starredRow = selectableRowTemplate |> SelectableRow.lens.params.starred .~ true
private let socialRow = selectableRowTemplate |> SelectableRow.lens.params.social .~ true
private let recommendedRow = selectableRowTemplate |> SelectableRow.lens.params.recommended .~ true
private let everythingRow = selectableRowTemplate
private let artSelectableRow = selectableRowTemplate |> SelectableRow.lens.params.category .~ .art
private let documentarySelectableRow = selectableRowTemplate
  |> SelectableRow.lens.params.category .~ .documentary

private let artExpandableRow = expandableRowTemplate
  |> ExpandableRow.lens.params.category .~ .art
  |> ExpandableRow.lens.selectableRows .~ [
    artSelectableRow,
    selectableRowTemplate |> SelectableRow.lens.params.category .~ .illustration
]

private let filmExpandableRow = expandableRowTemplate
  |> ExpandableRow.lens.params.category .~ .filmAndVideo
  |> ExpandableRow.lens.selectableRows .~ [
    selectableRowTemplate |> SelectableRow.lens.params.category .~ .filmAndVideo,
    selectableRowTemplate |> SelectableRow.lens.params.category .~ .documentary
]

internal final class DiscoveryFiltersViewModelTests: TestCase {
  private let vm = DiscoveryFiltersViewModel()

  private let animateInView = TestObserver<Int?, NoError>()
  private let loadCategoryRows = TestObserver<[ExpandableRow], NoError>()
  private let loadCategoryRowsInitialId = TestObserver<Int?, NoError>()
  private let loadCategoryRowsSelectedId = TestObserver<Int?, NoError>()
  private let loadTopRows = TestObserver<[SelectableRow], NoError>()
  private let loadTopRowsInitialId = TestObserver<Int?, NoError>()
  private let notifyDelegateOfSelectedRow = TestObserver<SelectableRow, NoError>()
  private let categories = [ Category.art, .illustration, .filmAndVideo, .documentary ]

  override func setUp() {
    super.setUp()

    self.vm.outputs.animateInView.observe(self.animateInView.observer)
    self.vm.outputs.loadCategoryRows.map(first).observe(self.loadCategoryRows.observer)
    self.vm.outputs.loadCategoryRows.map(second).observe(self.loadCategoryRowsInitialId.observer)
    self.vm.outputs.loadCategoryRows.map { $0.2 }.observe(self.loadCategoryRowsSelectedId.observer)
    self.vm.outputs.loadTopRows.map(first).observe(self.loadTopRows.observer)
    self.vm.outputs.loadTopRows.map(second).observe(self.loadTopRowsInitialId.observer)
    self.vm.outputs.notifyDelegateOfSelectedRow.observe(self.notifyDelegateOfSelectedRow.observer)
  }

  func testAnimateIn_Default() {
    self.vm.configureWith(selectedRow: staffPicksRow, categories: categories)

    self.animateInView.assertValueCount(0)

    self.vm.inputs.viewDidLoad()

    self.animateInView.assertValues([nil])
  }

  func testAnimateIn_Category() {
    self.vm.configureWith(selectedRow: artSelectableRow, categories: categories)

    self.animateInView.assertValueCount(0)

    self.vm.inputs.viewDidLoad()

    self.animateInView.assertValues([1])
  }

  func testAnimateIn_Subcategory() {
    self.vm.configureWith(selectedRow: documentarySelectableRow, categories: categories)

    self.animateInView.assertValueCount(0)

    self.vm.inputs.viewDidLoad()

    self.animateInView.assertValues([11])
  }

  func testKoalaEventsTrack() {
    self.vm.configureWith(selectedRow: staffPicksRow, categories: categories)
    self.vm.inputs.viewDidLoad()

    XCTAssertEqual(["Viewed Discovery Filters", "Discover Switch Modal"], self.trackingClient.events)

    self.vm.inputs.tapped(expandableRow: filmExpandableRow)

    XCTAssertEqual(["Viewed Discovery Filters", "Discover Switch Modal", "Expanded Discovery Filter"],
                   self.trackingClient.events)

    self.vm.inputs.tapped(selectableRow: documentarySelectableRow)

    XCTAssertEqual(["Viewed Discovery Filters", "Discover Switch Modal", "Expanded Discovery Filter",
      "Selected Discovery Filter", "Discover Modal Selected Filter"], self.trackingClient.events)

    XCTAssertEqual([nil, nil, Category.filmAndVideo.id, Category.documentary.id, Category.documentary.id],
                   self.trackingClient.properties(forKey: "discover_category_id", as: Int.self))
  }

  func testTopFilters_Logged_Out() {
    self.vm.inputs.configureWith(selectedRow: staffPicksRow, categories: categories)

    self.loadTopRows.assertValueCount(0)

    self.vm.inputs.viewDidLoad()

    self.loadTopRows.assertValues(
      [[staffPicksRow |> SelectableRow.lens.isSelected .~ true, everythingRow]],
      "The top filter rows load immediately with the first one selected."
    )

    self.loadTopRowsInitialId.assertValues([nil])
  }

  func testTopFilters_Logged_In() {
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: .template))

    self.vm.inputs.configureWith(selectedRow: staffPicksRow, categories: categories)
    self.vm.inputs.viewDidLoad()
    self.loadTopRows.assertValues(
      [[staffPicksRow |> SelectableRow.lens.isSelected .~ true, starredRow, recommendedRow, everythingRow]],
      "The top filter rows load immediately with the first one selected."
    )
    self.loadTopRowsInitialId.assertValues([nil])
  }

  func testTopFilters_Logged_In_Social() {
    AppEnvironment.login(
      AccessTokenEnvelope(accessToken: "deadbeef", user: .template |> User.lens.social .~ true)
    )

    self.vm.inputs.configureWith(selectedRow: staffPicksRow, categories: categories)
    self.vm.inputs.viewDidLoad()
    self.loadTopRows.assertValues(
      [
        [ staffPicksRow |> SelectableRow.lens.isSelected .~ true,
          starredRow,
          recommendedRow,
          socialRow,
          everythingRow
        ]
      ],
      "The top filter rows load immediately with the first one selected."
    )
    self.loadTopRowsInitialId.assertValues([nil])
  }

  func testTopFilters_Category_Selected() {
    self.vm.inputs.configureWith(selectedRow: artSelectableRow, categories: categories)
    self.vm.inputs.viewDidLoad()

    self.loadTopRows.assertValues([[staffPicksRow, everythingRow]])
    self.loadTopRowsInitialId.assertValues([1])
  }

  func testExpandingCategoryFilters() {
    self.vm.inputs.configureWith(selectedRow: staffPicksRow, categories: categories)

    self.loadCategoryRows.assertValueCount(0)

    self.vm.inputs.viewDidLoad()

    self.loadCategoryRows.assertValues([[artExpandableRow, filmExpandableRow]],
                                      "The root categories emit.")
    self.loadCategoryRowsInitialId.assertValues([nil])
    self.loadCategoryRowsSelectedId.assertValues([nil])

    // Expand art
    self.vm.inputs.tapped(expandableRow: artExpandableRow)

    self.loadCategoryRows.assertValues(
      [
        [artExpandableRow, filmExpandableRow],
        [artExpandableRow |> ExpandableRow.lens.isExpanded .~ true, filmExpandableRow]
      ],
      "The art category expands."
    )
    self.loadCategoryRowsInitialId.assertValues([nil, nil])
    self.loadCategoryRowsSelectedId.assertValues([nil, 1])

    // Expand film
    self.vm.inputs.tapped(expandableRow: filmExpandableRow)

    self.loadCategoryRows.assertValues(
      [
        [artExpandableRow, filmExpandableRow],
        [artExpandableRow |> ExpandableRow.lens.isExpanded .~ true, filmExpandableRow],
        [artExpandableRow, filmExpandableRow |> ExpandableRow.lens.isExpanded .~ true]
      ],
      "The art category collapses and the film category expands."
    )
    self.loadCategoryRowsInitialId.assertValues([nil, nil, nil])
    self.loadCategoryRowsSelectedId.assertValues([nil, 1, 11])

    // Collapse the expanded film row
    self.vm.inputs.tapped(expandableRow: filmExpandableRow |> ExpandableRow.lens.isExpanded .~ true)

    self.loadCategoryRows.assertValues(
      [
        [artExpandableRow, filmExpandableRow],
        [artExpandableRow |> ExpandableRow.lens.isExpanded .~ true, filmExpandableRow],
        [artExpandableRow, filmExpandableRow |> ExpandableRow.lens.isExpanded .~ true],
        [artExpandableRow, filmExpandableRow]
      ],
      "The film category collapses."
    )
    self.loadCategoryRowsInitialId.assertValues([nil, nil, nil, nil])
    self.loadCategoryRowsSelectedId.assertValues([nil, 1, 11, 11])
  }

  func testConfigureWithSelectedRow() {
    let artSelectedExpandedRow = artExpandableRow
      |> ExpandableRow.lens.isExpanded .~ true
      |> ExpandableRow.lens.selectableRows .~ [
        artSelectableRow |> SelectableRow.lens.isSelected .~ true,
        selectableRowTemplate
          |> SelectableRow.lens.isSelected .~ false
          |> SelectableRow.lens.params.category .~ .illustration
    ]

    self.vm.inputs.configureWith(selectedRow: artSelectableRow, categories: categories)

    self.loadCategoryRows.assertValueCount(0)

    self.vm.inputs.viewDidLoad()

    self.loadCategoryRows.assertValues(
      [
        [artSelectedExpandedRow, filmExpandableRow]
      ],
      "The art category expands."
    )
    self.loadCategoryRowsInitialId.assertValues([1])
    self.loadCategoryRowsSelectedId.assertValues([1])
  }

  func testTappingSelectableRow() {
    self.vm.inputs.configureWith(selectedRow: staffPicksRow, categories: categories)
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.tapped(selectableRow: staffPicksRow)

    self.notifyDelegateOfSelectedRow.assertValues([staffPicksRow],
                                                  "The tapped row emits.")
  }

  /**
   This tests an implementation detail of our API. The API returns counts only for the root categories
   when they are not embedded as the `parent` of another category. This means if we naively group the
   categories by the parent, we might accidentally get a mapping of root -> children where root does not
   have the projects count. We get around this by sorting the categories first.

   We can test this by making the categories load in an order that causes the bug.
   */
  func testGroupingAndCounts() {
    let illustrationWithParentHavingNoCount = .illustration
      |> Category.lens.parent .~ (.art |> Category.lens.projectsCount .~ nil)

    let particularOrderOfCategories = [
      .documentary,
      .filmAndVideo,
      .art,
      illustrationWithParentHavingNoCount // <-- important for the subcategory to go after the root category
    ]

    self.vm.inputs.configureWith(selectedRow: staffPicksRow, categories: particularOrderOfCategories)
    self.vm.inputs.viewDidLoad()

    let counts = self.loadCategoryRows.values
      .flatten()
      .map { $0.params.category?.projectsCount }

    XCTAssertEqual([Category.art.projectsCount, Category.filmAndVideo.projectsCount],
                   counts,
                   "Root counts are preserved in expandable rows.")
  }
}
