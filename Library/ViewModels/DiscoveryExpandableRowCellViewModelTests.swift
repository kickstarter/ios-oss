import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result
import XCTest
@testable import KsApi
@testable import ReactiveExtensions_TestHelpers
@testable import Library

final class DiscoveryExpandableRowCellViewModelTests: TestCase {
  fileprivate let vm: DiscoveryExpandableRowCellViewModelType = DiscoveryExpandableRowCellViewModel()

  fileprivate let cellAccessibilityHint = TestObserver<String, NoError>()
  fileprivate let cellAccessibilityLabel = TestObserver<String, NoError>()
  fileprivate let expandCategoryStyleExpandableRow = TestObserver<ExpandableRow, NoError>()
  fileprivate let expandCategoryStyleCategoryId = TestObserver<Int?, NoError>()
  fileprivate let filterIsExpanded = TestObserver<Bool, NoError>()
  fileprivate let filterTitleLabelText = TestObserver<String, NoError>()
  fileprivate let projectsCountLabelAlpha = TestObserver<CGFloat, NoError>()
  fileprivate let projectsCountLabelHidden = TestObserver<Bool, NoError>()
  fileprivate let projectsCountLabelText = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.cellAccessibilityHint.observe(self.cellAccessibilityHint.observer)
    self.vm.outputs.cellAccessibilityLabel.observe(self.cellAccessibilityLabel.observer)
    self.vm.outputs.expandCategoryStyle.map(first).observe(self.expandCategoryStyleExpandableRow.observer)
    self.vm.outputs.expandCategoryStyle.map(second).observe(self.expandCategoryStyleCategoryId.observer)
    self.vm.outputs.filterIsExpanded.observe(self.filterIsExpanded.observer)
    self.vm.outputs.filterTitleLabelText.observe(self.filterTitleLabelText.observer)
    self.vm.outputs.projectsCountLabelAlpha.observe(self.projectsCountLabelAlpha.observer)
    self.vm.outputs.projectsCountLabelHidden.observe(self.projectsCountLabelHidden.observer)
    self.vm.outputs.projectsCountLabelText.observe(self.projectsCountLabelText.observer)
  }

  func testCellAccessibilityHint_WhenCollapsed() {
    let expandableRowNotExpanded =  ExpandableRow(
      isExpanded: false,
      params: .defaults |> DiscoveryParams.lens.category .~ .filmAndVideo,
      selectableRows: []
    )

    let categoryId = expandableRowNotExpanded.params.category?.intID

    self.vm.inputs.configureWith(row: expandableRowNotExpanded, categoryId: categoryId)
    self.vm.inputs.willDisplay()

    self.cellAccessibilityHint.assertValues([Strings.Expands_subcategories()])
  }

  func testCellAccessibilityHint_WhenExpanded() {
    let expandableRowExpanded = ExpandableRow(
      isExpanded: true,
      params: .defaults |> DiscoveryParams.lens.category .~ .filmAndVideo,
      selectableRows: []
      )
    let categoryId = expandableRowExpanded.params.category?.intID

    self.vm.inputs.configureWith(row: expandableRowExpanded, categoryId: categoryId)
    self.vm.inputs.willDisplay()

    self.cellAccessibilityHint.assertValues([Strings.Collapses_subcategories()])
  }

  func testCellAccessibilityLabel() {
    let expandableRow =  ExpandableRow(
      isExpanded: false,
      params: .defaults |> DiscoveryParams.lens.category .~ .filmAndVideo,
      selectableRows: []
      )
    let categoryId = expandableRow.params.category?.intID

    self.vm.inputs.configureWith(row: expandableRow, categoryId: categoryId)
    self.vm.inputs.willDisplay()

    self.cellAccessibilityLabel.assertValues([
      Strings.Filter_name_project_count_live_projects(
        filter_name: (expandableRow.params.category?.name ?? ""),
        project_count: (expandableRow.params.category?.totalProjectCount ?? 0)
      )])
  }

  func testExpandCategoryStyle() {
    let expandableRow =  ExpandableRow(
      isExpanded: false,
      params: .defaults |> DiscoveryParams.lens.category .~ .filmAndVideo,
      selectableRows: []
    )
    let categoryId = expandableRow.params.category?.intID

    self.vm.inputs.configureWith(row: expandableRow, categoryId: categoryId)
    self.vm.inputs.willDisplay()

    self.expandCategoryStyleExpandableRow.assertValues([expandableRow])
    self.expandCategoryStyleCategoryId.assertValues([categoryId])

  }

  func testFilterIsExpanded_Expanded() {
    let expandableRow =  ExpandableRow(
      isExpanded: true,
      params: .defaults |> DiscoveryParams.lens.category .~ .games,
      selectableRows: []
      )
    let categoryId = expandableRow.params.category?.intID

    self.vm.inputs.configureWith(row: expandableRow, categoryId: categoryId)
    self.vm.inputs.willDisplay()

    self.filterIsExpanded.assertValues([true])
  }

  func testFilterIsExpanded_NotExpanded() {
    let expandableRow =  ExpandableRow(
      isExpanded: false,
      params: .defaults |> DiscoveryParams.lens.category .~ .games,
      selectableRows: []
      )
    let categoryId = expandableRow.params.category?.intID

    self.vm.inputs.configureWith(row: expandableRow, categoryId: categoryId)
    self.vm.inputs.willDisplay()

    self.filterIsExpanded.assertValues([false])
  }

  func testFilterTitleLabelText() {
    let expandableRow =  ExpandableRow(
      isExpanded: false,
      params: .defaults |> DiscoveryParams.lens.category .~ .filmAndVideo,
      selectableRows: []
      )
    let categoryId = expandableRow.params.category?.intID

    self.vm.inputs.configureWith(row: expandableRow, categoryId: categoryId)
    self.vm.inputs.willDisplay()

    self.filterTitleLabelText.assertValues([expandableRow.params.category?.name ?? ""])
  }

  func testProjectsCountLabelAlpha() {
    let expandableRow =  ExpandableRow(
      isExpanded: false,
      params: .defaults |> DiscoveryParams.lens.category .~ .filmAndVideo,
      selectableRows: []
    )
    let categoryId = expandableRow.params.category?.intID

    self.vm.inputs.configureWith(row: expandableRow, categoryId: categoryId)
    self.vm.inputs.willDisplay()

    self.projectsCountLabelAlpha.assertValues([0.4])
  }

  func testProjectsCountLabelHidden() {
    let gamesCategory = .games |> RootCategoriesEnvelope.Category.lens.totalProjectCount .~ 10
    let expandableRow =  ExpandableRow(
      isExpanded: false,
      params: .defaults |> DiscoveryParams.lens.category .~ gamesCategory,
      selectableRows: []
    )
    let categoryId = expandableRow.params.category?.intID

    self.vm.inputs.configureWith(row: expandableRow, categoryId: categoryId)
    self.vm.inputs.willDisplay()

    self.projectsCountLabelHidden.assertValues([false])
  }

  func testProjectsCountLabelHidden_NoProjects() {
    let gamesCategory = .games |> RootCategoriesEnvelope.Category.lens.totalProjectCount .~ 0
    let expandableRow =  ExpandableRow(
      isExpanded: false,
      params: .defaults |> DiscoveryParams.lens.category .~ gamesCategory,
      selectableRows: []
    )
    let categoryId = expandableRow.params.category?.intID

    self.vm.inputs.configureWith(row: expandableRow, categoryId: categoryId)
    self.vm.inputs.willDisplay()

    self.projectsCountLabelHidden.assertValues([true])
  }

  func testProjectsCountLabelText() {
    let filmAndVideoCategory = .filmAndVideo |> RootCategoriesEnvelope.Category.lens.totalProjectCount .~ 10
    let expandableRow =  ExpandableRow(
      isExpanded: false,
      params: .defaults |> DiscoveryParams.lens.category .~ filmAndVideoCategory,
      selectableRows: []
    )
    let categoryId = expandableRow.params.category?.intID

    self.vm.inputs.configureWith(row: expandableRow, categoryId: categoryId)
    self.vm.inputs.willDisplay()

    self.projectsCountLabelText.assertValues([Format.wholeNumber(10)])
  }
}
