import KsApi
import Library
import Prelude
import Prelude_UIKit
import SafariServices
import Result
import UIKit

public protocol SettingsPrivacyViewControllerDelegate: class {
  func notifyStartRequestDataTapped()
}

internal final class SettingsPrivacyViewController: UITableViewController {
  internal let viewModel: SettingsPrivacyViewModelType = SettingsPrivacyViewModel()
  fileprivate let dataSource = SettingsPrivacyDataSource()
  internal weak var delegate: SettingsPrivacyViewControllerDelegate?

  internal static func configureWith(user: User) -> SettingsPrivacyViewController {
    let vc = Storyboard.SettingsPrivacy.instantiate(SettingsPrivacyViewController.self)
    vc.viewModel.inputs.configureWith(user: user)
    return vc
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.dataSource = self.dataSource

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
        self?.dataSource.loadFollowCell(user: user)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.reloadData
      .observeForUI()
      .observeValues { [weak self] _ in
        self?.dataSource.loadFollowFooter()
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.reloadData
      .observeForUI()
      .observeValues { [weak self] user in
        self?.dataSource.loadRecommendationsCell(user: user)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.reloadData
      .observeForUI()
      .observeValues { [weak self] _ in
        self?.dataSource.loadRecommendationsFooter()
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.reloadData
      .observeForUI()
      .observeValues { [weak self] user in
        self?.dataSource.loadDownloadDataCell(user: user)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.reloadData
      .observeForUI()
      .observeValues { [weak self] _ in
        self?.dataSource.loadDownloadDataFooter()
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.reloadData
      .observeForUI()
      .observeValues { [weak self] user in
        self?.dataSource.loadDeleteAccountCell(user: user)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.updateCurrentUser // put in VC
      .observeForUI()
      .observeValues { [weak self] user in
        AppEnvironment.updateCurrentUser(user)
        self?.dataSource.loadFollowCell(user: user)
        self?.tableView.reloadData()
    }



  }

  internal override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell,
                                 forRowAt indexPath: IndexPath) {
    if let followCell = cell as? SettingsPrivacyCell {
      followCell.delegate = self
    } else if let requestDataCell = cell as? SettingsPrivacyRequestDataCell {
      requestDataCell.delegate = self
    } else if let deleteAccountCell = cell as? SettingsPrivacyDeleteAccountCell {
      deleteAccountCell.delegate = self
    }
  }
}

extension SettingsPrivacyViewController: SettingsPrivacyCellDelegate {
  func notifyDelegateShowFollowPrivacyPrompt() {
    let followingAlert = UIAlertController.turnOffPrivacyFollowing(
      turnOnHandler: { [weak self] _ in
        self?.cellViewModel.inputs.followingSwitchTapped(on: true, didShowPrompt: true) // fix this
      },
      turnOffHandler: { [weak self] _ in
        self?.cellViewModel.inputs.followingSwitchTapped(on: false, didShowPrompt: true) // and this
      }
    )
    self.present(followingAlert, animated: true, completion: nil)
  }
}

extension SettingsPrivacyViewController: SettingsRequestDataCellDelegate {
  func shouldPresentRequestDataPrompt() {
    let exportDataSheet = UIAlertController(
      title: Strings.Download_your_personal_data(),
      message: Strings.It_may_take_up_to_24_hours_to_collect_your_data(),
      preferredStyle: .actionSheet)

    let startTheRequest = UIAlertAction(title: Strings.Start_data_collection(),
                                        style: .default,
                                        handler: { _ in
        NotificationCenter.default.post(name: Notification.Name.ksr_dataRequested, object: nil, userInfo: nil)
      }
    )

    let dismiss = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

    exportDataSheet.addAction(startTheRequest)
    exportDataSheet.addAction(dismiss)

    self.present(exportDataSheet, animated: true, completion: nil)
  }

  func shouldRequestData(with url: String) {
    guard let fileUrl = URL(string: url) else { return }
    UIApplication.shared.openURL(fileUrl)
  }
}

extension SettingsPrivacyViewController: SettingsPrivacyDeleteAccountCellDelegate {
  internal func goToDeleteAccount(url: URL) {
    let controller = SFSafariViewController(url: url)
    controller.modalPresentationStyle = .overFullScreen
    self.present(controller, animated: true, completion: nil)
  }
}
