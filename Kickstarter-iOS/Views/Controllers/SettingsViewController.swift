import Library
import KsApi
import Prelude
import ReactiveSwift
import Result

final class SettingsViewController: UIViewController {
  @IBOutlet fileprivate weak var tableView: UITableView!

  private let dataSource = SettingsDataSource()
  private var userUpdatedObserver: Any?
  private let viewModel: SettingsViewModelType = SettingsViewModel(
    SettingsViewController.viewController(for:)
  )

  internal static func instantiate() -> SettingsViewController {
    return Storyboard.Settings.instantiate(SettingsViewController.self)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.dataSource = dataSource
    self.tableView.delegate = self

    self.tableView.register(nib: .SettingsTableViewCell)
    self.tableView.register(nib: .FindFriendsCell)
    self.tableView.registerHeaderFooter(nib: .SettingsFooterView)
    self.tableView.registerHeaderFooter(nib: .SettingsHeaderView)

    if self.presentingViewController != nil {
      self.navigationItem.leftBarButtonItem = self.leftBarButtonItem()
    }

    self.userUpdatedObserver = NotificationCenter.default
      .addObserver(forName: Notification.Name.ksr_userUpdated,
                   object: nil, queue: nil) { [weak self] _ in
                    self?.viewModel.inputs.currentUserUpdated()
    }

    self.viewModel.inputs.viewDidLoad()
  }

  deinit {
    self.userUpdatedObserver.doIfSome(NotificationCenter.default.removeObserver)
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> settingsViewControllerStyle
      |> UIViewController.lens.title %~ { _ in Strings.profile_buttons_settings() }

    _ = tableView
      |> settingsTableViewStyle
  }

  override func bindViewModel() {
    self.viewModel.outputs.reloadDataWithUser
      .observeForUI()
      .observeValues { [weak self] user in
        self?.dataSource.configureRows(with: user)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.transitionToViewController
      .observeForControllerAction()
      .observeValues { [weak self] viewController in
        self?.navigationController?.pushViewController(viewController, animated: true)
    }

    self.viewModel.outputs.showConfirmLogoutPrompt
      .observeForControllerAction()
      .observeValues { [weak self] (message, cancel, confirm) in
        self?.showLogoutPrompt(message: message, cancel: cancel, confirm: confirm)
    }

    self.viewModel.outputs.logoutWithParams
      .observeForControllerAction()
      .observeValues { [weak self] in self?.logout(params: $0) }

    self.viewModel.outputs.goToAppStoreRating
      .observeForControllerAction()
      .observeValues { [weak self] link in self?.goToAppStore(link: link) }
  }

  private func leftBarButtonItem() -> UIBarButtonItem {
    return UIBarButtonItem(
      image: UIImage(named: "icon--cross"),
      style: .plain,
      target: self,
      action: #selector(closeButtonPressed)
    )
    |> \.accessibilityLabel %~ { _ in Strings.Dismiss() }
    |> \.width .~ 44
  }

  @objc fileprivate func closeButtonPressed() {
    self.dismiss(animated: true, completion: nil)
  }

  private func logout(params: DiscoveryParams) {
    AppEnvironment.logout()
    PushNotificationDialog.resetAllContexts()

    self.view.window?.rootViewController
      .flatMap { $0 as? RootTabBarViewController }
      .doIfSome { root in
        UIView.transition(with: root.view, duration: 0.3, options: [.transitionCrossDissolve], animations: {
          root.switchToDiscovery(params: params)
        }, completion: { [weak self] _ in
          NotificationCenter.default.post(.init(name: .ksr_sessionEnded))

          self?.dismiss(animated: false, completion: nil)
        })
    }
  }

  private func goToAppStore(link: String) {
    guard let url = URL(string: link) else { return }
    UIApplication.shared.open(url)
  }

  private func showLogoutPrompt(message: String, cancel: String, confirm: String) {
    let logoutAlert = UIAlertController(title: nil, message: message, preferredStyle: .alert)

    logoutAlert.addAction(
      UIAlertAction(
        title: cancel,
        style: .cancel,
        handler: { [weak self] _ in
          self?.viewModel.inputs.logoutCanceled()
        }
      )
    )

    logoutAlert.addAction(
      UIAlertAction(
        title: confirm,
        style: .default,
        handler: { [weak self] _ in
          self?.viewModel.inputs.logoutConfirmed()
        }
      )
    )

    self.present(logoutAlert, animated: true, completion: nil)
  }
}

extension SettingsViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return SettingsSectionType.sectionHeaderHeight
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    return tableView.dequeueReusableHeaderFooterView(withIdentifier: Nib.SettingsHeaderView.rawValue)
  }

  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    guard section == SettingsSectionType.ratingAppVersion.rawValue else { return 0.1 }

    return UITableView.automaticDimension
  }

  func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
    return 44
  }

  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    guard section == SettingsSectionType.ratingAppVersion.rawValue else { return nil }

    let footerView = tableView.dequeueReusableHeaderFooterView(
      withIdentifier: Nib.SettingsFooterView.rawValue
    ) as? SettingsFooterView

    footerView?.configure(with: "\(Strings.App_version()) \(AppEnvironment.appVersionString)")

    return footerView
  }

  func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
    guard let cellType = dataSource.cellTypeForIndexPath(indexPath: indexPath) else {
      return false
    }

    return self.viewModel.shouldSelectRow(for: cellType)
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)

    guard let cellType = dataSource.cellTypeForIndexPath(indexPath: indexPath) else {
      return
    }

    self.viewModel.inputs.settingsCellTapped(cellType: cellType)
  }
}

extension SettingsViewController {
  static func viewController(for cellType: SettingsCellType) -> UIViewController? {
    switch cellType {
    case .account:
      return SettingsAccountViewController.instantiate()
    case .help:
      return HelpViewController.instantiate()
    case .findFriends:
      return FindFriendsViewController.configuredWith(source: .settings)
    case .newsletters:
      return SettingsNewslettersViewController.instantiate()
    case .notifications:
      return SettingsNotificationsViewController.instantiate()
    default:
      return nil
    }
  }
}
