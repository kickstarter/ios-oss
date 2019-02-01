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

    self.viewModel.outputs.transitionToViewController
      .observeForControllerAction()
      .observeValues { [weak self] (viewController) in
        self?.navigationController?.pushViewController(viewController, animated: true)
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

  private func showGeneralError() {
    self.messageBannerViewController?.showBanner(with: .error,
                                                 message: Strings.Something_went_wrong_please_try_again())
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
}

extension SettingsAccountViewController{
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
