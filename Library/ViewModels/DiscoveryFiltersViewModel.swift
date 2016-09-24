import KsApi
import Prelude
import ReactiveCocoa
import Result

public protocol DiscoveryFiltersViewModelInputs {
  /// Call with the row that is selected when the filters appear and array of loaded categories.
  func configureWith(selectedRow selectedRow: SelectableRow, categories: [KsApi.Category])

  /// Call when an expandable row is tapped.
  func tapped(expandableRow expandableRow: ExpandableRow)

  /// Call when a selectable row is tapped.
  func tapped(selectableRow selectableRow: SelectableRow)

  /// Call when the view loads.
  func viewDidLoad()

  /// Call when the view will appear.
  func viewWillAppear()
}

public protocol DiscoveryFiltersViewModelOutputs {
  /// Emits a category id to set the background gradient and animate in the view.
  var animateInView: Signal<Int?, NoError> { get }

  /**
   Emits an array of expandable rows to put into the categories section of filters,
   a category id to set row styles, and an optional category id for setting scrollTo position.
   **/
  var loadCategoryRows: Signal<(rows: [ExpandableRow], categoryId: Int?, selectedRowId: Int?),
    NoError> { get }

  /// Emits an array of selectable rows for the favorites section and category id to set row styles.
  var loadFavoriteRows: Signal<(rows: [SelectableRow], categoryId: Int?), NoError> { get }

  /// Emits an array of selectable rows to put into the top filters section and category id to set row styles.
  var loadTopRows: Signal<(rows: [SelectableRow], categoryId: Int?), NoError> { get }

  /// Emits a selectable row when the delegate should be notified of the selection.
  var notifyDelegateOfSelectedRow: Signal<SelectableRow, NoError> { get }

  /// A bool that determines whether a cell should be animated when it is displayed.
  var shouldAnimateSelectableCell: Bool { get }
}

public protocol DiscoveryFiltersViewModelType {
  var inputs: DiscoveryFiltersViewModelInputs { get }
  var outputs: DiscoveryFiltersViewModelOutputs { get }
}

public final class DiscoveryFiltersViewModel: DiscoveryFiltersViewModelType,
  DiscoveryFiltersViewModelInputs, DiscoveryFiltersViewModelOutputs {

  // swiftlint:disable function_body_length
  public init() {

    let initialTopFilters = self.viewDidLoadProperty.signal
      .take(1)
      .map { topFilters(forUser: AppEnvironment.current.currentUser) }

    let initialSelectedRowWithCategories = combineLatest(
      self.initialSelectedRowWithCategoriesProperty.signal.ignoreNil(),
      self.viewDidLoadProperty.signal
      )
      .take(1)
      .map(first)

    let topRows = combineLatest(
      initialTopFilters,
      initialSelectedRowWithCategories.map(first)
      )
      .map { params, selectedRow in
        params.map {
          SelectableRow(isSelected: $0 == selectedRow.params, params: $0)
        }
    }

    let categoryId = self.initialSelectedRowWithCategoriesProperty.signal.ignoreNil()
      .map(first)
      .map { $0.params.category?.rootId }

    self.loadTopRows = combineLatest(topRows, categoryId).map { (rows: $0, categoryId: $1) }

    let favoriteRows = initialSelectedRowWithCategories
      .map(favorites(selectedRow:categories:))
      .ignoreNil()

    self.loadFavoriteRows = combineLatest(favoriteRows, categoryId)
      .map { (rows: $0, categoryId: $1) }

    let selectedRowId = Signal.merge(
        categoryId,
        self.tappedExpandableRowProperty.signal.ignoreNil().map { $0.params.category?.rootId }
      )

    let initialRows = initialSelectedRowWithCategories
      .map(expandableRows(selectedRow:categories:))

    let expandingRows = combineLatest(
      self.tappedExpandableRowProperty.signal.ignoreNil(),
      initialRows
      )
      .map(toggleExpansion(row:in:))

    let initialCatRowsAndIdAndSelectedRowId = combineLatest(categoryId, selectedRowId)
      .takePairWhen(initialRows)

    let expandedCatRowsAndIdAndSelectedRowId = combineLatest(categoryId, selectedRowId)
      .takePairWhen(expandingRows)

    self.loadCategoryRows = Signal.merge(
      initialCatRowsAndIdAndSelectedRowId,
      expandedCatRowsAndIdAndSelectedRowId
      )
      .map { (rows: $1, categoryId: $0.0, selectedRowId: $0.1) }

    self.notifyDelegateOfSelectedRow = self.tappedSelectableRowProperty.signal.ignoreNil()

    self.shouldAnimateSelectableCellProperty <~ Signal.merge(
      self.tappedExpandableRowProperty.signal.mapConst(true),

      self.tappedExpandableRowProperty.signal
        .delay(0.3, onScheduler: AppEnvironment.current.scheduler)
        .mapConst(false)
    )

    self.animateInView = categoryId
      .takeWhen(self.viewWillAppearProperty.signal)

    self.viewDidLoadProperty.signal
      .observeNext { AppEnvironment.current.koala.trackDiscoveryModal() }

    self.notifyDelegateOfSelectedRow
      .observeNext { AppEnvironment.current.koala.trackDiscoveryModalSelectedFilter(params: $0.params) }

    self.tappedExpandableRowProperty.signal.ignoreNil()
      .observeNext { AppEnvironment.current.koala.trackDiscoveryModalExpandedFilter(params: $0.params) }
  }
  // swiftlint:enable function_body_length

  private let initialSelectedRowWithCategoriesProperty =
    MutableProperty<(SelectableRow, [KsApi.Category])?>(nil)
  public func configureWith(selectedRow selectedRow: SelectableRow, categories: [KsApi.Category]) {
    self.initialSelectedRowWithCategoriesProperty.value = (selectedRow, categories)
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
  private let viewWillAppearProperty = MutableProperty()
  public func viewWillAppear() {
    self.viewWillAppearProperty.value = ()
  }

  private let shouldAnimateSelectableCellProperty = MutableProperty(false)
  public var shouldAnimateSelectableCell: Bool {
    return self.shouldAnimateSelectableCellProperty.value
  }

  public let animateInView: Signal<Int?, NoError>
  public let loadCategoryRows: Signal<(rows: [ExpandableRow], categoryId: Int?, selectedRowId: Int?),
  NoError>
  public let loadFavoriteRows: Signal<(rows: [SelectableRow], categoryId: Int?), NoError>
  public let loadTopRows: Signal<(rows: [SelectableRow], categoryId: Int?), NoError>
  public let notifyDelegateOfSelectedRow: Signal<SelectableRow, NoError>

  public var inputs: DiscoveryFiltersViewModelInputs { return self }
  public var outputs: DiscoveryFiltersViewModelOutputs { return self }
}

/**
 Converts an array of categories into a grouped array of expandable rows,
 then finds the expandable row that contains the given selectable row, and expands it.

 - parameter selectedRow: An optional selected row to search for.

 - parameter categories: A full array of categories.

 - returns: An array of expandable rows with one row expanded.
 */
private func expandableRows(selectedRow selectedRow: SelectableRow,
                                        categories: [KsApi.Category]) -> [ExpandableRow] {

  let expandableRows = categories
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
              isSelected: childCategory == selectedRow.params.category,
              params: .defaults |> DiscoveryParams.lens.category .~ childCategory
            )
          }
      )
    }
    .sort { lhs, rhs in lhs.params.category < rhs.params.category }

  return expandableRows.map { expandableRow in
    return expandableRow
      |> ExpandableRow.lens.isExpanded .~
      expandableRow.selectableRows.lazy.map { $0.params }.contains(selectedRow.params)
      |> ExpandableRow.lens.selectableRows .~
      expandableRow.selectableRows.sort {
        if $0.params.category?.isRoot == $1.params.category?.isRoot {
          return $0.params.category?.name < $1.params.category?.name
        }
        return ($0.params.category?.isRoot ?? false) && !($1.params.category?.isRoot ?? false)
    }
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

  return expandableRows
    .map { expandableRow in

      return expandableRow
        |> ExpandableRow.lens.isExpanded .~ (expandableRow.params == rowToToggle.params &&
          !rowToToggle.isExpanded)
  }
}

private func topFilters(forUser user: User?) -> [DiscoveryParams] {
  var filters: [DiscoveryParams] = []

  filters.append(.defaults |> DiscoveryParams.lens.includePOTD .~ true)
  filters.append(.defaults |> DiscoveryParams.lens.staffPicks .~ true)

  if user != nil {
    filters.append(.defaults |> DiscoveryParams.lens.starred .~ true)
    filters.append(.defaults |> DiscoveryParams.lens.recommended .~ true)
  }

  if user?.social == true {
    filters.append(.defaults |> DiscoveryParams.lens.social .~ true)
  }

  return filters
}

private func favorites(selectedRow selectedRow: SelectableRow, categories: [KsApi.Category])
  -> [SelectableRow]? {

  let faves: [SelectableRow] = categories.flatMap { category in
    if AppEnvironment.current.ubiquitousStore.favoriteCategoryIds.contains(category.id) ||
      AppEnvironment.current.userDefaults.favoriteCategoryIds.contains(category.id) {

      return SelectableRow(
        isSelected: category == selectedRow.params.category,
        params: .defaults |> DiscoveryParams.lens.category .~ category
      )
    } else {
      return nil
    }
  }

  return faves.isEmpty ? nil : faves
}
