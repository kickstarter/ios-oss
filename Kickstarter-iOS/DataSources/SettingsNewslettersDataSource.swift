import Library
import KsApi

internal final class SettingsNewslettersDataSource: ValueCellDataSource {

  internal enum Section: Int {
    case newsletters
  }

  internal func load(newsletters: [Newsletter]) {
    self.set(values: newsletters,
             cellClass: SettingsNewslettersCell.self,
             inSection: Section.newsletters.rawValue)
  }

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as SettingsNewslettersCell, value as Newsletter):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized (cell, viewModel) combo.")
    }
  }
}
