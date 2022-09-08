import Foundation
import Library
import UIKit

final class ShippingRulesDataSource: ValueCellDataSource {
  // MARK: - Load

  func load(_ values: [ShippingRuleData]) {
    self.set(
      values: values,
      cellClass: ShippingRuleCell.self,
      inSection: 0
    )
  }

  // MARK: - Configure

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as ShippingRuleCell, value as (ShippingRuleData)):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized (cell, viewModel) combo.")
    }
  }
}
