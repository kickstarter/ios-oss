import Prelude
import ReactiveCocoa
import Result
import XCTest
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions
@testable import ReactiveExtensions_TestHelpers

internal final class DiscoveryNavigationHeaderViewModelTests: TestCase {
  private let vm: DiscoveryNavigationHeaderViewModelType = DiscoveryNavigationHeaderViewModel()

  private let animateArrowToDown = TestObserver<Bool, NoError>()
  private let dividerIsHidden = TestObserver<Bool, NoError>()
  private let primaryLabelText = TestObserver<String, NoError>()
  private let notifyDelegateFilterSelectedParams = TestObserver<DiscoveryParams, NoError>()
  private let secondaryLabelText = TestObserver<String, NoError>()
  private let secondaryLabelIsHidden = TestObserver<Bool, NoError>()
  private let titleAccessibilityHint = TestObserver<String, NoError>()
  private let titleAccessibilityLabel = TestObserver<String, NoError>()
  private let showDiscoveryFiltersRow = TestObserver<SelectableRow, NoError>()
  private let showDiscoveryFiltersCats = TestObserver<[KsApi.Category], NoError>()

  let initialParams = .defaults
    |> DiscoveryParams.lens.staffPicks .~ true
    |> DiscoveryParams.lens.includePOTD .~ true

  let categoryParams = .defaults |> DiscoveryParams.lens.category .~ .art
  let subcategoryParams = .defaults |> DiscoveryParams.lens.category .~ .documentary
  let starredParams = .defaults |> DiscoveryParams.lens.starred .~ true

  let selectableRow = SelectableRow(isSelected: false, params: .defaults)

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.animateArrowToDown.observe(self.animateArrowToDown.observer)
    self.vm.outputs.dividerIsHidden.observe(self.dividerIsHidden.observer)
    self.vm.outputs.primaryLabelText.observe(self.primaryLabelText.observer)
    self.vm.outputs.notifyDelegateFilterSelectedParams
      .observe(self.notifyDelegateFilterSelectedParams.observer)
    self.vm.outputs.secondaryLabelText.observe(self.secondaryLabelText.observer)
    self.vm.outputs.secondaryLabelIsHidden.observe(self.secondaryLabelIsHidden.observer)
    self.vm.outputs.titleButtonAccessibilityHint.observe(self.titleAccessibilityHint.observer)
    self.vm.outputs.titleButtonAccessibilityLabel.observe(self.titleAccessibilityLabel.observer)
    self.vm.outputs.showDiscoveryFilters.map(first).observe(self.showDiscoveryFiltersRow.observer)
    self.vm.outputs.showDiscoveryFilters.map(second).observe(self.showDiscoveryFiltersCats.observer)
  }

  func testShowFilters() {
    let categories = [
      Category.illustration,
      .documentary,
      .filmAndVideo,
      .art
    ]

    let categoriesResponse = .template |> CategoriesEnvelope.lens.categories .~ categories
    let initialRow = SelectableRow(isSelected: true, params: initialParams)
    let starredRow = selectableRow |> SelectableRow.lens.params .~ starredParams
    let artRow = selectableRow |> SelectableRow.lens.params .~ categoryParams

    withEnvironment(apiService: MockService(fetchCategoriesResponse: categoriesResponse)) {

      self.vm.inputs.viewDidLoad()
      self.vm.inputs.configureWith(params: initialParams)

      self.showDiscoveryFiltersRow.assertValueCount(0)

      self.vm.inputs.titleButtonTapped()

      self.showDiscoveryFiltersRow.assertValues([initialRow])
      self.showDiscoveryFiltersCats.assertValues([categories])

      self.vm.inputs.filtersSelected(row: starredRow)

      self.showDiscoveryFiltersRow.assertValues([initialRow], "Show Filters does not emit on selection.")

      self.vm.inputs.titleButtonTapped()

      self.showDiscoveryFiltersRow.assertValues([initialRow, starredRow])
      self.showDiscoveryFiltersCats.assertValues([categories, categories])

      self.vm.inputs.titleButtonTapped()

      self.showDiscoveryFiltersRow.assertValues([initialRow, starredRow],
                                                "Show filters does not emit on close.")

      self.vm.inputs.titleButtonTapped()

      self.showDiscoveryFiltersRow.assertValues([initialRow, starredRow, starredRow])
      self.showDiscoveryFiltersCats.assertValues([categories, categories, categories])

      self.vm.inputs.filtersSelected(row: artRow)
      self.vm.inputs.titleButtonTapped()

      self.showDiscoveryFiltersRow.assertValues([initialRow, starredRow, starredRow, artRow])
      self.showDiscoveryFiltersCats.assertValues([categories, categories, categories, categories])
    }
  }

  func testTitleData() {
    self.vm.inputs.viewDidLoad()

    self.animateArrowToDown.assertValueCount(0)
    self.dividerIsHidden.assertValueCount(0)
    self.primaryLabelText.assertValueCount(0)
    self.secondaryLabelText.assertValueCount(0)
    self.secondaryLabelIsHidden.assertValueCount(0)
    self.titleAccessibilityHint.assertValueCount(0)
    self.titleAccessibilityLabel.assertValueCount(0)

    self.vm.inputs.configureWith(params: initialParams)

    self.animateArrowToDown.assertValues([true])
    self.dividerIsHidden.assertValues([true])
    self.primaryLabelText.assertValues([Strings.projects_we_love()])
    self.secondaryLabelText.assertValues([""])
    self.secondaryLabelIsHidden.assertValues([true])
    self.titleAccessibilityHint.assertValues([Strings.opens_filters()])
    self.titleAccessibilityLabel.assertValues([Strings.filtered_by_projects_we_love()])

    self.vm.inputs.titleButtonTapped()

    self.animateArrowToDown.assertValues([true, false])
    self.dividerIsHidden.assertValues([true])
    self.primaryLabelText.assertValues([Strings.projects_we_love(), Strings.projects_we_love()])
    self.secondaryLabelText.assertValues(["", ""])
    self.secondaryLabelIsHidden.assertValues([true])
    self.titleAccessibilityHint.assertValues([Strings.opens_filters(), Strings.closes_filters()])
    self.titleAccessibilityLabel.assertValues([Strings.filtered_by_projects_we_love(),
      Strings.filtered_by_projects_we_love()])

    self.vm.inputs.filtersSelected(row: selectableRow |> SelectableRow.lens.params .~ starredParams)

    self.animateArrowToDown.assertValues([true, false, true])
    self.dividerIsHidden.assertValues([true])
    self.primaryLabelText.assertValues([Strings.projects_we_love(), Strings.projects_we_love(),
      Strings.discovery_saved()])
    self.secondaryLabelText.assertValues(["", "", ""])
    self.secondaryLabelIsHidden.assertValues([true])
    self.titleAccessibilityHint.assertValues([Strings.opens_filters(), Strings.closes_filters(),
      Strings.opens_filters()])
    self.titleAccessibilityLabel.assertValues([Strings.filtered_by_projects_we_love(),
      Strings.filtered_by_projects_we_love(), Strings.filtered_by_starred_projects()])

    self.vm.inputs.titleButtonTapped()

    self.animateArrowToDown.assertValues([true, false, true, false])
    self.dividerIsHidden.assertValues([true])
    self.primaryLabelText.assertValues([Strings.projects_we_love(), Strings.projects_we_love(),
      Strings.discovery_saved(), Strings.discovery_saved()])
    self.secondaryLabelText.assertValues(["", "", "", ""])
    self.secondaryLabelIsHidden.assertValues([true])
    self.titleAccessibilityHint.assertValues([Strings.opens_filters(), Strings.closes_filters(),
      Strings.opens_filters(), Strings.closes_filters()])
    self.titleAccessibilityLabel.assertValues([Strings.filtered_by_projects_we_love(),
      Strings.filtered_by_projects_we_love(), Strings.filtered_by_starred_projects(),
      Strings.filtered_by_starred_projects()])

    self.vm.inputs.filtersSelected(row: selectableRow |> SelectableRow.lens.params .~ categoryParams)

    self.animateArrowToDown.assertValues([true, false, true, false, true])
    self.dividerIsHidden.assertValues([true])
    self.primaryLabelText.assertValues([Strings.projects_we_love(), Strings.projects_we_love(),
      Strings.discovery_saved(), Strings.discovery_saved(), Strings.all_art_projects()])
    self.secondaryLabelText.assertValues(["", "", "", "", ""])
    self.secondaryLabelIsHidden.assertValues([true])
    self.titleAccessibilityHint.assertValues([Strings.opens_filters(), Strings.closes_filters(),
      Strings.opens_filters(), Strings.closes_filters(), Strings.opens_filters()])
    self.titleAccessibilityLabel.assertValues([Strings.filtered_by_projects_we_love(),
      Strings.filtered_by_projects_we_love(), Strings.filtered_by_starred_projects(),
      Strings.filtered_by_starred_projects(),
      Strings.filtered_by_category_name(category_name: categoryParams.category?.name ?? "")])

    self.vm.inputs.titleButtonTapped()

    self.animateArrowToDown.assertValues([true, false, true, false, true, false])
    self.dividerIsHidden.assertValues([true])
    self.primaryLabelText.assertValues([Strings.projects_we_love(), Strings.projects_we_love(),
      Strings.discovery_saved(), Strings.discovery_saved(), Strings.all_art_projects(),
      Strings.all_art_projects()])
    self.secondaryLabelText.assertValues(["", "", "", "", "", ""])
    self.secondaryLabelIsHidden.assertValues([true])
    self.titleAccessibilityHint.assertValues([Strings.opens_filters(), Strings.closes_filters(),
      Strings.opens_filters(), Strings.closes_filters(), Strings.opens_filters(), Strings.closes_filters()])
    self.titleAccessibilityLabel.assertValues([Strings.filtered_by_projects_we_love(),
      Strings.filtered_by_projects_we_love(), Strings.filtered_by_starred_projects(),
      Strings.filtered_by_starred_projects(),
      Strings.filtered_by_category_name(category_name: categoryParams.category?.name ?? ""),
      Strings.filtered_by_category_name(category_name: categoryParams.category?.name ?? "")
    ])

    self.vm.inputs.filtersSelected(row: selectableRow |> SelectableRow.lens.params .~ subcategoryParams)

    self.animateArrowToDown.assertValues([true, false, true, false, true, false, true])
    self.dividerIsHidden.assertValues([true, false])
    self.primaryLabelText.assertValues([Strings.projects_we_love(), Strings.projects_we_love(),
      Strings.discovery_saved(), Strings.discovery_saved(), Strings.all_art_projects(),
      Strings.all_art_projects(), "Film & Video"])
    self.secondaryLabelText.assertValues(["", "", "", "", "", "", "Documentary"])
    self.secondaryLabelIsHidden.assertValues([true, false])
    self.titleAccessibilityHint.assertValues([Strings.opens_filters(), Strings.closes_filters(),
      Strings.opens_filters(), Strings.closes_filters(), Strings.opens_filters(), Strings.closes_filters(),
      Strings.opens_filters()])
    self.titleAccessibilityLabel.assertValues([Strings.filtered_by_projects_we_love(),
      Strings.filtered_by_projects_we_love(), Strings.filtered_by_starred_projects(),
      Strings.filtered_by_starred_projects(),
      Strings.filtered_by_category_name(category_name: categoryParams.category?.name ?? ""),
      Strings.filtered_by_category_name(category_name: categoryParams.category?.name ?? ""),
      Strings.filtered_by_subcategory_name_in_category_name(
        subcategory_name: subcategoryParams.category?.name ?? "",
        category_name: subcategoryParams.category?.root?.name ?? "")
      ])
  }

  func testNotifyFilterSelectdParams() {
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.configureWith(params: initialParams)

    self.notifyDelegateFilterSelectedParams.assertValueCount(0)

    self.vm.inputs.filtersSelected(row: selectableRow)

    self.notifyDelegateFilterSelectedParams.assertValues([DiscoveryParams.defaults])

    self.vm.inputs.filtersSelected(row: selectableRow |> SelectableRow.lens.params .~ categoryParams)

    self.notifyDelegateFilterSelectedParams.assertValues([DiscoveryParams.defaults, categoryParams])
  }
}
