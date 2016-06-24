import KsApi
import Prelude
import ReactiveCocoa
import Result

public protocol DiscoveryFiltersViewModelInputs {
  /// Call with the (optional) row that is selected when the filters appear.
  func configureWith(selectedRow selectedRow: SelectableRow)

  /// Call when an expandable row is tapped.
  func tapped(expandableRow expandableRow: ExpandableRow)

  /// Call when a selectable row is tapped.
  func tapped(selectableRow selectableRow: SelectableRow)

  /// Call when the view loads.
  func viewDidLoad()
}

public protocol DiscoveryFiltersViewModelOutputs {
  /// Emits an array of expandable rows to put into the categories section of filters.
  var loadCategoryRows: Signal<[ExpandableRow], NoError> { get }

  /// Emits an array of selectable rows to put into the top filters section.
  var loadTopRows: Signal<[SelectableRow], NoError> { get }

  /// Emits a selectable row when the delegate should be notified of the selection.
  var notifyDelegateOfSelectedRow: Signal<SelectableRow, NoError> { get }
}

public protocol DiscoveryFiltersViewModelType {
  var inputs: DiscoveryFiltersViewModelInputs { get }
  var outputs: DiscoveryFiltersViewModelOutputs { get }
}

public final class DiscoveryFiltersViewModel: DiscoveryFiltersViewModelType,
  DiscoveryFiltersViewModelInputs, DiscoveryFiltersViewModelOutputs {

  public init() {
    let categories = self.viewDidLoadProperty.signal
      .switchMap { AppEnvironment.current.apiService.fetchCategories().demoteErrors() }

    let initialTopFilters = self.viewDidLoadProperty.signal
      .take(1)
      .map { topFilters(forUser: AppEnvironment.current.currentUser) }
      .uncollect()

    self.loadTopRows = combineLatest(
      initialTopFilters,
      self.initialSelectedRowProperty.signal.take(1)
      )
      .map { params, selectedRow in
        SelectableRow(
          isSelected: (selectedRow?.params).map { $0 == params } == true,
          params: params
        )
      }
      .collect()

    let initialRows = combineLatest(
      self.initialSelectedRowProperty.signal,
      categories.map { $0.categories }.map(expandableRows(fromCategories:))
      )
      .map(expand(parentOf:in:))

    let expandingRows = combineLatest(
      self.tappedExpandableRowProperty.signal.ignoreNil(),
      initialRows
      )
      .map(toggleExpansion(row:in:))

    self.loadCategoryRows = Signal.merge(initialRows, expandingRows)

    self.notifyDelegateOfSelectedRow = self.tappedSelectableRowProperty.signal.ignoreNil()

    self.viewDidLoadProperty.signal
      .observeNext { AppEnvironment.current.koala.trackDiscoveryModal() }

    self.notifyDelegateOfSelectedRow
      .observeNext { AppEnvironment.current.koala.trackDiscoveryModalSelectedFilter(params: $0.params) }
  }

  private let initialSelectedRowProperty = MutableProperty<SelectableRow?>(nil)
  public func configureWith(selectedRow selectedRow: SelectableRow) {
    self.initialSelectedRowProperty.value = selectedRow
  }
  private let tappedExpandableRowProperty = MutableProperty<ExpandableRow?>(nil)
  public func tapped(expandableRow expandableRow: ExpandableRow) {
    self.tappedExpandableRowProperty.value = expandableRow
  }
  private let tappedSelectableRowProperty = MutableProperty<SelectableRow?>(nil)
  public func tapped(selectableRow selectableRow: SelectableRow) {
    self.tappedSelectableRowProperty.value = selectableRow
  }
  private let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let loadCategoryRows: Signal<[ExpandableRow], NoError>
  public let loadTopRows: Signal<[SelectableRow], NoError>
  public let notifyDelegateOfSelectedRow: Signal<SelectableRow, NoError>

  public var inputs: DiscoveryFiltersViewModelInputs { return self }
  public var outputs: DiscoveryFiltersViewModelOutputs { return self }
}

/**
 Finds the expandable row that contains the given seletable row, and expands it.

 - parameter selectedRow:    An optional selected row to search for.
 - parameter expandableRows: All expandable rows to search through.

 - returns: A new array of expandable rows with one row expanded. If no selected row is provided, then the
            `expandableRows` value is returned unchanged.
 */
private func expand(parentOf selectedRow: SelectableRow?,
                    in expandableRows: [ExpandableRow]) -> [ExpandableRow] {
  guard let selectedRow = selectedRow else { return expandableRows }

  return expandableRows.map { expandableRow in
    expandableRow
      |> ExpandableRow.lens.isExpanded .~
        expandableRow.selectableRows.map { $0.params }.contains(selectedRow.params)
  }
}

/**
 Toggles the expansion of the row provided.

 - parameter rowToToggle:    The row to toggle expansion.
 - parameter expandableRows: A full array of expandable rows.

 - returns: A new array of expandable rows with the provided row's expansion toggled.
 */
private func toggleExpansion(row rowToToggle: ExpandableRow,
                             in expandableRows: [ExpandableRow]) -> [ExpandableRow] {
  return expandableRows.map { expandableRow in
    expandableRow
      |> ExpandableRow.lens.isExpanded .~ (expandableRow == rowToToggle && !rowToToggle.isExpanded)
  }
}

/**
 Converts an array of categories into a grouped array of expandable rows.

 - parameter categories: A full array of categories.

 - returns: An array of expandable rows.
 */
private func expandableRows(fromCategories categories: [KsApi.Category]) -> [ExpandableRow] {

  return categories
    .sort { lhs, _ in !lhs.isRoot }
    .groupedBy { $0.parent ?? $0 }
    .map { rootCategory, rootWithChildren in
      ExpandableRow(
        isExpanded: false,
        params: .defaults |> DiscoveryParams.lens.category .~ rootCategory,
        selectableRows: rootWithChildren
          .sort()
          .map { childCategory in
            SelectableRow(
              isSelected: false,
              params: .defaults |> DiscoveryParams.lens.category .~ childCategory
            )
        }
      )
    }
    .sort { lhs, rhs in lhs.params.category < rhs.params.category }
}

private func topFilters(forUser user: User?) -> [DiscoveryParams] {
  var filters: [DiscoveryParams] = []

  filters.append(.defaults
    |> DiscoveryParams.lens.staffPicks .~ true
    |> DiscoveryParams.lens.includePOTD .~ true)

  if user != nil {
    filters.append(.defaults |> DiscoveryParams.lens.recommended .~ true)
    filters.append(.defaults |> DiscoveryParams.lens.starred .~ true)
  }

  if user?.social == true {
    filters.append(.defaults |> DiscoveryParams.lens.social .~ true)
  }

  filters.append(.defaults)

  return filters
}
