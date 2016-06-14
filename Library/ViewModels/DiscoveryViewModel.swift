import KsApi
import Prelude
import ReactiveCocoa
import ReactiveExtensions
import Result

public protocol DiscoveryViewModelInputs {
  /// Call when the filter button is pressed.
  func filterButtonTapped()

  /// Call when params have been selected from the filters menu.
  func filtersSelected(row row: SelectableRow)

  /// Call when the UIPageViewController finishes transitioning.
  func pageTransition(completed completed: Bool)

  /// Call when the SortPagerViewController wants to switch to a specific sort.
  func sortPagerSelected(sort sort: DiscoveryParams.Sort)

  /// Call from the controller's viewDidLoad.
  func viewDidLoad()

  /// Call when the UIPageViewController begins a transition sequence.
  func willTransition(toPage nextPage: Int)
}

public protocol DiscoveryViewModelOutputs {
  /// Emits an array of sorts that should be used to configure the pager data source.
  var configurePagerDataSource: Signal<[DiscoveryParams.Sort], NoError> { get }

  /// Emits an array of sorts that should be used to configure the sort pager controller.
  var configureSortPager: Signal<[DiscoveryParams.Sort], NoError> { get }

  /// Emits when the filters view controller should be dismissed.
  var dismissDiscoveryFilters: Signal<(), NoError> { get }

  /// Emits a string to display in the filter label.
  var filterLabelText: Signal<String, NoError> { get }

  /// Emits when the discovery filters should be presented.
  var goToDiscoveryFilters: Signal<SelectableRow, NoError> { get }

  /// Emits a discovery params value that should be passed to all the pages in discovery.
  var loadFilterIntoDataSource: Signal<DiscoveryParams, NoError> { get }

  /// Emits when we should manually navigate to a sort's page.
  var navigateToSort: Signal<(DiscoveryParams.Sort, UIPageViewControllerNavigationDirection), NoError> { get }

  /// Emits a sort that should be passed on to the sort pager view controller.
  var selectSortPage: Signal<DiscoveryParams.Sort, NoError> { get }
}

public protocol DiscoveryViewModelType {
  var inputs: DiscoveryViewModelInputs { get }
  var outputs: DiscoveryViewModelOutputs { get }
}

public final class DiscoveryViewModel: DiscoveryViewModelType, DiscoveryViewModelInputs,
DiscoveryViewModelOutputs {

  // swiftlint:disable function_body_length
  public init() {
    let initialParams = .defaults
      |> DiscoveryParams.lens.staffPicks .~ true
      |> DiscoveryParams.lens.includePOTD .~ true

    let sorts: [DiscoveryParams.Sort] = [.Magic, .Popular, .Newest, .EndingSoon, .MostFunded]

    self.configurePagerDataSource = self.viewDidLoadProperty.signal.mapConst(sorts)
    self.configureSortPager = self.configurePagerDataSource

    self.loadFilterIntoDataSource = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst(initialParams),
      self.filtersSelectedRowProperty.signal.ignoreNil().map { $0.params }
      )

    self.filterLabelText = self.loadFilterIntoDataSource
      .map { params in
        if params.staffPicks == true {
          return localizedString(key: "discovery.recommended", defaultValue: "Staff Picks")
        } else if params.starred == true {
          return localizedString(key: "discovery.saved", defaultValue: "Starred")
        } else if params.social == true {
          return localizedString(key: "discovery.friends_backed", defaultValue: "Friends Backed")
        } else if let category = params.category {
          return category.name
        }
        return localizedString(key: "discovery.everything", defaultValue: "Everything")
    }.skipRepeats()

    self.goToDiscoveryFilters = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst(SelectableRow(isSelected: true, params: initialParams)),
      self.filtersSelectedRowProperty.signal.ignoreNil()
      )
      .takeWhen(self.filterButtonTappedProperty.signal)

    let swipeToSort = self.willTransitionToPageProperty.signal
      .takeWhen(self.pageTransitionCompletedProperty.signal.filter(isTrue))
      .map { sorts[$0] }

    self.selectSortPage = Signal.merge(
      swipeToSort,
      self.sortPagerSelectedSortProperty.signal.ignoreNil()
      )
      .skipRepeats()

    self.navigateToSort = Signal.merge(
      swipeToSort.map { (sort: $0, ignore: true) },
      self.sortPagerSelectedSortProperty.signal.ignoreNil().map { (sort: $0, ignore: false) }
      )
      .skipRepeats(==)
      .combinePrevious((sort: .Magic, ignore: true))
      .filter { previous, next in !next.ignore }
      .map { previous, next in
        (next.sort,
         sorts.indexOf(next.sort) < sorts.indexOf(previous.sort) ? .Reverse : .Forward)
    }

    self.dismissDiscoveryFilters = self.filtersSelectedRowProperty.signal.ignoreValues()

    self.sortPagerSelectedSortProperty.signal.ignoreNil()
      .skipRepeats(==)
      .observeNext { AppEnvironment.current.koala.trackDiscoveryPagerSelectedSort(nextSort: $0) }

    swipeToSort
      .observeNext { AppEnvironment.current.koala.trackDiscoverySortsSwiped(nextSort: $0) }
  }
  // swiftlint:enable function_body_length

  private let filterButtonTappedProperty = MutableProperty()
  public func filterButtonTapped() {
    self.filterButtonTappedProperty.value = ()
  }
  private let filtersSelectedRowProperty = MutableProperty<SelectableRow?>(nil)
  public func filtersSelected(row row: SelectableRow) {
    self.filtersSelectedRowProperty.value = row
  }
  private let pageTransitionCompletedProperty = MutableProperty(false)
  public func pageTransition(completed completed: Bool) {
    self.pageTransitionCompletedProperty.value = completed
  }
  private let sortPagerSelectedSortProperty = MutableProperty<DiscoveryParams.Sort?>(nil)
  public func sortPagerSelected(sort sort: DiscoveryParams.Sort) {
    self.sortPagerSelectedSortProperty.value = sort
  }
  private let willTransitionToPageProperty = MutableProperty<Int>(0)
  public func willTransition(toPage nextPage: Int) {
    self.willTransitionToPageProperty.value = nextPage
  }
  private let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let configurePagerDataSource: Signal<[DiscoveryParams.Sort], NoError>
  public let configureSortPager: Signal<[DiscoveryParams.Sort], NoError>
  public let dismissDiscoveryFilters: Signal<(), NoError>
  public let filterLabelText: Signal<String, NoError>
  public let goToDiscoveryFilters: Signal<SelectableRow, NoError>
  public let loadFilterIntoDataSource: Signal<DiscoveryParams, NoError>
  public let navigateToSort: Signal<(DiscoveryParams.Sort, UIPageViewControllerNavigationDirection), NoError>
  public let selectSortPage: Signal<DiscoveryParams.Sort, NoError>

  public var inputs: DiscoveryViewModelInputs { return self }
  public var outputs: DiscoveryViewModelOutputs { return self }
}
