import KsApi
import Library
import Prelude
import UIKit

internal final class SettingsNotificationsViewController: UIViewController {
  @IBOutlet fileprivate weak var tableView: UITableView!
  @IBOutlet fileprivate weak var emailFrequencyPickerView: UIPickerView!
  @IBOutlet fileprivate weak var emailPickerViewTopConstraint: NSLayoutConstraint!

  private static let emailPickerViewHeight: CGFloat = 200.0

  private let viewModel: SettingsNotificationsViewModelType = SettingsNotificationsViewModel()
  private let dataSource: SettingsNotificationsDataSource = SettingsNotificationsDataSource()

  internal static func instantiate() -> SettingsNotificationsViewController {
    return Storyboard.SettingsNotifications.instantiate(SettingsNotificationsViewController.self)
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.dataSource.cellDelegate = self

    self.tableView.dataSource = dataSource
    self.tableView.delegate = self

    self.emailFrequencyPickerView.delegate = self
    self.emailFrequencyPickerView.dataSource = self

    self.tableView.register(nib: .SettingsNotificationCell)
    self.tableView.register(nib: .SettingsNotificationPickerCell)
    self.tableView.registerHeaderFooter(nib: .SettingsHeaderView)

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

    self.viewModel.outputs.pickerViewIsHidden
      .observeForUI()
      .observeValues { [weak self] (isHidden) in
        self?.animatePickerView(isHidden: isHidden)
    }

    self.viewModel.outputs.pickerViewSelectedRow
      .observeForUI()
      .observeValues { [weak self] (emailFrequency) in
        self?.emailFrequencyPickerView.selectRow(emailFrequency.rawValue,
                                                 inComponent: 0,
                                                 animated: false)
    }

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

  private func animatePickerView(isHidden: Bool) {
    UIView.animate(withDuration: 0.25) {
      self.emailPickerViewTopConstraint.constant = isHidden
        ? 0 : -SettingsNotificationsViewController.emailPickerViewHeight

      self.view.setNeedsLayout()
      self.view.layoutIfNeeded()
    }
  }
}

extension SettingsNotificationsViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    guard let sectionType = dataSource.sectionType(section: section,
                                                   user: AppEnvironment.current.currentUser) else {
                                                    return 0.0
    }

    return sectionType.sectionHeaderHeight
  }

  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 0.1 // Required to remove footer in table view of type "Grouped"
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

// MARK: SettingsNotificationCellDelegate
extension SettingsNotificationsViewController: SettingsNotificationCellDelegate {
  func settingsNotificationCell(_ cell: SettingsNotificationCell, didFailToUpdateUser errorMessage: String) {
    self.viewModel.inputs.failedToUpdateUser(error: errorMessage)
  }

  func settingsNotificationCell(_ cell: SettingsNotificationCell, didUpdateUser user: User) {
    self.viewModel.inputs.updateUser(user: user)
  }
}

// MARK: SettingsNotificationPickerCellDelegate
extension SettingsNotificationsViewController: SettingsNotificationPickerCellDelegate {
  func settingsNotificationPickerCellDidTapFrequencyPickerButton(_ cell: SettingsNotificationPickerCell) {
    self.viewModel.inputs.didTapFrequencyPickerButton()
  }
}

// MARK: UIPickerViewDataSource & UIPickerViewDelegate
extension SettingsNotificationsViewController: UIPickerViewDataSource {
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }

  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return EmailFrequency.allCases.count
  }
}

extension SettingsNotificationsViewController: UIPickerViewDelegate {
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return EmailFrequency(rawValue: row)?.descriptionText
  }

  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    guard let selectedEmailFrequency = EmailFrequency(rawValue: row) else {
      return
    }

    self.viewModel.inputs.didSelectEmailFrequency(frequency: selectedEmailFrequency)
  }

  func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
    return EmailFrequency.rowHeight
  }
}
