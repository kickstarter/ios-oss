import KsApi
import Library
import Prelude
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

    self |> baseTableControllerStyle(estimatedRowHeight: 300.0)
    self.tableView.dataSource = dataSource
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.activitiesAndProject
      .observeForUI()
      .observeNext { [weak self] activities, project in
        self?.dataSource.load(activities: activities, project: project)
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
