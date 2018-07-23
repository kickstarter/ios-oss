import KsApi
import Library
import Prelude
import UIKit

internal final class SettingsPrivacyViewController: UITableViewController {
  internal let viewModel: SettingsPrivacyViewModelType = SettingsPrivacyViewModel()
  internal let cellViewModel: SettingsPrivacyCellViewModelType = SettingsPrivacyCellViewModel()
  fileprivate let dataSource = SettingsPrivacyDataSource()

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
      |> baseTableControllerStyle()
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

    self.viewModel.outputs.showFollowPrivacyAlert
      .observeForUI()
      .observeValues { [weak self] _ in
        self?.showPrivacyFollowingPrompt()
    }
  }

  func showPrivacyFollowingPrompt() {
    let followingAlert = UIAlertController.turnOffPrivacyFollowing(
      turnOnHandler: { [weak self] _ in
        self?.cellViewModel.inputs.followingSwitchTapped(on: true, didShowPrompt: true)
      },
      turnOffHandler: { [weak self] _ in
        self?.cellViewModel.inputs.followingSwitchTapped(on: false, didShowPrompt: true)
      }
    )
    self.present(followingAlert, animated: true, completion: nil)
  }

  public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell,
                                 forRowAt indexPath: IndexPath) {
    if let cell = cell as? SettingsPrivacyCell, cell.delegate == nil {
      cell.delegate = self
    }
  }
}

extension SettingsPrivacyViewController: SettingsPrivacyCellDelegate {
  func notifyDelegateShowFollowPrivacyPrompt() {
    self.viewModel.inputs.showPrivacyAlert()
  }
}
