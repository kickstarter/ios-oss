import Library
import Prelude
import Prelude_UIKit
import UIKit

private let reuseIdentifier = "CurrencySelectionCell"

final class SelectCurrencyViewController: UIViewController, MessageBannerViewControllerPresenting {
  private let viewModel: SelectCurrencyViewModelType = SelectCurrencyViewModel()

  internal var messageBannerViewController: MessageBannerViewController?
  private var saveButtonView: LoadingBarButtonItemView!

  internal static func instantiate() -> SelectCurrencyViewController {
    return SelectCurrencyViewController(nibName: nil, bundle: nil)
  }

  public func configure(with currency: Currency) {
    self.viewModel.inputs.configure(with: currency)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)

    self.tableView.setHeaderViewConstrainedToWidth(self.headerView)
    self.view.addSubview(self.tableView)
    self.tableView.constrainEdges(to: self.view)

    self.viewModel.inputs.viewDidLoad()
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self.tableView
      |> settingsTableViewStyle
      |> \.separatorStyle .~ .singleLine

    _ = self.headerView
      |> \.text %~ { _ in
        """
        \(Strings.Making_this_change())\n
        \(Strings.A_successfully_funded_project_will_collect_your_pledge_in_its_native_currency())
        """
    }
  }

  // MARK: - Subviews

  private lazy var tableView: UITableView = {
    UITableView(frame: .zero, style: .plain)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
      |> \.tableFooterView .~ UIView(frame: .zero)
      |> \.dataSource .~ self
      |> \.delegate .~ self
  }()

  private lazy var headerView: SelectCurrencyTableViewHeader = {
    SelectCurrencyTableViewHeader(frame: .zero)
  }()
}

extension SelectCurrencyViewController: UITableViewDataSource {

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return Currency.allCases.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)

    let currency = Currency.allCases[indexPath.row]

    cell.textLabel?.text = currency.descriptionText
    cell.accessoryType = self.viewModel.outputs.isSelectedCurrency(currency) ? .checkmark : .none

    return cell
  }
}

extension SelectCurrencyViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let currency = Currency.allCases[indexPath.row]

    self.viewModel.inputs.didSelect(currency)

    tableView.deselectRow(at: indexPath, animated: true)
    tableView.visibleCells.forEach { $0.accessoryType = .none }
    tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
  }
}
