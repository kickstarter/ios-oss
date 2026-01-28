import KsApi
import Library
import Prelude
import UIKit

internal final class SettingsNotificationsViewController: UIViewController {
  @IBOutlet fileprivate var tableView: UITableView!
  @IBOutlet fileprivate var emailFrequencyPickerView: UIPickerView!
  @IBOutlet fileprivate var emailPickerViewTopConstraint: NSLayoutConstraint!

  private let viewModel: SettingsNotificationsViewModelType = SettingsNotificationsViewModel()
  private let dataSource: SettingsNotificationsDataSource = SettingsNotificationsDataSource()

  internal static func instantiate() -> SettingsNotificationsViewController {
    return Storyboard.SettingsNotifications.instantiate(SettingsNotificationsViewController.self)
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.dataSource.cellDelegate = self

    self.tableView.dataSource = self.dataSource
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
      |> settingsTableViewStyle
      |> settingsTableViewSeparatorStyle

    _ = self.emailFrequencyPickerView
      |> \.isAccessibilityElement .~ true
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.pickerViewIsHidden
      .observeForUI()
      .observeValues { [weak self] isHidden in
        self?.animatePickerView(isHidden: isHidden)
      }

    self.viewModel.outputs.pickerViewSelectedRow
      .observeForUI()
      .observeValues { [weak self] emailFrequency in
        self?.emailFrequencyPickerView.selectRow(
          emailFrequency.rawValue,
          inComponent: 0,
          animated: false
        )
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

    self.viewModel.outputs.goToManageProjectNotifications
      .observeForControllerAction()
      .observeValues { [weak self] _ in self?.goToManageProjectNotifications() }
  }

  fileprivate func goToManageProjectNotifications() {
    let vc = ProjectNotificationsViewController.instantiate()
    self.navigationController?.pushViewController(vc, animated: true)
  }

  @objc private func tapGestureToDismissEmailFrequencyPicker() {
    self.viewModel.inputs.dismissPickerTap()
  }

  private func animatePickerView(isHidden: Bool) {
    let tapRecognizer = UITapGestureRecognizer(
      target: self,
      action: #selector(self.tapGestureToDismissEmailFrequencyPicker)
    )

    UIView.animate(
      withDuration: 0.25,
      animations: { [weak self] in
        guard let self = self else { return }

        if !isHidden {
          self.view.addGestureRecognizer(tapRecognizer)
        }

        if isHidden {
          self.view.gestureRecognizers?.removeAll()
        }

        if !isHidden, AppEnvironment.current.isVoiceOverRunning() {
          // Tells VoiceOver to ignore other elements in the same parent view
          self.emailFrequencyPickerView.accessibilityViewIsModal = true

          UIAccessibility.post(
            notification: UIAccessibility.Notification.screenChanged,
            argument: self.emailFrequencyPickerView
          )
        }

        self.emailPickerViewTopConstraint.constant = isHidden ? 0 : self.emailFrequencyPickerView.frame.height
        self.view.layoutIfNeeded()
      },
      completion: { [weak self] _ in
        if isHidden, AppEnvironment.current.isVoiceOverRunning() {
          // Tells VoiceOver to re-enable focus on other elements in the same parent view
          self?.emailFrequencyPickerView.accessibilityViewIsModal = false

          UIAccessibility.post(
            notification: UIAccessibility.Notification.screenChanged,
            argument: self?.emailFrequencyPickerView
          )
        }
      }
    )
  }
}

extension SettingsNotificationsViewController: UITableViewDelegate {
  func tableView(_: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    guard let sectionType = dataSource.sectionType(
      section: section,
      user: AppEnvironment.current.currentUser
    ) else {
      return 0.0
    }

    return sectionType.sectionHeaderHeight
  }

  func tableView(_: UITableView, heightForFooterInSection _: Int) -> CGFloat {
    return 0.1 // Required to remove footer in table view of type "Grouped"
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    guard let sectionType = dataSource.sectionType(
      section: section,
      user: AppEnvironment.current.currentUser
    ) else {
      return nil
    }

    let headerView = tableView
      .dequeueReusableHeaderFooterView(withIdentifier: Nib.SettingsHeaderView.rawValue) as? SettingsHeaderView
    headerView?.configure(title: sectionType.sectionTitle)

    return headerView
  }

  func tableView(_: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
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

// MARK: - SettingsNotificationCellDelegate

extension SettingsNotificationsViewController: SettingsNotificationCellDelegate {
  func settingsNotificationCell(_: SettingsNotificationCell, didFailToUpdateUser errorMessage: String) {
    self.viewModel.inputs.failedToUpdateUser(error: errorMessage)
  }

  func settingsNotificationCell(_: SettingsNotificationCell, didUpdateUser user: User) {
    self.viewModel.inputs.updateUser(user: user)
  }
}

// MARK: - UIPickerViewDataSource & UIPickerViewDelegate

extension SettingsNotificationsViewController: UIPickerViewDataSource {
  func numberOfComponents(in _: UIPickerView) -> Int {
    return 1
  }

  func pickerView(_: UIPickerView, numberOfRowsInComponent _: Int) -> Int {
    return EmailFrequency.allCases.count
  }
}

extension SettingsNotificationsViewController: UIPickerViewDelegate {
  func pickerView(_: UIPickerView, titleForRow row: Int, forComponent _: Int) -> String? {
    return EmailFrequency(rawValue: row)?.descriptionText
  }

  func pickerView(_: UIPickerView, didSelectRow row: Int, inComponent _: Int) {
    guard let selectedEmailFrequency = EmailFrequency(rawValue: row) else {
      return
    }

    self.viewModel.inputs.didSelectEmailFrequency(frequency: selectedEmailFrequency)
  }

  func pickerView(_: UIPickerView, rowHeightForComponent _: Int) -> CGFloat {
    return EmailFrequency.rowHeight
  }
}
