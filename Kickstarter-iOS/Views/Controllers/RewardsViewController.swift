import KsApi
import Library
import Prelude

internal final class RewardsViewController: UITableViewController {
  private let dataSource = RewardsDataSource()
  private let viewModel: RewardsViewModelType = RewardsViewModel()
  private var headerView: UIView?

  internal func configureWith(project project: Project) {
    self.viewModel.inputs.configureWith(project: project)
  }

  internal func transfer(headerView headerView: UIView?, previousContentOffset: CGPoint?) {
    self.headerView = headerView
    if let headerView = headerView {
      self.view.addSubview(headerView)
      self.viewModel.inputs.transferredHeaderView(atContentOffset: previousContentOffset)
    }
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()
    self.tableView.dataSource = dataSource
    self.viewModel.inputs.viewDidLoad()
  }

  internal override func bindStyles() {
    super.bindStyles()
    self
      |> baseTableControllerStyle(estimatedRowHeight: 300)
      |> (UITableViewController.lens.tableView • UITableView.lens.delaysContentTouches) .~ false
      |> (UITableViewController.lens.tableView • UITableView.lens.canCancelContentTouches) .~ true
      |> (UITableViewController.lens.tableView • UITableView.lens.clipsToBounds) .~ false
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.loadProjectIntoDataSource
      .observeForControllerAction()
      .observeNext { [weak self] project in
        self?.dataSource.load(project: project)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.layoutHeaderView
      .observeForControllerAction()
      .observeNext { [weak self] in
        self?.layoutHeaderView(atContentOffset: $0)
    }
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    self.viewModel.inputs.viewDidLayoutSubviews(contentSize: self.tableView.contentSize)
  }

  internal func layoutHeaderView(atContentOffset contentOffset: CGPoint?) {

    guard let headerView = self.headerView else { return }

    headerView.frame.size = headerView.systemLayoutSizeFittingSize(
      CGSize(width: self.view.frame.width, height: 0),
      withHorizontalFittingPriority: UILayoutPriorityRequired,
      verticalFittingPriority: UILayoutPriorityDefaultLow
    )
    headerView.frame.origin.y = -headerView.frame.height

    self.tableView.contentInset.top = headerView.frame.height

    if let contentOffset = contentOffset {
      self.tableView.contentOffset.y = -self.tableView.contentInset.top + contentOffset.y
    }
  }
}
