import KsApi
import Library
import UIKit

internal final class DiscoveryPageViewController: UITableViewController {
  private let viewModel: DiscoveryPageViewModelType = DiscoveryPageViewModel()
  private let dataSource = DiscoveryProjectsDataSource()

  internal func configureWith(sort sort: DiscoveryParams.Sort) {
    self.viewModel.inputs.configureWith(sort: sort)
  }

  internal func change(filter filter: DiscoveryParams) {
    self.viewModel.inputs.selectedFilter(filter)
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.estimatedRowHeight = 400.0
    self.tableView.rowHeight = UITableViewAutomaticDimension
    self.tableView.dataSource = self.dataSource

    self.viewModel.inputs.viewDidLoad()
  }

  internal override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    self.viewModel.inputs.viewDidAppear()
  }

  override func viewDidDisappear(animated: Bool) {
    super.viewDidDisappear(animated)
    self.viewModel.inputs.viewDidDisappear()
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.projects
      .observeForUI()
      .observeNext { [weak self] projects in
        self?.dataSource.loadData(projects)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.goToProject
      .observeForUI()
      .observeNext { [weak self] in self?.goTo(project: $0, refTag: $1) }
  }

  internal override func tableView(tableView: UITableView,
                                   willDisplayCell cell: UITableViewCell,
                                   forRowAtIndexPath indexPath: NSIndexPath) {

    self.viewModel.inputs.willDisplayRow(self.dataSource.itemIndexAt(indexPath),
                                         outOf: self.dataSource.numberOfItems())
  }

  internal override func tableView(tableView: UITableView,
                                   didSelectRowAtIndexPath indexPath: NSIndexPath) {

    if let project = self.dataSource.projectAtIndexPath(indexPath) {
      self.viewModel.inputs.tapped(project: project)
    }
  }

  private func goTo(project project: Project, refTag: RefTag) {
    guard let projectViewController = UIStoryboard(name: "Project", bundle: nil)
      .instantiateInitialViewController() as? ProjectViewController else {
        fatalError("Couldn't instantiate project view controller.")
    }

    projectViewController.configureWith(project: project, refTag: refTag)
    let nav = UINavigationController(rootViewController: projectViewController)
    self.presentViewController(nav, animated: true, completion: nil)
  }
}
