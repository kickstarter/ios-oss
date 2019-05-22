import Foundation
import Library

final class PledgeDataSource: ValueCellDataSource {
  enum Section: Int {
    case project
    case inputs
    case summary
  }

  func load(amount: Double, currency: String, shipping: (location: String, amount: NSAttributedString?)) {
    self.appendRow(
      value: "Description",
      cellClass: PledgeRowCell.self,
      toSection: Section.project.rawValue
    )

    self.appendRow(
      value: (amount, currency),
      cellClass: PledgeAmountCell.self,
      toSection: Section.inputs.rawValue
    )

    self.appendRow(
      value: shipping,
      cellClass: PledgeShippingLocationCell.self,
      toSection: Section.inputs.rawValue
    )

    self.appendRow(
      value: "Total",
      cellClass: PledgeRowCell.self,
      toSection: Section.summary.rawValue
    )
  }

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as PledgeAmountCell, value as (Double, String)):
      cell.configureWith(value: value)
    case let (cell as PledgeRowCell, value as String):
      cell.configureWith(value: value)
    case let (cell as PledgeShippingLocationCell, value as (String, NSAttributedString?)):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized (cell, viewModel) combo.")
    }
  }
}
