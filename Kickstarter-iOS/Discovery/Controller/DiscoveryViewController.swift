import KsApi
import Library
import Prelude
import UIKit

internal final class DiscoveryViewController: UIViewController {
  fileprivate let viewModel: DiscoveryViewModelType = DiscoveryViewModel()
  fileprivate var dataSource: DiscoveryPagesDataSource?

  private var recommendationsChangedObserver: Any?
  private weak var navigationHeaderViewController: DiscoveryNavigationHeaderViewController!
  private var optimizelyConfiguredObserver: Any?
  private var optimizelyConfigurationFailedObserver: Any?
  private weak var pageViewController: UIPageViewController!
  private weak var sortPagerViewController: SortPagerViewController!

  internal static func instantiate() -> DiscoveryViewController {
    return Storyboard.Discovery.instantiate(DiscoveryViewController.self)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.pageViewController = self.children
      .compactMap { $0 as? UIPageViewController }.first
    self.pageViewController.ksr_setViewControllers(
      [.init()],
      direction: .forward,
      animated: false,
      completion: nil
    )
    self.pageViewController.delegate = self

    self.sortPagerViewController = self.children
      .compactMap { $0 as? SortPagerViewController }.first
    self.sortPagerViewController.delegate = self

    self.navigationHeaderViewController = self.children
      .compactMap { $0 as? DiscoveryNavigationHeaderViewController }.first
    self.navigationHeaderViewController.delegate = self

    self.recommendationsChangedObserver = NotificationCenter.default
      .addObserver(
        forName: Notification.Name.ksr_recommendationsSettingChanged,
        object: nil,
        queue: nil
      ) { [weak self] _ in
        self?.viewModel.inputs.didChangeRecommendationsSetting()
      }

    self.optimizelyConfiguredObserver = NotificationCenter.default
      .addObserver(forName: .ksr_optimizelyClientConfigured, object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.optimizelyClientConfigured()
      }

    self.optimizelyConfigurationFailedObserver = NotificationCenter.default
      .addObserver(
        forName: .ksr_optimizelyClientConfigurationFailed,
        object: nil,
        queue: nil
      ) { [weak self] _ in
        self?.viewModel.inputs.optimizelyClientConfigurationFailed()
      }

    self.viewModel.inputs.viewDidLoad()
  }

  deinit {
    [
      self.optimizelyConfiguredObserver,
      self.optimizelyConfigurationFailedObserver,
      self.recommendationsChangedObserver
    ].forEach { $0.doIfSome(NotificationCenter.default.removeObserver) }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.viewModel.inputs.viewWillAppear(animated: animated)

    self.navigationController?.setNavigationBarHidden(true, animated: animated)
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.configureNavigationHeader
      .observeForControllerAction()
      .observeValues { [weak self] in self?.navigationHeaderViewController.configureWith(params: $0) }

    self.viewModel.outputs.configurePagerDataSource
      .observeForControllerAction()
      .observeValues { [weak self] in self?.configurePagerDataSource($0) }

    self.viewModel.outputs.configureSortPager
      .observeForControllerAction()
      .observeValues { [weak self] in self?.sortPagerViewController.configureWith(sorts: $0) }

    self.viewModel.outputs.loadFilterIntoDataSource
      .observeForControllerAction()
      .observeValues { [weak self] in self?.dataSource?.load(filter: $0) }

    self.viewModel.outputs.navigateToSort
      .observeForControllerAction()
      .observeValues { [weak self] sort, direction in
        guard let controller = self?.dataSource?.controllerFor(sort: sort) else { return }

        self?.pageViewController.ksr_setViewControllers(
          [controller], direction: direction, animated: true, completion: nil
        )
      }

    self.viewModel.outputs.selectSortPage
      .observeForControllerAction()
      .observeValues { [weak self] in self?.sortPagerViewController.select(sort: $0) }

    self.viewModel.outputs.sortsAreEnabled
      .observeForUI()
      .observeValues { [weak self] in
        self?.sortPagerViewController.setSortPagerEnabled($0)
        self?.setPageViewControllerScrollEnabled($0)
      }

    self.viewModel.outputs.updateSortPagerStyle
      .observeForControllerAction()
      .observeValues { [weak self] in self?.sortPagerViewController.updateStyle(categoryId: $0) }
  }

  internal func filter(with params: DiscoveryParams) {
    self.viewModel.inputs.filter(withParams: params)
  }

  internal func setSortsEnabled(_ enabled: Bool) {
    self.viewModel.inputs.setSortsEnabled(enabled)
  }

  fileprivate func configurePagerDataSource(_ sorts: [DiscoveryParams.Sort]) {
    self.dataSource = DiscoveryPagesDataSource(sorts: sorts)

    self.pageViewController.dataSource = self.dataSource

    self.pageViewController.ksr_setViewControllers(
      [self.dataSource?.controllerFor(index: 0)].compact(),
      direction: .forward,
      animated: false,
      completion: nil
    )
  }

  private func setPageViewControllerScrollEnabled(_ enabled: Bool) {
    self.pageViewController.dataSource = enabled == false ? nil : self.dataSource
  }
}

extension DiscoveryViewController: UIPageViewControllerDelegate {
  internal func pageViewController(
    _: UIPageViewController,
    didFinishAnimating _: Bool,
    previousViewControllers _: [UIViewController],
    transitionCompleted completed: Bool
  ) {
    self.viewModel.inputs.pageTransition(completed: completed)
  }

  internal func pageViewController(
    _: UIPageViewController,
    willTransitionTo pendingViewControllers: [UIViewController]
  ) {
    guard let dataSource = self.dataSource,
      let idx = pendingViewControllers.first.flatMap(dataSource.indexFor(controller:)) else { return }

    self.viewModel.inputs.willTransition(toPage: idx)
  }
}

extension DiscoveryViewController: SortPagerViewControllerDelegate {
  internal func sortPager(_: UIViewController, selectedSort sort: DiscoveryParams.Sort) {
    self.viewModel.inputs.sortPagerSelected(sort: sort)
  }
}

extension DiscoveryViewController: DiscoveryNavigationHeaderViewDelegate {
  func discoveryNavigationHeaderFilterSelectedParams(_ params: DiscoveryParams) {
    self.filter(with: params)
  }
}

extension DiscoveryViewController: TabBarControllerScrollable {
  func scrollToTop() {
    if let scrollView = self.pageViewController?.viewControllers?.first?.view as? UIScrollView {
      scrollView.scrollToTop()
    }
  }
}
