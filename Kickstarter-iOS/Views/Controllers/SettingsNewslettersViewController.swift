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

    self.tableView.dataSource = dataSource
    self.tableView.delegate = self
    self.tableView.registerHeaderFooter(nib: .SettingsNewslettersHeaderView)
    self.tableView.register(nib: .SettingsNewslettersCell)
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

    self.viewModel.outputs.initialUser
      .observeForUI()
      .observeValues { [weak self] user in
        AppEnvironment.updateCurrentUser(user)
        self?.dataSource.load(newsletters: Newsletter.allCases, user: user)
        self?.tableView.reloadData()
    }
  }
}

extension SettingsNewslettersViewController: UITableViewDelegate {

  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 146
  }

  internal func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

    return tableView.dequeueReusableHeaderFooterView(
      withIdentifier: Nib.SettingsNewslettersHeaderView.rawValue)
  }
}

extension SettingsNewslettersViewController: SettingsNewslettersCellDelegate {

  func shouldShowOptInAlert(_ newsletterName: String) {
    let optInAlert = UIAlertController.newsletterOptIn(newsletterName)
    self.present(optInAlert, animated: true, completion: nil)
  }
}
