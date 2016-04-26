import Library
import Models

internal final class SearchDataSource: ValueCellDataSource {

  internal func popularTitle(isVisible visible: Bool) {
    self.set(values: visible ? [()] : [],
             cellClass: StaticTableViewCell.self,
             inSection: 0)
  }

  internal func load(projects projects: [Project]) {
    self.set(values: projects,
             cellClass: SearchProjectCell.self,
             inSection: 1)
  }

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as SearchProjectCell, value as Project):
      cell.configureWith(value: value)
    case (is StaticTableViewCell, _):
      return
    default:
      assertionFailure("Unrecognized (cell, viewModel) combo.")
    }
  }
}
