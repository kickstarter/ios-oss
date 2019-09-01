import KsApi
import Library
import Prelude
import UIKit

final class ShippingRulesTableViewController: UITableViewController {
  // MARK: - Properties

  private let dataSource: ShippingRulesDataSource = ShippingRulesDataSource()
  private let viewModel: ShippingRulesViewModelType = ShippingRulesViewModel()

  // MARK: - Lifecycle

  static func instantiate() -> ShippingRulesTableViewController {
    return ShippingRulesTableViewController(style: .plain)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    _ = self.tableView
      |> \.dataSource .~ self.dataSource

    self.tableView.registerCellClass(ShippingRuleCell.self)

    self.viewModel.inputs.viewDidLoad()
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.deselectCellAtIndex
      .map { IndexPath(row: $0, section: 0) }
      .observeForUI()
      .observeValues { [weak self] indexPath in
        self?.tableView.cellForRow(at: indexPath)?.accessoryType = .none
      }

    self.viewModel.outputs.flashScrollIndicators
      .observeForUI()
      .observeValues { [weak self] in
        self?.tableView.flashScrollIndicators()
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

  // MARK: - UITableViewDelegate

  override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
    self.viewModel.inputs.didSelectShippingRule(at: indexPath.row)

    self.tableView.deselectRow(at: indexPath, animated: true)
  }
}
