import Foundation
import KsApi
import Library
import UIKit

final class PledgeDataSource: ValueCellDataSource {
  enum Section: Int {
    case project
    case inputs
    case summary
  }

  func load(amount: Double, currency: String, delivery: String, isLoggedIn: Bool) {
    self.appendRow(
      value: delivery,
      cellClass: PledgeDescriptionCell.self,
      toSection: Section.project.rawValue
    )

    self.appendRow(
      value: (amount, currency),
      cellClass: PledgeAmountCell.self,
      toSection: Section.inputs.rawValue
    )

    self.appendRow(
      value: (location: "British Indian Ocean Territory", currency: "$", rate: 7.50),
      cellClass: PledgeShippingLocationCell.self,
      toSection: Section.inputs.rawValue
    )

    self.loadSummarySection(isLoggedIn: isLoggedIn)
  }

  private func loadSummarySection(isLoggedIn: Bool) {
    self.appendRow(
      value: "Total",
      cellClass: PledgeRowCell.self,
      toSection: Section.summary.rawValue
    )

    if !isLoggedIn {
      self.appendRow(value: (),
                     cellClass: PledgeContinueCell.self,
                     toSection: Section.summary.rawValue)
    }
  }

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as PledgeAmountCell, value as (Double, String)):
      cell.configureWith(value: value)
    case let (cell as PledgeDescriptionCell, value as String):
      cell.configureWith(value: value)
    case let (cell as PledgeRowCell, value as String):
      cell.configureWith(value: value)
    case let (cell as PledgeShippingLocationCell, value as (String, String, Double)):
      cell.configureWith(value: value)
    case let (cell as PledgeContinueCell, value as ()):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized (cell, viewModel) combo.")
    }
  }
}
