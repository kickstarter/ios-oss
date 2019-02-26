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
    SettingsAccountViewController.viewController(for:currency:)
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
    self.tableView.register(nib: .SettingsAccountWarningCell)
    self.tableView.registerHeaderFooter(nib: .SettingsHeaderView)
    self.tableView.registerHeaderFooterClass(SettingsGroupedFooterView.self)
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
    let (userHasPassword, _) = self.viewModel.outputs.userHasPasswordAndEmail
    guard section == SettingsAccountSectionType.createPassword.rawValue, !userHasPassword else {
      return 0.1
    }
    return Styles.grid(10)
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    return tableView.dequeueReusableHeaderFooterView(withIdentifier: Nib.SettingsHeaderView.rawValue)
  }

  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    let (userHasPassword, email) = self.viewModel.outputs.userHasPasswordAndEmail
    guard let userEmail = email,
      !userHasPassword,
      section == SettingsAccountSectionType.createPassword.rawValue else {
        return nil
    }

    let footerView = tableView.dequeueReusableHeaderFooterView(
      withClass: SettingsGroupedFooterView.self) as? SettingsGroupedFooterView
    footerView?.configure(with:
      Strings.Youre_connected_via_Facebook_email_Create_a_password_for_this_account(email: userEmail)
    )
    return footerView
  }
}

extension SettingsAccountViewController {
  static func viewController(for cellType: SettingsAccountCellType, currency: Currency) -> UIViewController? {
    switch cellType {
    case .changeEmail:
      return ChangeEmailViewController.instantiate()
    case .changePassword:
      return ChangePasswordViewController.instantiate()
    case .paymentMethods:
      return PaymentMethodsViewController.instantiate()
    case .privacy:
      return SettingsPrivacyViewController.instantiate()
    case .currency:
      let vc = SelectCurrencyViewController.instantiate()
      vc.configure(with: currency)
      return vc
    default:
      return nil
    }
  }
}
