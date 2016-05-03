import Library
import Models

internal final class SearchDataSource: ValueCellDataSource {
  private enum Section: Int {
    case PopularTitle
    case Projects
  }

  internal func popularTitle(isVisible visible: Bool) {
    self.set(cellIdentifiers: visible ? ["MostPopularCell"] : [],
             inSection: Section.PopularTitle.rawValue)
  }

  internal func load(projects projects: [Project]) {
    self.set(values: projects,
             cellClass: SearchProjectCell.self,
             inSection: Section.Projects.rawValue)
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
