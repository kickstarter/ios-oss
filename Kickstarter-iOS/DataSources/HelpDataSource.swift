import Library
import KsApi

final class HelpDataSource: ValueCellDataSource {
  func configureRows() {
    _ = HelpSectionType.allCases.map { section -> Void in
      self.set(values: section.cellRowsForSection,
               cellClass: SettingsTableViewCell.self,
               inSection: section.rawValue)
    }
  }

  func cellTypeForIndexPath(indexPath: IndexPath) -> HelpCellType? {
    return self[indexPath] as? HelpCellType
  }

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as SettingsTableViewCell, value as HelpCellType):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized (cell, viewModel) combo.")
    }
  }
}
