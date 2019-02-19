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

    _ = self.navigationItem
      |> \.title %~ { _ in Strings.Currency() }

    self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)

    self.view.addSubview(self.tableView)
    self.tableView.constrainEdges(to: self.view)

    let headerContainerView = UIView(frame: .zero)
    headerContainerView.addSubview(self.headerView)
    self.headerView.constrainEdges(to: headerContainerView, priority: .defaultHigh)

    self.tableView.tableHeaderView = headerContainerView
    self.headerView.widthAnchor.constraint(equalTo: self.tableView.widthAnchor).isActive = true

    self.messageBannerViewController = self.configureMessageBannerViewController(on: self)

    self.saveButtonView = LoadingBarButtonItemView.instantiate()
    self.saveButtonView.setTitle(title: Strings.Save())
    self.saveButtonView.addTarget(self, action: #selector(saveButtonTapped(_:)))

    let navigationBarButton = UIBarButtonItem(customView: self.saveButtonView)
    self.navigationItem.setRightBarButton(navigationBarButton, animated: false)

    self.viewModel.inputs.viewDidLoad()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    self.tableView.ksr_sizeHeaderFooterViewsToFit()
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
