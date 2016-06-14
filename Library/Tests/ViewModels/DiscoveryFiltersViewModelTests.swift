@testable import ReactiveExtensions_TestHelpers
@testable import KsApi
@testable import KsApi_TestHelpers
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

  private let loadCategoryRows = TestObserver<[ExpandableRow], NoError>()
  private let loadTopRows = TestObserver<[SelectableRow], NoError>()
  private let notifyDelegateOfSelectedRow = TestObserver<SelectableRow, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.loadCategoryRows.observe(self.loadCategoryRows.observer)
    self.vm.outputs.loadTopRows.observe(self.loadTopRows.observer)
    self.vm.outputs.notifyDelegateOfSelectedRow.observe(self.notifyDelegateOfSelectedRow.observer)

    AppEnvironment.replaceCurrentEnvironment(
      apiService: MockService(
        fetchCategoriesResponse: .template |> CategoriesEnvelope.lens.categories .~ [
          .illustration,
          .documentary,
          .filmAndVideo,
          .art
        ]
      )
    )
  }

  func testKoalaEventsTrack() {
    self.vm.configureWith(selectedRow: staffPicksRow)
    self.vm.inputs.viewDidLoad()

    XCTAssertEqual(["Discover Switch Modal"], self.trackingClient.events)

    self.vm.inputs.tapped(expandableRow: filmExpandableRow)

    XCTAssertEqual(["Discover Switch Modal"], self.trackingClient.events)

    self.vm.inputs.tapped(selectableRow: documentarySelectableRow)

    XCTAssertEqual(["Discover Switch Modal", "Discover Modal Selected Filter"],
                   self.trackingClient.events)

    XCTAssertEqual(["Discover Switch Modal", "Discover Modal Selected Filter"],
                   self.trackingClient.events)
    XCTAssertEqual([nil, Category.documentary.id],
                   self.trackingClient.properties(forKey: "discover_category_id", as: Int.self))
  }

  func testTopFilters() {
    self.vm.inputs.configureWith(selectedRow: staffPicksRow)
    self.vm.inputs.viewDidLoad()
    self.loadTopRows.assertValues(
      [[staffPicksRow |> SelectableRow.lens.isSelected .~ true, starredRow, socialRow, everythingRow]],
      "The top filter rows load immediately with the first one selected."
    )
  }

  func testExpandingCategoryFilters() {
    self.vm.inputs.configureWith(selectedRow: staffPicksRow)
    self.vm.inputs.viewDidLoad()

    self.loadCategoryRows.assertValues([[artExpandableRow, filmExpandableRow]],
                                      "The root categories emit.")

    // Expand art
    self.vm.inputs.tapped(expandableRow: artExpandableRow)

    self.loadCategoryRows.assertValues(
      [
        [artExpandableRow, filmExpandableRow],
        [artExpandableRow |> ExpandableRow.lens.isExpanded .~ true, filmExpandableRow]
      ],
      "The art category expands."
    )

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
  }

  func testConfigureWithSelectedRow() {
    self.vm.inputs.configureWith(selectedRow: artSelectableRow)
    self.vm.inputs.viewDidLoad()

    self.loadCategoryRows.assertValues(
      [
        [artExpandableRow |> ExpandableRow.lens.isExpanded .~ true, filmExpandableRow]
      ],
      "The art category expands."
    )
  }

  func testTappingSelectableRow() {
    self.vm.inputs.configureWith(selectedRow: staffPicksRow)
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

    let particularOrderOfCategories = .template |> CategoriesEnvelope.lens.categories .~ [
      .documentary,
      .filmAndVideo,
      .art,
      illustrationWithParentHavingNoCount // <-- important for the subcategory to go after the root category
    ]

    withEnvironment(apiService: MockService(fetchCategoriesResponse: particularOrderOfCategories)) {
      self.vm.inputs.configureWith(selectedRow: staffPicksRow)
      self.vm.inputs.viewDidLoad()

      let counts = self.loadCategoryRows.values
        .flatten()
        .map { $0.params.category?.projectsCount }

      XCTAssertEqual([Category.art.projectsCount, Category.filmAndVideo.projectsCount],
                     counts,
                     "Root counts are preserved in expandable rows.")
    }
  }
}
