import Library
import KsApi
import UIKit

internal final class DiscoveryProjectsDataSource: ValueCellDataSource {

  func loadData(projects: [Project]) {
    self.clearValues()

    projects.forEach { project in
      self.appendRow(
        value: project,
        cellClass: DiscoveryProjectCell.self,
        toSection: 0
      )
      self.appendStaticRow(cellIdentifier: "Padding", toSection: 0)
    }
  }

  internal func projectAtIndexPath(indexPath: NSIndexPath) -> Project? {
    return self[indexPath] as? Project
  }

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    if let cell = cell as? DiscoveryProjectCell,
      project = value as? Project {
      cell.configureWith(value: project)
    }
  }
}
