import KsApi
import Library
import Prelude
import UIKit

internal final class SettingsNewslettersViewController: UIViewController {

  fileprivate let dataSource = SettingsNewslettersDataSource()

  @IBOutlet fileprivate weak var tableView: UITableView!

  internal static func instantiate() -> SettingsNewslettersViewController {
    return Storyboard.SettingsNewsletters.instantiate(SettingsNewslettersViewController.self)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.dataSource = dataSource
    self.tableView.register(nib: .SettingsNewslettersCell)
    self.dataSource.load(newsletters: Newsletter.allCases)
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self.tableView
      |> UITableView.lens.separatorStyle .~ .none
      |> UITableView.lens.estimatedRowHeight .~ 100
  }
}

extension SettingsNewslettersViewController: SettingsNewslettersCellDelegate {

  func shouldShowOptInAlert(_ newsletterName: String) {
    let optInAlert = UIAlertController.newsletterOptIn(newsletterName)
    self.present(optInAlert, animated: true, completion: nil)
  }
}
