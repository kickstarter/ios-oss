import Library
import KsApi
import Prelude
import ReactiveSwift
import Result

final class SettingsV2ViewController: UIViewController {
  @IBOutlet fileprivate weak var tableView: UITableView!

  private let dataSource = SettingsDataSource()
  private let viewModel: SettingsV2ViewModelType = SettingsV2ViewModel()

  internal static func instantiate() -> SettingsV2ViewController {
    return Storyboard.SettingsV2.instantiate(SettingsV2ViewController.self)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.dataSource = dataSource
    tableView.delegate = self

    tableView.register(nib: .SettingsTableViewCell)
    tableView.registerHeaderFooter(nib: .SettingsHeaderView)

    self.viewModel.inputs.viewDidLoad()
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseControllerStyle()
      |> UIViewController.lens.view.backgroundColor .~ .ksr_grey_200
      |> UIViewController.lens.title %~ { _ in Strings.profile_buttons_settings() }

    _ = tableView
      |> UITableView.lens.backgroundColor .~ .ksr_grey_200
  }

  override func bindViewModel() {
    self.viewModel.outputs.reloadData
      .observeForUI()
      .observeValues { [weak self] in
        self?.dataSource.configureRows()
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

  private func logout(params: DiscoveryParams) {
    AppEnvironment.logout()

    self.view.window?.rootViewController
      .flatMap { $0 as? RootTabBarViewController }
      .doIfSome { root in
        UIView.transition(with: root.view, duration: 0.3, options: [.transitionCrossDissolve], animations: {
          root.switchToDiscovery(params: params)
        }, completion: { _ in
          NotificationCenter.default.post(.init(name: .ksr_sessionEnded))
        })
    }
  }

  private func goToAppStore(link: String) {
    guard let url = URL(string: link) else { return }
    UIApplication.shared.openURL(url)
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

extension SettingsV2ViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return SettingsSectionType.sectionHeaderHeight
  }

  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 0.1 // Required to remove the footer in UITableViewStyleGrouped
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    return tableView.dequeueReusableHeaderFooterView(withIdentifier: Nib.SettingsHeaderView.rawValue)
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
