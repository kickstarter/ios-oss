import KsApi
import Library
import Prelude
import UIKit

internal final class DiscoveryViewController: UIViewController {
  private let viewModel: DiscoveryViewModelType = DiscoveryViewModel()
  private var dataSource: DiscoveryPagesDataSource!

  private weak var navigationHeaderViewController: DiscoveryNavigationHeaderViewController!
  private weak var pageViewController: UIPageViewController!
  private weak var sortPagerViewController: SortPagerViewController!

  internal static func instantiate() -> DiscoveryViewController {
    return Storyboard.Discovery.instantiate(DiscoveryViewController)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.pageViewController = self.childViewControllers
      .flatMap { $0 as? UIPageViewController }.first
    self.pageViewController.delegate = self

    self.sortPagerViewController = self.childViewControllers
      .flatMap { $0 as? SortPagerViewController }.first
    self.sortPagerViewController.delegate = self

    self.navigationHeaderViewController = self.childViewControllers
      .flatMap { $0 as? DiscoveryNavigationHeaderViewController }.first
    self.navigationHeaderViewController.delegate = self

    self.viewModel.inputs.viewDidLoad()
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    self.viewModel.inputs.viewWillAppear(animated: animated)

    self.navigationController?.setNavigationBarHidden(true, animated: animated)
  }

  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)

    self.navigationController?.setNavigationBarHidden(false, animated: animated)
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.configureNavigationHeader
      .observeForControllerAction()
      .observeNext { [weak self] in self?.navigationHeaderViewController.configureWith(params: $0) }

    self.viewModel.outputs.configurePagerDataSource
      .observeForControllerAction()
      .observeNext { [weak self] in self?.configurePagerDataSource($0) }

    self.viewModel.outputs.configureSortPager
      .observeNext { [weak self] in self?.sortPagerViewController.configureWith(sorts: $0) }

    self.viewModel.outputs.loadFilterIntoDataSource
      .observeForControllerAction()
      .observeNext { [weak self] in self?.dataSource.load(filter: $0) }

    self.viewModel.outputs.selectSortPage
      .observeForControllerAction()
      .observeNext { [weak self] in self?.sortPagerViewController.select(sort: $0) }

    self.viewModel.outputs.updateSortPagerStyle
      .observeForControllerAction()
      .observeNext { [weak self] in self?.sortPagerViewController.updateStyle(categoryId: $0) }

    self.viewModel.outputs.navigateToSort
      .observeForControllerAction()
      .observeNext { [weak self] sort, direction in
        guard let controller = self?.dataSource.controllerFor(sort: sort) else {
          fatalError("Controller not found for sort \(sort)")
        }

        self?.pageViewController.setViewControllers(
          [controller], direction: direction, animated: true, completion: nil
        )
    }
  }

  internal func filter(with params: DiscoveryParams) {
    self.viewModel.inputs.filter(withParams: params)
  }

  private func configurePagerDataSource(sorts: [DiscoveryParams.Sort]) {
    self.dataSource = DiscoveryPagesDataSource(sorts: sorts)

    self.pageViewController.dataSource = self.dataSource
    self.pageViewController.setViewControllers(
      [self.dataSource.controllerFor(index: 0)].compact(),
      direction: .Forward,
      animated: false,
      completion: nil
    )
  }
}

extension DiscoveryViewController: UIPageViewControllerDelegate {
  internal func pageViewController(pageViewController: UIPageViewController,
                                   didFinishAnimating finished: Bool,
                                   previousViewControllers: [UIViewController],
                                   transitionCompleted completed: Bool) {

    self.viewModel.inputs.pageTransition(completed: completed)
  }

  internal func pageViewController(
    pageViewController: UIPageViewController,
    willTransitionToViewControllers pendingViewControllers: [UIViewController]) {

    guard let idx = pendingViewControllers.first.flatMap(self.dataSource.indexFor(controller:)) else {
      return
    }

    self.viewModel.inputs.willTransition(toPage: idx)
  }
}

extension DiscoveryViewController: SortPagerViewControllerDelegate {
  internal func sortPager(viewController: UIViewController, selectedSort sort: DiscoveryParams.Sort) {
    self.viewModel.inputs.sortPagerSelected(sort: sort)
  }
}

extension DiscoveryViewController: DiscoveryNavigationHeaderViewDelegate {
  func discoveryNavigationHeaderFilterSelectedParams(params: DiscoveryParams) {
    self.filter(with: params)
  }
}
