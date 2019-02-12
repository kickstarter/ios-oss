import KsApi
import Library
import Prelude
import Prelude_UIKit
import SafariServices
import Result
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
    self.tableView.tableHeaderView?.backgroundColor = .ksr_grey_100

    self.viewModel.inputs.viewDidLoad()
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> UITableViewController.lens.view.backgroundColor .~ .ksr_grey_100
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

  internal override func tableView(_ tableView: UITableView,
                                   willDisplay cell: UITableViewCell,
                                   forRowAt indexPath: IndexPath) {
    if let followCell = cell as? SettingsFollowCell {
      followCell.delegate = self
    } else if let requestDataCell = cell as? SettingsPrivacyRequestDataCell {
      requestDataCell.delegate = self
    } else if let deleteAccountCell = cell as? SettingsPrivacyDeleteAccountCell {
      deleteAccountCell.delegate = self
    } else if let privacySwitchCell = cell as? SettingsPrivacySwitchCell {
      privacySwitchCell.delegate = self
    }
  }

  private func accessibilityFocusOnFollowingCell() {
    let cell = self.tableView.visibleCells.filter { $0 is SettingsFollowCell }.first
    if let cell = cell {
      UIAccessibility.post(notification: UIAccessibility.Notification.screenChanged, argument: cell)
    }
  }
}

extension SettingsPrivacyViewController: SettingsPrivacySwitchCellDelegate {
  func privacySettingsSwitchCell(_ cell: SettingsPrivacySwitchCell, didTogglePrivacySwitch on: Bool) {
    self.viewModel.inputs.privateProfileToggled(on: on)
  }
}

extension SettingsPrivacyViewController: SettingsFollowCellDelegate {
  internal func settingsFollowCellDidDisableFollowing(_ cell: SettingsFollowCell) {
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

extension SettingsPrivacyViewController: SettingsRequestDataCellDelegate {
  internal func settingsRequestDataCellDidPresentPrompt(_ cell: SettingsPrivacyRequestDataCell) {
    let exportDataSheet = UIAlertController(
      title: Strings.Request_my_personal_data(),
      message: Strings.It_may_take_up_to_24_hours_to_collect_your_data(),
      preferredStyle: .actionSheet)

    let startTheRequest = UIAlertAction(title: Strings.Start_the_request(),
                                        style: .default,
                                        handler: { _ in
        NotificationCenter.default.post(name: Notification.Name.ksr_dataRequested, object: nil, userInfo: nil)
      }
    )

    let dismiss = UIAlertAction(title: Strings.Cancel(), style: .cancel, handler: nil)

    exportDataSheet.addAction(startTheRequest)
    exportDataSheet.addAction(dismiss)

    self.present(exportDataSheet, animated: true, completion: nil)
  }

  internal func settingsRequestDataCell(_ cell: SettingsPrivacyRequestDataCell,
                                        requestedDataWith url: String) {
    guard let fileUrl = URL(string: url) else { return }
    UIApplication.shared.open(fileUrl)
  }
}

extension SettingsPrivacyViewController: SettingsPrivacyDeleteAccountCellDelegate {
  internal func settingsPrivacyDeleteAccountCellTapped(_ cell: SettingsPrivacyDeleteAccountCell,
                                                       with url: URL) {
    let controller = SFSafariViewController(url: url)
    controller.modalPresentationStyle = .overFullScreen
    self.present(controller, animated: true, completion: nil)
  }
}
