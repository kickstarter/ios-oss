import Foundation
import KsApi
import Library

final class PledgeDataSource: ValueCellDataSource {
  enum Section: Int {
    case project
    case inputs
    case summary
  }

  func load(reward: Reward) {
    self.appendRow(
      value: "Description",
      cellClass: PledgeRowCell.self,
      toSection: Section.project.rawValue
    )

    self.appendRow(
      value: "Your pledge amount",
      cellClass: PledgeRowCell.self,
      toSection: Section.inputs.rawValue
    )

    self.appendRow(
      value: "Your shipping location",
      cellClass: PledgeRowCell.self,
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
    case let (cell as PledgeRowCell, value as String):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized (cell, viewModel) combo.")
    }
  }
}
