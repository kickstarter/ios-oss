@testable import ReactiveExtensions_TestHelpers
@testable import KsApi
@testable import Library
@testable import Prelude
import ReactiveSwift
import Result
import XCTest

// A whole bunch of data to play around with in tests.
private let selectableRowTemplate = SelectableRow(isSelected: false,
                                                  params: .defaults)
private let expandableRowTemplate = ExpandableRow(isExpanded: false,
                                                  params: .defaults,
                                                  selectableRows: [])

private let allProjectsRow = selectableRowTemplate |> SelectableRow.lens.params.includePOTD .~ true
private let liveStreamRow = selectableRowTemplate |> SelectableRow.lens.params.hasLiveStreams .~ true
private let staffPicksRow = selectableRowTemplate |> SelectableRow.lens.params.staffPicks .~ true
private let starredRow = selectableRowTemplate |> SelectableRow.lens.params.starred .~ true
private let socialRow = selectableRowTemplate |> SelectableRow.lens.params.social .~ true
private let recommendedRow = selectableRowTemplate
  |> SelectableRow.lens.params.recommended .~ true
  |> SelectableRow.lens.params.backed .~ false

private let artSelectableRow = selectableRowTemplate
  |> SelectableRow.lens.params.category .~ .art

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

private let categories =
  [ RootCategoriesEnvelope.Category.art, RootCategoriesEnvelope.Category.illustration,
    RootCategoriesEnvelope.Category.filmAndVideo, RootCategoriesEnvelope.Category.documentary ]

internal final class DiscoveryFiltersViewModelTests: TestCase {
  private let vm: DiscoveryFiltersViewModelType = DiscoveryFiltersViewModel()

  private let animateInView = TestObserver<(), NoError>()
  private let loadCategoryRows = TestObserver<[ExpandableRow], NoError>()
  private let loadCategoryRowsInitialId = TestObserver<Int?, NoError>()
  private let loadCategoryRowsSelectedId = TestObserver<Int?, NoError>()
  private let loadingIndicatorisVisible = TestObserver<Bool, NoError>()
  private let loadTopRows = TestObserver<[SelectableRow], NoError>()
  private let loadTopRowsInitialId = TestObserver<Int?, NoError>()
  private let notifyDelegateOfSelectedRow = TestObserver<SelectableRow, NoError>()
  private let loadFavoriteRows = TestObserver<[SelectableRow], NoError>()
  private let loadFavoriteRowsId = TestObserver<Int?, NoError>()

  private let categoriesResponse = RootCategoriesEnvelope.template
    |> RootCategoriesEnvelope.lens.categories .~ categories

  override func setUp() {
    super.setUp()

    self.vm.outputs.animateInView.observe(self.animateInView.observer)
    self.vm.outputs.loadingIndicatorIsVisible.observe(self.loadingIndicatorisVisible.observer)
    self.vm.outputs.loadCategoryRows.map(first).observe(self.loadCategoryRows.observer)
    self.vm.outputs.loadCategoryRows.map(second).observe(self.loadCategoryRowsInitialId.observer)
    self.vm.outputs.loadCategoryRows.map { $0.2 }.observe(self.loadCategoryRowsSelectedId.observer)
    self.vm.outputs.loadTopRows.map(first).observe(self.loadTopRows.observer)
    self.vm.outputs.loadTopRows.map(second).observe(self.loadTopRowsInitialId.observer)
    self.vm.outputs.notifyDelegateOfSelectedRow.observe(self.notifyDelegateOfSelectedRow.observer)
    self.vm.outputs.loadFavoriteRows.map(first).observe(self.loadFavoriteRows.observer)
    self.vm.outputs.loadFavoriteRows.map(second).observe(self.loadFavoriteRowsId.observer)
  }

  func testAnimateIn() {
    self.vm.inputs.configureWith(selectedRow: allProjectsRow)
    self.vm.inputs.viewDidLoad()

    self.scheduler.advance(by: AppEnvironment.current.apiDelayInterval)

    self.animateInView.assertValueCount(0)

    self.vm.inputs.viewDidAppear()

    self.animateInView.assertValueCount(1)
  }

  func testKoalaEventsTrack() {
    self.vm.inputs.configureWith(selectedRow: allProjectsRow)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewDidAppear()

    self.scheduler.advance(by: AppEnvironment.current.apiDelayInterval)

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
    self.vm.inputs.configureWith(selectedRow: allProjectsRow)

    self.loadTopRows.assertValueCount(0)

    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewDidAppear()

    self.scheduler.advance(by: AppEnvironment.current.apiDelayInterval)

    self.loadTopRows.assertValues(
      [
        [
          allProjectsRow
            |> SelectableRow.lens.isSelected .~ true,
          staffPicksRow,
          liveStreamRow,
          ]
      ],
      "The top filter rows load immediately with the first one selected."
    )

    self.loadTopRowsInitialId.assertValues([nil])
  }

  func testTopFilters_LiveStreamFeatureFlagEnabled() {
    let config = .template
      |> Config.lens.features .~ ["ios_live_stream_discovery": true]

    withEnvironment(config: config) {
      self.vm.inputs.configureWith(selectedRow: allProjectsRow)
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.viewDidAppear()

      self.scheduler.advance()

      self.loadTopRows.assertValues(
        [
          [
            allProjectsRow
              |> SelectableRow.lens.isSelected .~ true,
            staffPicksRow,
            liveStreamRow,
            ]
        ],
        "The top filter rows load immediately with the first one selected."
      )
    }
  }

  func testTopFilters_LiveStreamFeatureFlagDisabled() {
    let config = .template
      |> Config.lens.features .~ ["ios_live_stream_discovery": false]

    withEnvironment(config: config) {
      self.vm.inputs.configureWith(selectedRow: allProjectsRow)
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.viewDidAppear()

      self.scheduler.advance()

      self.loadTopRows.assertValues(
        [
          [
            allProjectsRow
              |> SelectableRow.lens.isSelected .~ true,
            staffPicksRow,
          ]
        ],
        "The top filter rows load immediately with the first one selected."
      )
    }
  }

  func testTopFilters_LiveStreamFeatureFlagAbsent() {
    let config = .template
      |> Config.lens.features .~ [:]

    withEnvironment(config: config) {
      self.vm.inputs.configureWith(selectedRow: allProjectsRow)
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.viewDidAppear()

      self.scheduler.advance()

      self.loadTopRows.assertValues(
        [
          [
            allProjectsRow
              |> SelectableRow.lens.isSelected .~ true,
            staffPicksRow,
            liveStreamRow,
          ]
        ],
        "The top filter rows load immediately with the first one selected."
      )
    }
  }

  func testTopFilters_Logged_In() {
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: .template))

    self.vm.inputs.configureWith(selectedRow: allProjectsRow)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewDidAppear()

    self.scheduler.advance(by: AppEnvironment.current.apiDelayInterval)

    self.loadTopRows.assertValues(
      [
        [
          allProjectsRow
            |> SelectableRow.lens.isSelected .~ true,
          staffPicksRow,
          liveStreamRow,
          starredRow,
          recommendedRow,
          socialRow
        ]
      ],
      "The top filter rows load immediately with the first one selected."
    )
    self.loadTopRowsInitialId.assertValues([nil])
  }

  func testTopFilters_Logged_In_Social() {
    AppEnvironment.login(
      AccessTokenEnvelope(accessToken: "deadbeef", user: .template |> User.lens.social .~ true)
    )

    self.vm.inputs.configureWith(selectedRow: allProjectsRow)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewDidAppear()

    self.scheduler.advance(by: AppEnvironment.current.apiDelayInterval)

    self.loadTopRows.assertValues(
      [
        [
          allProjectsRow
            |> SelectableRow.lens.isSelected .~ true,
          staffPicksRow,
          liveStreamRow,
          starredRow,
          recommendedRow,
          socialRow,
        ]
      ],
      "The top filter rows load immediately with the first one selected."
    )
    self.loadTopRowsInitialId.assertValues([nil])
  }

  func testTopFilters_Category_Selected() {
    self.vm.inputs.configureWith(selectedRow: artSelectableRow)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewDidAppear()

    self.scheduler.advance(by: AppEnvironment.current.apiDelayInterval)

    self.loadTopRows.assertValues(
      [
        [
          allProjectsRow,
          staffPicksRow,
          liveStreamRow
        ]
      ]
    )
    self.loadTopRowsInitialId.assertValues([1])
  }

  func testExpandingCategoryFilters() {

    withEnvironment(apiService: MockService(fetchGraphCategoriesResponse: categoriesResponse)) {
      self.vm.inputs.configureWith(selectedRow: allProjectsRow)

      self.loadCategoryRows.assertValueCount(0)
      self.loadingIndicatorisVisible.assertValueCount(0)

      self.vm.inputs.viewDidLoad()
      self.vm.inputs.viewDidAppear()

      self.loadingIndicatorisVisible.assertValues([true])

      self.scheduler.advance(by: AppEnvironment.current.apiDelayInterval)

      self.loadingIndicatorisVisible.assertValues([true, false])

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

    self.vm.inputs.configureWith(selectedRow: artSelectableRow)

    self.loadCategoryRows.assertValueCount(0)

    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewDidAppear()

    self.loadingIndicatorisVisible.assertValues([true])

    self.scheduler.advance(by: AppEnvironment.current.apiDelayInterval)

    self.loadingIndicatorisVisible.assertValues([true, false])

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
    self.vm.inputs.configureWith(selectedRow: allProjectsRow)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewDidAppear()

    self.scheduler.advance(by: AppEnvironment.current.apiDelayInterval)

    self.vm.inputs.tapped(selectableRow: allProjectsRow)

    self.notifyDelegateOfSelectedRow.assertValues([allProjectsRow],
                                                  "The tapped row emits.")
  }

  /**
   This tests an implementation detail of our API. The API returns counts only for the root categories
   when they are not embedded as the `parent` of another category. This means if we naively group the
   categories by the parent, we might accidentally get a mapping of root -> children where root does not
   have the projects count. We get around this by sorting the categories first.

   We can test this by making the categories load in an order that causes the bug.
   */
//  func testGroupingAndCounts() {
//    let illustrationWithParentHavingNoCount = .illustration
//      |> RootCategoriesEnvelope.Category.lens.totalProjectCount .~ nil
//
//    let particularOrderOfCategories = [
//      RootCategoriesEnvelope.Category.documentary,
//      RootCategoriesEnvelope.Category.filmAndVideo,
//      RootCategoriesEnvelope.Category.art,
//      illustrationWithParentHavingNoCount // <-- important for the subcategory to go after the root category
//    ]
//
//    let specialCategoriesResponse = .template
//      |> RootCategoriesEnvelope.lens.categories .~ particularOrderOfCategories
//
//    withEnvironment(apiService: MockService(fetchCategoriesResponse: specialCategoriesResponse)) {
//      self.vm.inputs.configureWith(selectedRow: allProjectsRow)
//      self.vm.inputs.viewDidLoad()
//      self.vm.inputs.viewDidAppear()
//
//      self.scheduler.advance(by: AppEnvironment.current.apiDelayInterval)
//
//      let counts = self.loadCategoryRows.values
//        .joined()
//        .map { $0.params.category?.totalProjectCount }
//
//      XCTAssertEqual([RootCategoriesEnvelope.Category.art.totalProjectCount,
//                      RootCategoriesEnvelope.Category.filmAndVideo.totalProjectCount], counts,
//                     "Root counts are preserved in expandable rows.")
//    }
//  }

  func testFavoriteRows_Without_Favorites() {
    self.vm.inputs.configureWith(selectedRow: allProjectsRow)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewDidAppear()

    self.scheduler.advance(by: AppEnvironment.current.apiDelayInterval)

    self.loadFavoriteRows.assertValueCount(0, "Favorite rows does not emit without favorites set.")
  }

  func testFavoriteRows_With_Favorites() {
    withEnvironment(apiService: MockService(fetchGraphCategoriesResponse: categoriesResponse)) {
      self.ubiquitousStore.favoriteCategoryIds = [1, 30]

      self.vm.inputs.configureWith(selectedRow: allProjectsRow)

      self.loadFavoriteRows.assertValueCount(0)

      self.vm.inputs.viewDidLoad()
      self.vm.inputs.viewDidAppear()

      self.scheduler.advance(by: AppEnvironment.current.apiDelayInterval)

      self.loadFavoriteRows.assertValues([[artSelectableRow, documentarySelectableRow]])
      self.loadFavoriteRowsId.assertValues([nil])
    }
  }

  func testFavoriteRows_With_Favorites_Selected() {
    self.ubiquitousStore.favoriteCategoryIds = [1, 30]

    self.vm.inputs.configureWith(selectedRow: artSelectableRow)

    self.loadFavoriteRows.assertValueCount(0)

    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewDidAppear()

    self.scheduler.advance(by: AppEnvironment.current.apiDelayInterval)

    self.loadFavoriteRows.assertValues([[
      artSelectableRow |> SelectableRow.lens.isSelected .~ true,
      documentarySelectableRow
    ]])
    self.loadFavoriteRowsId.assertValues([1])
  }

  func testCategoriesFromCache() {
    self.cache[KSCache.ksr_discoveryFiltersCategories] = categories

    self.vm.inputs.configureWith(selectedRow: allProjectsRow)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewDidAppear()

    self.loadingIndicatorisVisible.assertValueCount(0)

    self.loadCategoryRows.assertValues([[artExpandableRow, filmExpandableRow]],
                                       "Server did not advance, categories loaded from cache.")
  }
}
