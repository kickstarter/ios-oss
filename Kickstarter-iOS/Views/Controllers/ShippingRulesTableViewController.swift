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

    self.viewModel.outputs.reloadDataWithShippingRules
      .observeForUI()
      .observeValues { [weak self] shippingRules, reload in
        self?.dataSource.load(shippingRules)
        if reload {
          self?.tableView.reloadData()
        }
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
}
