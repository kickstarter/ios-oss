import KsApi
import Library
import Prelude
import ReactiveSwift
import Result
import UIKit

final class SettingsAccountViewController: UIViewController, MessageBannerViewControllerPresenting {
  @IBOutlet private weak var tableView: UITableView!

  private let dataSource = SettingsAccountDataSource()
  internal var messageBannerViewController: MessageBannerViewController?

  fileprivate let viewModel: SettingsAccountViewModelType = SettingsAccountViewModel(
    SettingsAccountViewController.viewController(for:)
  )

  internal static func instantiate() -> SettingsAccountViewController {
    return Storyboard.Settings.instantiate(SettingsAccountViewController.self)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.dataSource = dataSource
    self.tableView.delegate = self

    self.messageBannerViewController = self.configureMessageBannerViewController(on: self)

    self.tableView.register(nib: .SettingsTableViewCell)
    self.tableView.register(nib: .SettingsCurrencyPickerCell)
    self.tableView.register(nib: .SettingsCurrencyCell)
    self.tableView.register(nib: .SettingsAccountWarningCell)
    self.tableView.registerHeaderFooter(nib: .SettingsHeaderView)

    self.viewModel.inputs.viewDidLoad()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.viewModel.inputs.viewWillAppear()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    self.viewModel.inputs.viewDidAppear()
  }

  override func bindViewModel() {
    self.viewModel.outputs.currencyUpdated
      .observeForControllerAction()
      .observeValues { _ in
        NotificationCenter.default.post(.init(name: .ksr_userLocalePreferencesChanged))
    }

    self.viewModel.outputs.reloadData
      .observeForUI()
      .observeValues { [weak self] currency, shouldHideEmailWarning, shouldHideEmailPasswordSection in
        self?.dataSource.configureRows(currency: currency,
                                       shouldHideEmailWarning: shouldHideEmailWarning,
                                       shouldHideEmailPasswordSection: shouldHideEmailPasswordSection)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.fetchAccountFieldsError
      .observeForUI()
      .observeValues { [weak self] in
        self?.dataSource.configureRows(currency: nil,
                                       shouldHideEmailWarning: true,
                                       shouldHideEmailPasswordSection: false)
        self?.tableView.reloadData()

        self?.showGeneralError()
    }

    self.viewModel.outputs.presentCurrencyPicker
      .observeForUI()
      .observeValues { [weak self] currency in
        self?.showCurrencyPickerCell(with: currency)
    }

    self.viewModel.outputs.updateCurrencyFailure
      .observeForControllerAction()
      .observeValues { [weak self] errorMessage in
          self?.present(UIAlertController.genericError(errorMessage),
                        animated: true, completion: nil)
    }

    self.viewModel.outputs.dismissCurrencyPicker
      .observeForUI()
      .observeValues { [weak self] in
        self?.dismissCurrencyPickerCell()
    }

    self.viewModel.outputs.transitionToViewController
      .observeForControllerAction()
      .observeValues { [weak self] (viewController) in
        self?.navigationController?.pushViewController(viewController, animated: true)
    }

    self.viewModel.outputs.showAlert
      .observeForUI()
      .observeValues { [weak self] _ in
        self?.showChangeCurrencyAlert()
    }
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> settingsViewControllerStyle
      |> UIViewController.lens.title %~ { _ in Strings.Account() }

    _ = tableView
      |> settingsTableViewStyle
  }

  private func showCurrencyPickerCell(with currency: Currency) {
    let tapRecognizer = UITapGestureRecognizer(
      target: self,
      action: #selector(tapGestureToDismissCurrencyPicker)
    )

    self.tableView.beginUpdates()
    if let indexPath = self.dataSource.insertCurrencyPickerRow(with: currency) {
      self.tableView.insertRows(at: [indexPath], with: .top)
    }
    self.view.addGestureRecognizer(tapRecognizer)
    self.tableView.endUpdates()
  }

  private func showGeneralError() {
    self.messageBannerViewController?.showBanner(with: .error,
                                                 message: Strings.Something_went_wrong_please_try_again())
  }

  private func dismissCurrencyPickerCell() {
    guard let pickerCellIndexPath = self.dataSource.removeCurrencyPickerRow() else {
      return
    }

    tableView.beginUpdates()
    self.tableView.deleteRows(at: [pickerCellIndexPath], with: .top)
    self.view.gestureRecognizers?.removeAll()
    self.tableView.endUpdates()
  }

  private func showChangeCurrencyAlert() {
    let alertController = UIAlertController(
      title: Strings.Change_currency(),
      message: """
      \(Strings.This_allows_you_to_see_project_goal_and_pledge_amounts_in_your_preferred_currency()) \n
      \(Strings.A_successfully_funded_project_will_collect_your_pledge_in_its_native_currency())
      """,
      preferredStyle: .alert
    )

    alertController.addAction(
      UIAlertAction(
        title: Strings.Yes_change_currency(),
        style: .default,
        handler: { [weak self] _ in
          self?.viewModel.inputs.didConfirmChangeCurrency()
        }
      )
    )

    alertController.addAction(
      UIAlertAction(
        title: Strings.Cancel(),
        style: .cancel,
        handler: nil
      )
    )

    self.present(alertController, animated: true, completion: nil)
  }

  @objc private func tapGestureToDismissCurrencyPicker() {
    self.viewModel.inputs.dismissPickerTap()
  }
}

extension SettingsAccountViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)

    guard let cellType = dataSource.cellTypeForIndexPath(indexPath: indexPath) else {
      return
    }
    self.viewModel.inputs.didSelectRow(cellType: cellType)
  }

  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return SettingsSectionType.sectionHeaderHeight
  }

  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 0.1
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    return tableView.dequeueReusableHeaderFooterView(withIdentifier: Nib.SettingsHeaderView.rawValue)
  }

  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if let cell = cell as? SettingsCurrencyPickerCell {
      cell.delegate = self
    }
  }
}

extension SettingsAccountViewController: SettingsCurrencyPickerCellDelegate {
  func settingsCurrencyPickerCellDidChangeCurrency(_ currency: Currency) {
    self.viewModel.inputs.showChangeCurrencyAlert(for: currency)
    self.dismissCurrencyPickerCell()
  }

  static func viewController(for cellType: SettingsAccountCellType) -> UIViewController? {
    switch cellType {
    case .changeEmail:
      return ChangeEmailViewController.instantiate()
    case .changePassword:
      return ChangePasswordViewController.instantiate()
    case .privacy:
      return SettingsPrivacyViewController.instantiate()
    default:
      return nil
    }
  }
}
