import KsApi
import Library
import Prelude
import UIKit

internal final class DiscoveryViewController: UIViewController {
  fileprivate let viewModel: DiscoveryViewModelType = DiscoveryViewModel()
  fileprivate var dataSource: DiscoveryPagesDataSource!

  private weak var liveStreamDiscoveryViewController: LiveStreamDiscoveryViewController!
  private weak var navigationHeaderViewController: DiscoveryNavigationHeaderViewController!
  private weak var pageViewController: UIPageViewController!
  private weak var sortPagerViewController: SortPagerViewController!
  internal static func instantiate() -> DiscoveryViewController {
    return Storyboard.Discovery.instantiate(DiscoveryViewController.self)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.pageViewController = self.children
      .compactMap { $0 as? UIPageViewController }.first
    self.pageViewController.setViewControllers(
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

    self.liveStreamDiscoveryViewController = self.children
      .compactMap { $0 as? LiveStreamDiscoveryViewController }.first

    self.viewModel.inputs.viewDidLoad()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.viewModel.inputs.viewWillAppear(animated: animated)

    self.navigationController?.setNavigationBarHidden(true, animated: animated)
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.liveStreamDiscoveryViewHidden
      .observeForUI()
      .observeValues { [weak self] hidden in
        self?.liveStreamDiscoveryViewController.view.superview?.isHidden = hidden
        self?.liveStreamDiscoveryViewController.isActive(!hidden)
    }

    self.viewModel.outputs.discoveryPagesViewHidden
      .observeForUI()
      .observeValues { [weak self] in
        self?.pageViewController.view.superview?.isHidden = $0
    }

    self.viewModel.outputs.sortViewHidden
      .observeForUI()
      .observeValues { [weak self] in
        self?.sortPagerViewController.view.superview?.isHidden = $0
    }

    self.viewModel.outputs.configureNavigationHeader
      .observeForControllerAction()
      .observeValues { [weak self] in self?.navigationHeaderViewController.configureWith(params: $0) }

    self.viewModel.outputs.configurePagerDataSource
      .observeForControllerAction()
      .observeValues { [weak self] in self?.configurePagerDataSource($0) }

    self.viewModel.outputs.configureSortPager
      .observeValues { [weak self] in self?.sortPagerViewController.configureWith(sorts: $0) }

    self.viewModel.outputs.loadFilterIntoDataSource
      .observeForControllerAction()
      .observeValues { [weak self] in self?.dataSource.load(filter: $0) }

    self.viewModel.outputs.navigateToSort
      .observeForControllerAction()
      .observeValues { [weak self] sort, direction in
        guard let controller = self?.dataSource.controllerFor(sort: sort) else {
          fatalError("Controller not found for sort \(sort)")
        }

        self?.pageViewController.setViewControllers(
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

    DispatchQueue.main.async {
      self.pageViewController.setViewControllers(
        [self.dataSource.controllerFor(index: 0)].compact(),
        direction: .forward,
        animated: false,
        completion: nil
      )
    }
  }

  private func setPageViewControllerScrollEnabled(_ enabled: Bool) {
    self.pageViewController.dataSource = enabled == false ? nil : self.dataSource
  }
}

extension DiscoveryViewController: UIPageViewControllerDelegate {
  internal func pageViewController(_ pageViewController: UIPageViewController,
                                   didFinishAnimating finished: Bool,
                                   previousViewControllers: [UIViewController],
                                   transitionCompleted completed: Bool) {

    self.viewModel.inputs.pageTransition(completed: completed)
  }

  internal func pageViewController(
    _ pageViewController: UIPageViewController,
    willTransitionTo pendingViewControllers: [UIViewController]) {

    guard let idx = pendingViewControllers.first.flatMap(self.dataSource.indexFor(controller:)) else {
      return
    }

    self.viewModel.inputs.willTransition(toPage: idx)
  }
}

extension DiscoveryViewController: SortPagerViewControllerDelegate {
  internal func sortPager(_ viewController: UIViewController, selectedSort sort: DiscoveryParams.Sort) {
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
    let view: UIView?

    if let superview = self.liveStreamDiscoveryViewController.view.superview, superview.isHidden {
      view = self.pageViewController.viewControllers?.first?.view
    } else {
      view = self.liveStreamDiscoveryViewController.view
    }

    if let scrollView = view as? UIScrollView {
      scrollView.scrollToTop()
    }
  }
}
