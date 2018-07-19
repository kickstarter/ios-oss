import KsApi
import Library
import Prelude
import UIKit

internal final class SettingsPrivacyViewController: UITableViewController {
  internal let viewModel: SettingsPrivacyViewModelType = SettingsPrivacyViewModel()
  fileprivate let dataSource = SettingsPrivacyDataSource()

  internal static func configureWith(user: User) -> SettingsPrivacyViewController {
    let vc = Storyboard.SettingsPrivacy.instantiate(SettingsPrivacyViewController.self)
    vc.viewModel.inputs.configureWith(user: user)
    return vc
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.dataSource = self.dataSource

    self.viewModel.inputs.viewDidLoad()
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseControllerStyle()
      |> UIViewController.lens.title %~ { _ in Strings.Privacy() }
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.reloadData
      .observeForUI()
      .observeValues { [weak self] user in
        self?.dataSource.load(user: user)
        self?.tableView.reloadData()
    }
  }

  public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell,
                                 forRowAt indexPath: IndexPath) {
    if let cell = cell as? SettingsPrivacyCell, cell.delegate == nil {
      cell.delegate = self
    }
  }
}

extension SettingsPrivacyViewController: SettingsPrivacyCellDelegate {
  func goToDownloadData() {

  }

  func goToDeleteAccount() {

  }
}
