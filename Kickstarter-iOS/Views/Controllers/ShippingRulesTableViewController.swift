import KsApi
import Library
import Prelude
import UIKit

protocol ShippingRulesTableViewControllerDelegate: AnyObject {
  func shippingRulesTableViewControllerCancelButtonTapped()
  func shippingRulesTableViewController(
    _ tableViewController: ShippingRulesTableViewController,
    didSelect rule: ShippingRule
  )
}

final class ShippingRulesTableViewController: UITableViewController {
  // MARK: - Properties

  private let dataSource: ShippingRulesDataSource = ShippingRulesDataSource()
  private let viewModel: ShippingRulesViewModelType = ShippingRulesViewModel()
  weak var delegate: ShippingRulesTableViewControllerDelegate?

  private lazy var searchBar: UISearchBar = {
    UISearchBar(frame: .zero)
      |> \.delegate .~ self
      |> \.searchBarStyle .~ .minimal
      |> \.showsCancelButton .~ false
  }()

  // MARK: - Lifecycle

  static func instantiate() -> ShippingRulesTableViewController {
    return ShippingRulesTableViewController(style: .plain)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    _ = self
      |> \.navigationItem.rightBarButtonItem .~ UIBarButtonItem(
        barButtonSystemItem: .cancel,
        target: self,
        action: #selector(ShippingRulesTableViewController.dismissViewController)
      )

    _ = self.navigationItem
      |> \.titleView .~ self.searchBar

    _ = self.tableView
      |> \.dataSource .~ self.dataSource
      |> \.separatorStyle .~ .none

    self.tableView.registerCellClass(ShippingRuleCell.self)

    self.viewModel.inputs.viewDidLoad()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    self.viewModel.inputs.viewDidLayoutSubviews()
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseControllerStyle()
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.deselectVisibleCells
      .observeForUI()
      .observeValues { [weak self] in
        self?.tableView.visibleCells.forEach { $0.accessoryType = .none }
      }

    self.viewModel.outputs.flashScrollIndicators
      .observeForUI()
      .observeValues { [weak self] in
        self?.tableView.flashScrollIndicators()
      }

    self.viewModel.outputs.notifyDelegateOfSelectedShippingRule
      .observeForUI()
      .observeValues { [weak self] selectedShippingRule in
        guard let self = self else { return }

        self.delegate?.shippingRulesTableViewController(self, didSelect: selectedShippingRule)
      }

    self.viewModel.outputs.reloadDataWithShippingRules
      .observeForUI()
      .observeValues { [weak self] shippingRules, reload in
        self?.dataSource.load(shippingRules)
        if reload {
          self?.tableView.reloadData()
        }
      }

    self.viewModel.outputs.scrollToCellAtIndex
      .map { IndexPath(row: $0, section: 0) }
      .observeForUI()
      .observeValues { [weak self] indexPath in
        self?.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
      }

    self.viewModel.outputs.selectCellAtIndex
      .map { IndexPath(row: $0, section: 0) }
      .observeForUI()
      .observeValues { [weak self] indexPath in
        self?.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
      }
  }

  // MARK: - Configuration

  func configureWith(_ project: Project, shippingRules: [ShippingRule], selectedShippingRule: ShippingRule) {
    self.viewModel.inputs.configureWith(
      project,
      shippingRules: shippingRules,
      selectedShippingRule: selectedShippingRule
    )
  }

  // MARK: - Actions

  @objc private func dismissViewController() {
    self.delegate?.shippingRulesTableViewControllerCancelButtonTapped()
  }

  // MARK: - UITableViewDelegate

  override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
    self.viewModel.inputs.didSelectShippingRule(at: indexPath.row)

    self.tableView.deselectRow(at: indexPath, animated: true)
  }
}

extension ShippingRulesTableViewController: UISearchBarDelegate {
  func searchBar(_: UISearchBar, textDidChange searchText: String) {
    self.viewModel.inputs.searchTextDidChange(searchText)
  }
}
