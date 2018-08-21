import KsApi
import Library
import Prelude
import UIKit

internal final class ProjectNotificationsViewController: UITableViewController {
  fileprivate let viewModel: ProjectNotificationsViewModelType = ProjectNotificationsViewModel()
  fileprivate let dataSource = ProjectNotificationsDataSource()

  internal static func instantiate() -> ProjectNotificationsViewController {
    return Storyboard.Settings.instantiate(ProjectNotificationsViewController.self)
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.dataSource = self.dataSource

    self.viewModel.inputs.viewDidLoad()
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseControllerStyle()
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.projectNotifications
      .observeForUI()
      .observeValues { [weak self] notifications in
        self?.dataSource.load(notifications: notifications)
        self?.tableView.reloadData()
    }
  }

  internal override func tableView(_ tableView: UITableView,
                                   willDisplay cell: UITableViewCell,
                                   forRowAt indexPath: IndexPath) {
    if let cell = cell as? ProjectNotificationCell {
      cell.delegate = self
    }
  }
}

extension ProjectNotificationsViewController: ProjectNotificationCellDelegate {
  internal func projectNotificationCell(_ cell: ProjectNotificationCell?, notificationSaveError: String) {
    self.present(UIAlertController.genericError(notificationSaveError),
                               animated: true,
                               completion: nil
    )
  }
}
