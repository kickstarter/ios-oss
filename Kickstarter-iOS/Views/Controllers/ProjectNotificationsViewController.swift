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
    self.viewModel.inputs.viewDidLoad()
    self.view.backgroundColor = .ksr_grey_100
    self.tableView.dataSource = self.dataSource
  }

  override func bindStyles() {
    _ = self |> baseControllerStyle()
  }

  internal override func bindViewModel() {
    self.viewModel.outputs.projectNotifications
      .observeForControllerAction()
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
