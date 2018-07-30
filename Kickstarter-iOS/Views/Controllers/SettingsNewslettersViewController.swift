import KsApi
import Library
import Prelude
import UIKit

internal final class SettingsNewslettersViewController: UIViewController {

  fileprivate let dataSource = SettingsNewslettersDataSource()
  fileprivate let viewModel: SettingsNewslettersViewModelType = SettingsNewslettersViewModel()

  @IBOutlet fileprivate weak var tableView: UITableView!

  internal static func instantiate() -> SettingsNewslettersViewController {
    return Storyboard.SettingsNewsletters.instantiate(SettingsNewslettersViewController.self)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.viewModel.inputs.viewDidLoad()

    self.tableView.register(nib: .SettingsNewslettersTopCell)
    self.tableView.register(nib: .SettingsNewslettersCell)
    self.tableView.dataSource = dataSource
    self.tableView.delegate = self
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self.tableView
      |> UITableView.lens.separatorStyle .~ .none
      |> UITableView.lens.estimatedRowHeight .~ 127
      |> UITableView.lens.allowsSelection .~ false

    self.title = Strings.Newsletters()
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.currentUser
      .observeForUI()
      .observeValues { [weak self] user in
        AppEnvironment.updateCurrentUser(user)
        self?.dataSource.load(newsletters: Newsletter.allCases, user: user)
        if let indexes = self?.tableView.indexPathsForVisibleRows {
          self?.tableView.reloadRows(at: indexes, with: .none)
        }
    }
  }
}

extension SettingsNewslettersViewController: UITableViewDelegate {

  internal func tableView(_ tableView: UITableView,
                          willDisplay cell: UITableViewCell,
                          forRowAt indexPath: IndexPath) {

    if let cell = cell as? SettingsNewslettersTopCell, cell.delegate == nil {
      cell.delegate = self
    } else if let cell = cell as? SettingsNewslettersCell, cell.delegate == nil {
      cell.delegate = self
    }
  }
}

extension SettingsNewslettersViewController: SettingsNewslettersCellDelegate {

  func didUpdate(user: User) {
    self.viewModel.inputs.didUpdate(user: user)
  }

  func shouldShowOptInAlert(_ newsletterName: String) {
    let optInAlert = UIAlertController.newsletterOptIn(newsletterName)
    self.present(optInAlert, animated: true, completion: nil)
  }
}

extension SettingsNewslettersViewController: SettingsNewslettersTopCellDelegate {

  func didUpdateAllNewsletters(user: User) {
    self.viewModel.inputs.didUpdate(user: user)
  }
}
