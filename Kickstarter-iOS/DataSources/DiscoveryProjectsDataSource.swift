import Library
import Models
import UIKit

internal final class DiscoveryProjectsDataSource: ValueCellDataSource {

  func loadData(projects: [Project]) {
    self.clearValues()

    projects.forEach { project in
        self.appendSection(
          values: [project],
          cellClass: DiscoveryProjectCell.self
        )
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
