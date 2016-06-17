import Foundation
import Library
import KsApi

internal final class DashboardDataSource: ValueCellDataSource {
  private enum Section: Int {
    case Context
    case Action
    case FundingProgress
    case Rewards
    case Referers
    case Video
  }

  internal func load(project project: Project) {
    self.clearValues()

    self.appendRow(
      value: project,
      cellClass: DashboardContextCell.self,
      toSection: Section.Context.rawValue
    )

    self.appendRow(
      value: project,
      cellClass: DashboardActionCell.self,
      toSection: Section.Action.rawValue
    )
  }

  internal override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as DashboardContextCell, value as Project):
      cell.configureWith(value: value)
    case let (cell as DashboardActionCell, value as Project):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized (\(cell.dynamicType), \(value.dynamicType)) combo.")
    }
  }

  internal func didSelectContext(at indexPath: NSIndexPath) -> Bool {
    return indexPath.section == Section.Context.rawValue
  }
}
