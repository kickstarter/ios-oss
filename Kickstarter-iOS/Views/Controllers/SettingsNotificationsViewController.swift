import KsApi
import Library
import Prelude
import UIKit

internal final class SettingsNotificationsViewController: UIViewController {
  @IBOutlet fileprivate weak var tableView: UITableView!

  private let viewModel: SettingsNotificationsViewModelType = SettingsNotificationsViewModel()
  private let dataSource: SettingsNotificationsDataSource = SettingsNotificationsDataSource()

  internal static func instantiate() -> SettingsNotificationsViewController {
    return Storyboard.SettingsNotifications.instantiate(SettingsNotificationsViewController.self)
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    dataSource.cellDelegate = self

    tableView.dataSource = dataSource
    tableView.delegate = self

    tableView.register(nib: .SettingsNotificationCell)
    tableView.registerHeaderFooter(nib: .SettingsHeaderView)

    self.viewModel.inputs.viewDidLoad()
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseControllerStyle()
      |> UIViewController.lens.title %~ { _ in Strings.profile_settings_navbar_title_notifications() }

    _ = self.tableView
      |> UITableView.lens.backgroundColor .~ .ksr_grey_200
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.unableToSaveError
      .observeForControllerAction()
      .observeValues { [weak self] message in
        self?.present(UIAlertController.genericError(message), animated: true, completion: nil)
    }

    self.viewModel.outputs.updateCurrentUser
      .observeForUI()
      .observeValues { [weak self] user in
        AppEnvironment.updateCurrentUser(user)

        self?.dataSource.load(user: user)

        self?.tableView.reloadData()
    }

    self.viewModel.outputs.goToFindFriends
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.goToFindFriends()
    }

    self.viewModel.outputs.goToEmailFrequency
      .observeForControllerAction()
      .observeValues { [weak self] user in
        self?.goToEmailFrequency(user: user)
    }

    self.viewModel.outputs.goToManageProjectNotifications
      .observeForControllerAction()
      .observeValues { [weak self] _ in self?.goToManageProjectNotifications() }
  }

  fileprivate func goToEmailFrequency(user: User) {
    let vc = CreatorDigestSettingsViewController.configureWith(user: user)
    self.navigationController?.pushViewController(vc, animated: true)
  }

  fileprivate func goToFindFriends() {
    let vc = FindFriendsViewController.configuredWith(source: .settings)
    self.navigationController?.pushViewController(vc, animated: true)
  }

  fileprivate func goToManageProjectNotifications() {
    let vc = ProjectNotificationsViewController.instantiate()
    self.navigationController?.pushViewController(vc, animated: true)
  }
}

extension SettingsNotificationsViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return SettingsNotificationSectionType.sectionHeaderHeight
  }

  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 0.1 // Required to remove the footer in UITableViewStyleGrouped
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    guard let sectionType = dataSource.sectionType(section: section,
                                                   user: AppEnvironment.current.currentUser) else {
      return nil
    }

    let headerView = tableView
      .dequeueReusableHeaderFooterView(withIdentifier: Nib.SettingsHeaderView.rawValue) as? SettingsHeaderView
    headerView?.configure(title: sectionType.sectionTitle)

    return headerView
  }

  func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
    guard let cellType = self.dataSource.cellTypeForIndexPath(indexPath: indexPath) else {
      return false
    }

    return self.viewModel.shouldSelectRow(for: cellType)
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)

    guard let cellType = dataSource.cellTypeForIndexPath(indexPath: indexPath) else {
      return
    }

    self.viewModel.inputs.didSelectRow(cellType: cellType)
  }
}

extension SettingsNotificationsViewController: SettingsNotificationCellDelegate {
  func didFailToSaveChange(errorMessage: String) {
    self.viewModel.inputs.failedToUpdateUser(error: errorMessage)
  }

  func didUpdateUser(user: User) {
    self.viewModel.inputs.updateUser(user: user)
  }
}
