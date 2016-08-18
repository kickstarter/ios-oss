import KsApi
import Library
import UIKit

internal final class DiscoveryViewController: UIViewController {
  private let viewModel: DiscoveryViewModelType = DiscoveryViewModel()
  private var dataSource: DiscoveryPagesDataSource!

  private weak var pageViewController: UIPageViewController!
  private weak var sortPagerViewController: SortPagerViewController!
  @IBOutlet private weak var titleButton: UIButton!

  internal static func instantiate() -> DiscoveryViewController {
    return Storyboard.Discovery.instantiate(DiscoveryViewController)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.pageViewController = self.childViewControllers
      .filter { $0 is UIPageViewController }
      .first as? UIPageViewController
    self.pageViewController.delegate = self

    self.sortPagerViewController = self.childViewControllers
      .filter { $0 is SortPagerViewController }
      .first as? SortPagerViewController
    self.sortPagerViewController.delegate = self

    self.viewModel.inputs.viewDidLoad()
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    self.viewModel.inputs.viewWillAppear(animated: animated)
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.titleButton.rac.title = self.viewModel.outputs.filterLabelText

    self.viewModel.outputs.configurePagerDataSource
      .observeForUI()
      .observeNext { [weak self] in
        self?.configurePagerDataSource($0)
    }

    self.viewModel.outputs.configureSortPager
      .observeNext { [weak self] in
        self?.sortPagerViewController.configureWith(sorts: $0)
    }

    self.viewModel.outputs.goToDiscoveryFilters
      .observeForUI()
      .observeNext { [weak self] in
        self?.goToDiscoveryFilters($0)
    }

    self.viewModel.outputs.loadFilterIntoDataSource
      .observeNext { [weak self] in
        self?.dataSource.load(filter: $0)
    }

    self.viewModel.outputs.selectSortPage
      .observeNext { [weak self] in
        self?.sortPagerViewController.select(sort: $0)
    }

    self.viewModel.outputs.updateSortPagerStyle
      .observeForUI()
      .observeNext { [weak self] id in
        self?.sortPagerViewController.updateStyle(categoryId: id)
    }

    self.viewModel.outputs.navigateToSort
      .observeForUI()
      .observeNext { [weak self] sort, direction in
        guard let controller = self?.dataSource.controllerFor(sort: sort) else {
          fatalError("Controller not found for sort \(sort)")
        }

        self?.pageViewController.setViewControllers(
          [controller], direction: direction, animated: true, completion: nil
        )
    }

    self.viewModel.outputs.dismissDiscoveryFilters
      .observeForUI()
      .observeNext { [weak self] in
        self?.dismissViewControllerAnimated(true, completion: nil)
    }
  }

  private func goToDiscoveryFilters(selectedRow: SelectableRow) {
    guard let vc = self.storyboard?.instantiateViewControllerWithIdentifier("DiscoveryFiltersViewController"),
      filters = vc as? DiscoveryFiltersViewController else {

      fatalError("Couldn't instantiate DiscoveryFiltersViewController.")
    }

    filters.configureWith(selectedRow: selectedRow)
    filters.delegate = self

    self.presentViewController(vc, animated: true, completion: nil)
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

  @IBAction private func filterButtonTapped() {
    self.viewModel.inputs.filterButtonTapped()
  }
}

extension DiscoveryViewController: DiscoveryFiltersViewControllerDelegate {
  internal func discoveryFilters(viewController: DiscoveryFiltersViewController, selectedRow: SelectableRow) {
    self.viewModel.inputs.filtersSelected(row: selectedRow)
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
