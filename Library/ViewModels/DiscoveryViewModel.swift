import CoreGraphics
import KsApi
import Models
import Prelude
import ReactiveCocoa
import ReactiveExtensions
import Result

public protocol DiscoveryViewModelInputs {
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

public protocol DiscoveryViewModelOutputs {
  /// Emits a list of projects that should be shown.
  var projects: Signal<[Project], NoError> { get }

  /// Emits a boolean that determines if projects are currently loading or not.
  var projectsAreLoading: Signal<Bool, NoError> { get }
}

public protocol DiscoveryViewModelType {
  var inputs: DiscoveryViewModelInputs { get }
  var outputs: DiscoveryViewModelOutputs { get }
}

public final class DiscoveryViewModel: DiscoveryViewModelType, DiscoveryViewModelInputs,
DiscoveryViewModelOutputs {
  typealias Model = ()

  private let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  private let willDisplayRowProperty = MutableProperty<(row: Int, total: Int)?>(nil)
  public func willDisplayRow(row: Int, outOf totalRows: Int) {
    self.willDisplayRowProperty.value = (row, totalRows)
  }

  private let filterParamsChangedProperty = MutableProperty<DiscoveryParams?>(nil)
  public func filterParamsChanged(params: DiscoveryParams) {
    self.filterParamsChangedProperty.value = params
  }

  private let sortChangedProperty = MutableProperty<DiscoveryParams.Sort?>(nil)
  public func sortChanged(sort: DiscoveryParams.Sort) {
    self.sortChangedProperty.value = sort
  }

  public let projects: Signal<[Project], NoError>
  public let projectsAreLoading: Signal<Bool, NoError>

  public var inputs: DiscoveryViewModelInputs { return self }
  public var outputs: DiscoveryViewModelOutputs { return self }

  public init() {
    // emits when the next page of discovery should be loaded.
    let isCloseToBottom = self.willDisplayRowProperty.signal.ignoreNil()
      .map { row, total in row >= total - 3 }
      .skipRepeats()
      .filter { isClose in isClose }
      .ignoreValues()

    let params = DiscoveryParams.defaults
      |> DiscoveryParams.lens.staffPicks .~ true
      |> DiscoveryParams.lens.includePOTD .~ true

    let filterChange = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst(params),
      self.filterParamsChangedProperty.signal.ignoreNil()
      )

    let sortChange = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst(.Magic),
      self.sortChangedProperty.signal.ignoreNil()
    )

    let paramsChanged = combineLatest(filterChange, sortChange)
      .map { filter, sort in filter |> DiscoveryParams.lens.sort .~ sort }

    (self.projects, self.projectsAreLoading, _) = paginate(
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
