import KsApi
import Library
import UIKit

internal final class ProjectNotificationsViewController: UITableViewController {
  private let viewModel: ProjectNotificationsViewModelType = ProjectNotificationsViewModel()
  private let dataSource = ProjectNotificationsDataSource()

  internal static func instantiate() -> ProjectNotificationsViewController {
    return Storyboard.Settings.instantiate(ProjectNotificationsViewController)
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()
    self.viewModel.inputs.viewDidLoad()
    self.view.backgroundColor = .ksr_grey_100
    self.tableView.dataSource = self.dataSource
  }

  internal override func bindViewModel() {
    self.viewModel.outputs.projectNotifications
      .observeForControllerAction()
      .observeNext { [weak self] notifications in
        self?.dataSource.load(notifications: notifications)
        self?.tableView.reloadData()
    }
  }

  internal override func tableView(tableView: UITableView,
                                   willDisplayCell cell: UITableViewCell,
                                   forRowAtIndexPath indexPath: NSIndexPath) {
    if let cell = cell as? ProjectNotificationCell {
      cell.delegate = self
    }
  }
}

extension ProjectNotificationsViewController: ProjectNotificationCellDelegate {
  internal func projectNotificationCell(cell: ProjectNotificationCell?, notificationSaveError: String) {
    self.presentViewController(UIAlertController.genericError(notificationSaveError),
                               animated: true,
                               completion: nil
    )
  }
}
