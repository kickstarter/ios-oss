import Library
import KsApi
import Prelude
import ReactiveSwift
import Result

final class SettingsAccountViewController: UIViewController {

  @IBOutlet private weak var tableView: UITableView!

  private let dataSource = SettingsAccountDataSource()
  private let viewModel: SettingsViewModelType = SettingsViewModel()

  internal static func instantiate() -> SettingsAccountViewController {
    return Storyboard.SettingsAccount.instantiate(SettingsAccountViewController.self)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.dataSource = dataSource
    self.tableView.delegate = self

    self.tableView.register(nib: .SettingsTableViewCell)
    self.viewModel.inputs.viewDidLoad()
  }

  override func bindViewModel() {
    self.viewModel.outputs.reloadData
      .observeForUI()
      .observeValues { [weak self] in
        self?.dataSource.configureRows()
        self?.tableView.reloadData()
    }
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
}

extension SettingsAccountViewController: UITableViewDelegate {

}
