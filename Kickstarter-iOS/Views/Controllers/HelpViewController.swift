import Library
import KsApi
import Prelude

final class HelpViewController: UIViewController {
  @IBOutlet fileprivate weak var tableView: UITableView!

  private let dataSource = HelpDataSource()

  internal static func instantiate() -> HelpViewController {
    return Storyboard.SettingsV2.instantiate(HelpViewController.self)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.dataSource = dataSource
    tableView.delegate = self
    tableView.register(nib: .SettingsTableViewCell)
    tableView.registerHeaderFooter(nib: .SettingsHeaderView)

    _ = tableView |> UIView.lens.backgroundColor .~ .ksr_grey_200

    dataSource.configureRows()

    tableView.reloadData()
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseControllerStyle()
      |> UIViewController.lens.view.backgroundColor .~ .ksr_grey_200
      |> UIViewController.lens.title %~ { _ in Strings.profile_settings_about_title() }
  }
}

extension HelpViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 30
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    return tableView.dequeueReusableHeaderFooterView(withIdentifier: Nib.SettingsHeaderView.rawValue)
  }
}
