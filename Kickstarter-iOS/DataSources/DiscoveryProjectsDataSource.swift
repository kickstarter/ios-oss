import class Library.ValueCellDataSource
import struct Models.Project
import class UIKit.UITableViewCell

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

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    if let cell = cell as? DiscoveryProjectCell,
      project = value as? Project {
      cell.configureWith(value: project)
    }
  }
}
