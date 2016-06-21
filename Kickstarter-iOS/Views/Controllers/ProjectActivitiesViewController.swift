import KsApi
import Library
import UIKit

internal final class ProjectActivitiesViewController: UITableViewController {
  private let viewModel: ProjectActivitiesViewModelType = ProjectActivitiesViewModel()
  private let dataSource = ProjectActivitiesDataSource()

  internal func configureWith(project project: Project) {
    self.viewModel.inputs.configureWith(project)
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.viewModel.inputs.viewDidLoad()

    self.tableView.estimatedRowHeight = 300.0
    self.tableView.rowHeight = UITableViewAutomaticDimension
    self.tableView.dataSource = dataSource
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.activities
      .observeForUI()
      .observeNext { [weak self] activities in
        self?.dataSource.load(activities: activities)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.showEmptyState
      .observeForUI()
      .observeNext { [weak self] visible in
        self?.dataSource.emptyState(visible: visible)
        self?.tableView.reloadData()
    }
  }

  internal override func tableView(tableView: UITableView,
                                   willDisplayCell cell: UITableViewCell,
                                   forRowAtIndexPath indexPath: NSIndexPath) {

    self.viewModel.inputs.willDisplayRow(self.dataSource.itemIndexAt(indexPath),
                                         outOf: self.dataSource.numberOfItems())
  }
}
