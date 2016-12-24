import Foundation
import Library
import KsApi

internal final class DashboardProjectsDrawerDataSource: ValueCellDataSource {
  internal func load(data: [ProjectsDrawerData]) {
    self.set(values: data,
             cellClass: DashboardProjectsDrawerCell.self,
             inSection: 0)
  }

  internal override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as DashboardProjectsDrawerCell, value as ProjectsDrawerData):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized (\(cell), \(value)) combo.")
    }
  }

  internal func projectAtIndexPath(_ indexPath: NSIndexPath) -> Project? {
    guard let data = self[indexPath as IndexPath] as? ProjectsDrawerData else { return nil }
    return data.project
  }
}
