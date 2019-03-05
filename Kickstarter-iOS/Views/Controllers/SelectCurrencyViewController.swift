import Library
import Prelude
import Prelude_UIKit
import UIKit

final class SelectCurrencyViewController: UIViewController, MessageBannerViewControllerPresenting {
  private let dataSource = SelectCurrencyDataSource()
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

    self.tableView.register(
      SelectCurrencyCell.self, forCellReuseIdentifier: SelectCurrencyCell.defaultReusableId
    )

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

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.reloadDataWithCurrencies
      .observeForUI()
      .observeValues { [weak self] currencies, reload in
        self?.dataSource.load(currencies: currencies)
        if reload {
          self?.tableView.reloadData()
        }
    }

    self.viewModel.outputs.activityIndicatorShouldShow
      .observeForUI()
      .observeValues { [weak self] shouldShow in
        if shouldShow {
          self?.saveButtonView.startAnimating()
        } else {
          self?.saveButtonView.stopAnimating()
        }
    }

    self.viewModel.outputs.saveButtonIsEnabled
      .observeForUI()
      .observeValues { [weak self] (isEnabled) in
        self?.saveButtonView.setIsEnabled(isEnabled: isEnabled)
    }

    self.viewModel.outputs.updateCurrencyDidFailWithError
      .observeForUI()
      .observeValues { [weak self] error in
        self?.messageBannerViewController?.showBanner(
          with: .error,
          message: error
        )
    }

    self.viewModel.outputs.deselectCellAtIndex
      .map { IndexPath(row: $0, section: 0) }
      .observeForUI()
      .observeValues { [weak self] indexPath in
        self?.tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }

    self.viewModel.outputs.selectCellAtIndex
      .map { IndexPath(row: $0, section: 0) }
      .observeForUI()
      .observeValues { [weak self] indexPath in
        self?.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    }

    self.viewModel.outputs.didUpdateCurrency
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.handleDidUpdateCurrency()
    }
  }

  // MARK: - Private Functions
  private func handleDidUpdateCurrency() {
    self.messageBannerViewController?.showBanner(with: .success,
                                                 message: Strings.Got_it_your_changes_have_been_saved())

    NotificationCenter.default.post(name: .ksr_userLocalePreferencesChanged, object: nil)
  }

  // MARK: - Actions

  @objc private func saveButtonTapped(_ sender: Any) {
    self.viewModel.inputs.saveButtonTapped()
  }

  // MARK: - Subviews

  private lazy var tableView: UITableView = {
    UITableView(frame: .zero, style: .plain)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
      |> \.tableFooterView .~ UIView(frame: .zero)
      |> \.dataSource .~ self.dataSource
      |> \.delegate .~ self
  }()

  private lazy var headerView: SelectCurrencyTableViewHeader = {
    SelectCurrencyTableViewHeader(frame: .zero)
  }()
}

extension SelectCurrencyViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    self.viewModel.inputs.didSelectCurrency(atIndex: indexPath.row)

    tableView.deselectRow(at: indexPath, animated: true)
  }
}
