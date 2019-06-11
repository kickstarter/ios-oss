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

  // MARK: - Load

  func load(project: Project, reward: Reward, isLoggedIn: Bool) {
    self.appendRow(
      value: reward,
      cellClass: PledgeDescriptionCell.self,
      toSection: Section.project.rawValue
    )

    self.appendRow(
      value: (project, reward),
      cellClass: PledgeAmountCell.self,
      toSection: Section.inputs.rawValue
    )

    if reward.shipping.enabled {
      self.appendRow(
        value: (project, reward),
        cellClass: PledgeShippingLocationCell.self,
        toSection: Section.inputs.rawValue
      )
    }

    self.appendRow(
      value: Strings.Total(),
      cellClass: PledgeRowCell.self,
      toSection: Section.summary.rawValue
    )

    if !isLoggedIn {
      self.appendRow(
        value: (),
        cellClass: PledgeContinueCell.self,
        toSection: Section.summary.rawValue
      )
    }
  }

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as PledgeAmountCell, value as (Project, Reward)):
      cell.configureWith(value: value)
    case let (cell as PledgeContinueCell, value as ()):
      cell.configureWith(value: value)
    case let (cell as PledgeDescriptionCell, value as Reward):
      cell.configureWith(value: value)
    case let (cell as PledgeRowCell, value as String):
      cell.configureWith(value: value)
    case let (cell as PledgeShippingLocationCell, value as (Project, Reward)):
      cell.configureWith(value: value)
    case let (cell as PledgeContinueCell, value as ()):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized (cell, viewModel) combo.")
    }
  }
}
