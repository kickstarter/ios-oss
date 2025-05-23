import KsApi
import Library
import Prelude
import Prelude_UIKit
import SafariServices
import UIKit

internal final class SettingsPrivacyViewController: UITableViewController {
  internal let viewModel: SettingsPrivacyViewModelType = SettingsPrivacyViewModel()
  fileprivate let dataSource = SettingsPrivacyDataSource()

  internal static func instantiate() -> SettingsPrivacyViewController {
    return Storyboard.SettingsPrivacy.instantiate(SettingsPrivacyViewController.self)
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.dataSource = self.dataSource

    self.tableView.register(nib: Nib.SettingsPrivacySwitchCell)

    self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: Styles.grid(4)))
    self.tableView.tableHeaderView?.backgroundColor = LegacyColors.ksr_support_100.uiColor()

    self.viewModel.inputs.viewDidLoad()
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> UITableViewController.lens.view.backgroundColor .~ LegacyColors.ksr_support_100.uiColor()
      |> UITableViewController.lens.title %~ { _ in Strings.Privacy() }
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.reloadData
      .observeForUI()
      .observeValues { [weak self] user in
        self?.dataSource.load(user: user)
        self?.tableView.reloadData()
      }

    self.viewModel.outputs.updateCurrentUser
      .observeForUI()
      .observeValues { [weak self] user in
        AppEnvironment.updateCurrentUser(user)
        NotificationCenter.default.post(Notification(name: .ksr_userUpdated))
        self?.dataSource.load(user: user)
      }

    self.viewModel.outputs.unableToSaveError
      .observeForControllerAction()
      .observeValues { [weak self] message in
        self?.present(UIAlertController.genericError(message), animated: true, completion: nil)
      }

    self.viewModel.outputs.resetFollowingSection
      .observeForUI()
      .observeValues { [weak self] _ in
        let indexPath = IndexPath(row: 0, section: Section.following.rawValue)
        let cell = self?.tableView.cellForRow(at: indexPath) as? SettingsFollowCell
        cell?.toggleOn()
      }

    self.viewModel.outputs.focusScreenReaderOnFollowingCell
      .observeForUI()
      .observeValues { [weak self] _ in
        self?.accessibilityFocusOnFollowingCell()
      }
  }

  internal override func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt _: IndexPath) {
    if let followCell = cell as? SettingsFollowCell {
      followCell.delegate = self
    } else if let deleteAccountCell = cell as? SettingsPrivacyDeleteOrRequestCell {
      deleteAccountCell.delegate = self
    } else if let privacySwitchCell = cell as? SettingsPrivacySwitchCell {
      privacySwitchCell.delegate = self
    }
  }

  private func accessibilityFocusOnFollowingCell() {
    let cell = self.tableView.visibleCells.first { $0 is SettingsFollowCell }
    if let cell = cell {
      UIAccessibility.post(notification: UIAccessibility.Notification.screenChanged, argument: cell)
    }
  }
}

extension SettingsPrivacyViewController: SettingsPrivacySwitchCellDelegate {
  func privacySettingsSwitchCell(_: SettingsPrivacySwitchCell, didTogglePrivacySwitch on: Bool) {
    self.viewModel.inputs.privateProfileToggled(on: on)
  }
}

extension SettingsPrivacyViewController: SettingsFollowCellDelegate {
  internal func settingsFollowCellDidDisableFollowing(_: SettingsFollowCell) {
    let followingAlert = UIAlertController.turnOffPrivacyFollowing(
      cancelHandler: { [weak self] _ in
        self?.viewModel.inputs.didCancelSocialOptOut()
      },
      turnOffHandler: { [weak self] _ in
        self?.viewModel.inputs.didConfirmSocialOptOut()
      }
    )
    self.present(followingAlert, animated: true, completion: nil)
  }

  internal func settingsFollowCellDidUpdate(user: User) {
    self.viewModel.inputs.didUpdate(user: user)
  }
}

extension SettingsPrivacyViewController: SettingsPrivacyDeleteOrRequestCellDelegate {
  internal func settingsPrivacyDeleteOrRequestCellTapped(
    _: SettingsPrivacyDeleteOrRequestCell,
    with url: URL
  ) {
    self.goTo(url: url)
  }
}
