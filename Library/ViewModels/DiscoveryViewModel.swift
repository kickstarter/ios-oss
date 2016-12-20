import Argo
import Runes
import KsApi
import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result

public protocol DiscoveryViewModelInputs {
  /// Call when params have been selected.
  func filter(withParams params: DiscoveryParams)

  /// Call when the UIPageViewController finishes transitioning.
  func pageTransition(completed: Bool)

  /// Call when the SortPagerViewController wants to switch to a specific sort.
  func sortPagerSelected(sort: DiscoveryParams.Sort)

  /// Call to disable/enable the sorts when an empty state is displayed/dismissed.
  func setSortsEnabled(_ enabled: Bool)

  /// Call from the controller's viewDidLoad.
  func viewDidLoad()

  /// Call from the controller's viewWillAppear.
  func viewWillAppear(animated: Bool)

  /// Call when the UIPageViewController begins a transition sequence.
  func willTransition(toPage nextPage: Int)
}

public protocol DiscoveryViewModelOutputs {
  /// Emits params to configure the navigation header.
  var configureNavigationHeader: Signal<DiscoveryParams, NoError> { get }

  /// Emits an array of sorts that should be used to configure the pager data source.
  var configurePagerDataSource: Signal<[DiscoveryParams.Sort], NoError> { get }

  /// Emits an array of sorts that should be used to configure the sort pager controller.
  var configureSortPager: Signal<[DiscoveryParams.Sort], NoError> { get }

  /// Emits a discovery params value that should be passed to all the pages in discovery.
  var loadFilterIntoDataSource: Signal<DiscoveryParams, NoError> { get }

  /// Emits when we should manually navigate to a sort's page.
  var navigateToSort: Signal<(DiscoveryParams.Sort, UIPageViewControllerNavigationDirection), NoError> { get }

  /// Emits a sort that should be passed on to the sort pager view controller.
  var selectSortPage: Signal<DiscoveryParams.Sort, NoError> { get }

  /// Emits to disable/enable the sorts when an empty state is displayed/dismissed.
  var sortsAreEnabled: Signal<Bool, NoError> { get }

  /// Emits a category id to update the sort pager view controller style.
  var updateSortPagerStyle: Signal<Int?, NoError> { get }
}

public protocol DiscoveryViewModelType {
  var inputs: DiscoveryViewModelInputs { get }
  var outputs: DiscoveryViewModelOutputs { get }
}

public final class DiscoveryViewModel: DiscoveryViewModelType, DiscoveryViewModelInputs,
DiscoveryViewModelOutputs {
  fileprivate static let defaultParams = .defaults |> DiscoveryParams.lens.includePOTD .~ true

  // swiftlint:disable function_body_length
  public init() {
    let sorts: [DiscoveryParams.Sort] = [.magic, .popular, .newest, .endingSoon, .mostFunded]

    self.configurePagerDataSource = self.viewDidLoadProperty.signal.mapConst(sorts)
    self.configureSortPager = self.configurePagerDataSource

    let currentParams = self.viewWillAppearProperty.signal
      .take(first: 1)
      .flatMap { [filterWithParams = filterWithParamsProperty.producer.skipNil()] _ in
        filterWithParams.prefix(value: DiscoveryViewModel.defaultParams)
      }
      .skipRepeats()

    self.configureNavigationHeader = currentParams

    self.loadFilterIntoDataSource = currentParams

    let swipeToSort = self.willTransitionToPageProperty.signal
      .takeWhen(self.pageTransitionCompletedProperty.signal.filter(isTrue))
      .map { sorts[$0] }

    self.selectSortPage = Signal
      .merge(
        swipeToSort,
        self.sortPagerSelectedSortProperty.signal.skipNil(),
        currentParams.map { $0.sort }.skipNil()
      )
      .skipRepeats()

    self.navigateToSort = Signal
      .merge(
        swipeToSort.map { (sort: $0, ignore: true) },
        self.sortPagerSelectedSortProperty.signal.skipNil().map { (sort: $0, ignore: false) },
        currentParams.map { $0.sort }.skipNil().map { (sort: $0, ignore: false) }
      )
      .skipRepeats(==)
      .combinePrevious((sort: .magic, ignore: true))
      .filter { previous, next in !next.ignore }
      .map { previous, next in
        let lhs = sorts.index(of: next.sort) ?? -1
        let rhs = sorts.index(of: previous.sort) ?? 9999
        return (next.sort, lhs < rhs ? .reverse : .forward)
    }

    self.updateSortPagerStyle = self.filterWithParamsProperty.signal.skipNil()
      .map { $0.category?.root?.id }
      .skipRepeats(==)

    self.sortsAreEnabled = self.setSortsEnabledProperty.signal.skipNil()

    self.sortPagerSelectedSortProperty.signal.skipNil()
      .skipRepeats(==)
      .observeValues { AppEnvironment.current.koala.trackDiscoverySelectedSort(nextSort: $0, gesture: .tap) }

    swipeToSort
      .observeValues { AppEnvironment.current.koala.trackDiscoverySelectedSort(nextSort: $0, gesture: .swipe) }

    currentParams
      .takeWhen(self.viewWillAppearProperty.signal.skipNil().filter(isFalse))
      .observeValues { AppEnvironment.current.koala.trackDiscoveryViewed(params: $0) }
  }
  // swiftlint:enable function_body_length

  fileprivate let filterWithParamsProperty = MutableProperty<DiscoveryParams?>(nil)
  public func filter(withParams params: DiscoveryParams) {
    self.filterWithParamsProperty.value = params
  }
  fileprivate let pageTransitionCompletedProperty = MutableProperty(false)
  public func pageTransition(completed: Bool) {
    self.pageTransitionCompletedProperty.value = completed
  }
  fileprivate let sortPagerSelectedSortProperty = MutableProperty<DiscoveryParams.Sort?>(nil)
  public func sortPagerSelected(sort: DiscoveryParams.Sort) {
    self.sortPagerSelectedSortProperty.value = sort
  }
  fileprivate let setSortsEnabledProperty = MutableProperty<Bool?>(nil)
  public func setSortsEnabled(_ enabled: Bool) {
    self.setSortsEnabledProperty.value = enabled
  }
  fileprivate let willTransitionToPageProperty = MutableProperty<Int>(0)
  public func willTransition(toPage nextPage: Int) {
    self.willTransitionToPageProperty.value = nextPage
  }
  fileprivate let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }
  fileprivate let viewWillAppearProperty = MutableProperty<Bool?>(nil)
  public func viewWillAppear(animated: Bool) {
    self.viewWillAppearProperty.value = animated
  }

  public let configureNavigationHeader: Signal<DiscoveryParams, NoError>
  public let configurePagerDataSource: Signal<[DiscoveryParams.Sort], NoError>
  public let configureSortPager: Signal<[DiscoveryParams.Sort], NoError>
  public let loadFilterIntoDataSource: Signal<DiscoveryParams, NoError>
  public let navigateToSort: Signal<(DiscoveryParams.Sort, UIPageViewControllerNavigationDirection), NoError>
  public let selectSortPage: Signal<DiscoveryParams.Sort, NoError>
  public let sortsAreEnabled: Signal<Bool, NoError>
  public let updateSortPagerStyle: Signal<Int?, NoError>

  public var inputs: DiscoveryViewModelInputs { return self }
  public var outputs: DiscoveryViewModelOutputs { return self }
}
