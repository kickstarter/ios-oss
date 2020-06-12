import Argo
import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift
import Runes

public protocol DiscoveryViewModelInputs {
  /// Call when Recommendations setting changes on Settings > Account > Privacy > Recommendations.
  func didChangeRecommendationsSetting()

  /// Call when params have been selected.
  func filter(withParams params: DiscoveryParams)

  /// Call when the OptimizelyClient has been configured
  func optimizelyClientConfigured()

  /// Call when the OptimizelyClient configuration has failed
  func optimizelyClientConfigurationFailed()

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
  var configureNavigationHeader: Signal<DiscoveryParams, Never> { get }

  /// Emits an array of sorts that should be used to configure the pager data source.
  var configurePagerDataSource: Signal<[DiscoveryParams.Sort], Never> { get }

  /// Emits an array of sorts that should be used to configure the sort pager controller.
  var configureSortPager: Signal<[DiscoveryParams.Sort], Never> { get }

  /// Emits a discovery params value that should be passed to all the pages in discovery.
  var loadFilterIntoDataSource: Signal<DiscoveryParams, Never> { get }

  /// Emits when we should manually navigate to a sort's page.
  var navigateToSort: Signal<
    (DiscoveryParams.Sort, UIPageViewController.NavigationDirection),
    Never
  > { get }

  /// Emits a sort that should be passed on to the sort pager view controller.
  var selectSortPage: Signal<DiscoveryParams.Sort, Never> { get }

  /// Emits to disable/enable the sorts when an empty state is displayed/dismissed.
  var sortsAreEnabled: Signal<Bool, Never> { get }

  /// Emits a category id to update the sort pager view controller style.
  var updateSortPagerStyle: Signal<Int?, Never> { get }
}

public protocol DiscoveryViewModelType {
  var inputs: DiscoveryViewModelInputs { get }
  var outputs: DiscoveryViewModelOutputs { get }
}

public final class DiscoveryViewModel: DiscoveryViewModelType, DiscoveryViewModelInputs,
  DiscoveryViewModelOutputs {
  internal static func initialParams() -> DiscoveryParams {
    guard AppEnvironment.current.currentUser?.optedOutOfRecommendations == .some(false) else {
      return DiscoveryParams.defaults
        |> DiscoveryParams.lens.includePOTD .~ true
    }

    return DiscoveryParams.recommendedDefaults
  }

  public init() {
    let optimizelyReadyOrContinue = Signal.merge(
      self.optimizelyClientConfiguredProperty.signal,
      self.viewDidLoadProperty.signal.map { AppEnvironment.current.optimizelyClient }
        .skipNil()
        .ignoreValues(),
      self.optimizelyClientConfigurationFailedProperty.signal
    ).take(first: 1)
      .map {
        // Immediately activate the nativeProjectCards experiment
        activateNativeProjectCardsExperiment()
      }.ignoreValues()

    let sorts: [DiscoveryParams.Sort] = [.magic, .popular, .newest, .endingSoon]

    let configureWithSorts = optimizelyReadyOrContinue.mapConst(sorts)

    self.configurePagerDataSource = configureWithSorts
    self.configureSortPager = configureWithSorts

    let initialParams = Signal.merge(
      self.viewWillAppearProperty.signal.take(first: 1).ignoreValues(),
      self.didChangeRecommendationsSettingProperty.signal
        .takeWhen(self.viewWillAppearProperty.signal)
    )
    .map(DiscoveryViewModel.initialParams)
    .skipRepeats()

    let currentParams = Signal.merge(
      initialParams,
      self.filterWithParamsProperty.signal.skipNil()
    )
    .skipRepeats()

    let dataSourceConfiguredAndCurrentParams = Signal.combineLatest(
      configureWithSorts.ksr_debounce(.nanoseconds(0), on: AppEnvironment.current.scheduler),
      currentParams
    )
    .map(second)

    self.configureNavigationHeader = dataSourceConfiguredAndCurrentParams
    self.loadFilterIntoDataSource = dataSourceConfiguredAndCurrentParams

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
      .filter { _, next in !next.ignore }
      .map { previous, next in
        let lhs = sorts.firstIndex(of: next.sort) ?? -1
        let rhs = sorts.firstIndex(of: previous.sort) ?? 9_999
        return (next.sort, lhs < rhs ? .reverse : .forward)
      }

    self.updateSortPagerStyle = self.filterWithParamsProperty.signal.skipNil()
      .map { $0.category?.intID }
      .skipRepeats(==)

    self.sortsAreEnabled = self.setSortsEnabledProperty.signal.skipNil()

    currentParams
      .takePairWhen(self.sortPagerSelectedSortProperty.signal.skipNil().skipRepeats(==))
      .observeValues { AppEnvironment.current.koala.trackDiscoverySelectedSort(nextSort: $1, params: $0) }

    currentParams
      .takePairWhen(swipeToSort)
      .observeValues {
        AppEnvironment.current.koala.trackDiscoverySelectedSort(nextSort: $1, params: $0)
      }
  }

  fileprivate let didChangeRecommendationsSettingProperty = MutableProperty(())
  public func didChangeRecommendationsSetting() {
    self.didChangeRecommendationsSettingProperty.value = ()
  }

  fileprivate let filterWithParamsProperty = MutableProperty<DiscoveryParams?>(nil)
  public func filter(withParams params: DiscoveryParams) {
    self.filterWithParamsProperty.value = params
  }

  fileprivate let optimizelyClientConfiguredProperty = MutableProperty(())
  public func optimizelyClientConfigured() {
    self.optimizelyClientConfiguredProperty.value = ()
  }

  fileprivate let optimizelyClientConfigurationFailedProperty = MutableProperty(())
  public func optimizelyClientConfigurationFailed() {
    self.optimizelyClientConfigurationFailedProperty.value = ()
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

  fileprivate let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  fileprivate let viewWillAppearProperty = MutableProperty<Bool?>(nil)
  public func viewWillAppear(animated: Bool) {
    self.viewWillAppearProperty.value = animated
  }

  public let configureNavigationHeader: Signal<DiscoveryParams, Never>
  public let configurePagerDataSource: Signal<[DiscoveryParams.Sort], Never>
  public let configureSortPager: Signal<[DiscoveryParams.Sort], Never>
  public let loadFilterIntoDataSource: Signal<DiscoveryParams, Never>
  public let navigateToSort: Signal<(DiscoveryParams.Sort, UIPageViewController.NavigationDirection), Never>
  public let selectSortPage: Signal<DiscoveryParams.Sort, Never>
  public let sortsAreEnabled: Signal<Bool, Never>
  public let updateSortPagerStyle: Signal<Int?, Never>

  public var inputs: DiscoveryViewModelInputs { return self }
  public var outputs: DiscoveryViewModelOutputs { return self }
}

private func activateNativeProjectCardsExperiment() -> OptimizelyExperiment.Variant {
  guard let optimizelyClient = AppEnvironment.current.optimizelyClient else {
    return .control
  }

  let variant = optimizelyClient.variant(for: .nativeProjectCards)

  return variant
}
