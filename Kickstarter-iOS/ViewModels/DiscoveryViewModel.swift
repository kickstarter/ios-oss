import CoreGraphics
import Library
import KsApi
import ReactiveCocoa
import Models
import Result
import Prelude
import Library

internal protocol DiscoveryViewModelInputs {
  /// Call from the controller's viewDidLoad.
  func viewDidLoad()

  /**
   Call from the controller's `tableView:willDisplayCell:forRowAtIndexPath` method.

   - parameter row:       The 0-based index of the row displaying.
   - parameter totalRows: The total number of rows in the table view.
   */
  func willDisplayRow(row: Int, outOf totalRows: Int)

  /// Call when params have been selected from the filters menu.
  func filterParamsChanged(params: DiscoveryParams)

  /// Call when the sort has changed.
  func sortChanged(sort: DiscoveryParams.Sort)
}

internal protocol DiscoveryViewModelOutputs {
  /// Emits a list of projects that should be shown.
  var projects: Signal<[Project], NoError> { get }

  /// Emits a boolean that determines if projects are currently loading or not.
  var projectsAreLoading: Signal<Bool, NoError> { get }
}

internal protocol DiscoveryViewModelType {
  var inputs: DiscoveryViewModelInputs { get }
  var outputs: DiscoveryViewModelOutputs { get }
}

internal final class DiscoveryViewModel: ViewModelType, DiscoveryViewModelType, DiscoveryViewModelInputs,
DiscoveryViewModelOutputs {
  typealias Model = ()

  private let viewDidLoadProperty = MutableProperty()
  internal func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  private let willDisplayRowProperty = MutableProperty<(row: Int, total: Int)?>(nil)
  internal func willDisplayRow(row: Int, outOf totalRows: Int) {
    self.willDisplayRowProperty.value = (row, totalRows)
  }

  private let filterParamsChangedProperty = MutableProperty<DiscoveryParams?>(nil)
  internal func filterParamsChanged(params: DiscoveryParams) {
    self.filterParamsChangedProperty.value = params
  }

  private let sortChangedProperty = MutableProperty<DiscoveryParams.Sort?>(nil)
  internal func sortChanged(sort: DiscoveryParams.Sort) {
    self.sortChangedProperty.value = sort
  }

  internal let projects: Signal<[Project], NoError>
  internal let projectsAreLoading: Signal<Bool, NoError>

  internal var inputs: DiscoveryViewModelInputs { return self }
  internal var outputs: DiscoveryViewModelOutputs { return self }

  internal init() {
    // emits when the next page of discovery should be loaded.
    let isCloseToBottom = self.willDisplayRowProperty.signal.ignoreNil()
      .map { row, total in row >= total - 3 }
      .skipRepeats()
      .filter { isClose in isClose }
      .ignoreValues()

    let filterChange = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst(DiscoveryParams(staffPicks: true, includePOTD: true)),
      self.filterParamsChangedProperty.signal.ignoreNil()
      )

    let sortChange = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst(.Magic),
      self.sortChangedProperty.signal.ignoreNil()
    )

    let paramsChanged = combineLatest(filterChange, sortChange)
      .map { filter, sort in filter.with(sort: sort) }

    (self.projects, self.projectsAreLoading) = paginate(
      requestFirstPageWith: paramsChanged,
      requestNextPageWhen: isCloseToBottom,
      clearOnNewRequest: true,
      valuesFromEnvelope: { $0.projects },
      cursorFromEnvelope: { $0.urls.api.moreProjects },
      requestFromParams: { AppEnvironment.current.apiService.fetchDiscovery(params: $0) },
      requestFromCursor: { AppEnvironment.current.apiService.fetchDiscovery(paginationUrl: $0) })

    self.viewDidLoadProperty.signal
      .observeNext { AppEnvironment.current.koala.trackDiscovery() }
  }
}
