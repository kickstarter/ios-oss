import Foundation
import UIKit
import Library
import KsApi

internal final class DiscoveryViewController: UITableViewController {
  let viewModel: DiscoveryViewModelType = DiscoveryViewModel()
  let dataSource = DiscoveryProjectsDataSource()

  override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.estimatedRowHeight = 400.0
    self.tableView.rowHeight = UITableViewAutomaticDimension
    self.tableView.dataSource = dataSource

    self.viewModel.inputs.viewDidLoad()
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.projects
      .observeForUI()
      .observeNext { [weak self] projects in
        self?.dataSource.loadData(projects)
        self?.tableView.reloadData()
    }
  }

  override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 32.0
  }

  override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let view = UIView()
    view.backgroundColor = .clearColor()
    return view
  }

  override func tableView(tableView: UITableView,
                          willDisplayCell cell: UITableViewCell,
                          forRowAtIndexPath indexPath: NSIndexPath) {

    self.viewModel.inputs.willDisplayRow(self.dataSource.itemIndexAt(indexPath),
                                         outOf: self.dataSource.numberOfItems())
  }

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    guard let project = self.dataSource.projectAtIndexPath(indexPath) else {
      return
    }
    guard let projectViewController = UIStoryboard(name: "Project", bundle: nil)
      .instantiateInitialViewController() as? ProjectViewController else {
        fatalError("Couldn't instantiate project view controller.")
    }

    projectViewController.configureWith(project: project, refTag: nil)
    let nav = UINavigationController(rootViewController: projectViewController)
    self.presentViewController(nav, animated: true, completion: nil)
  }
}
