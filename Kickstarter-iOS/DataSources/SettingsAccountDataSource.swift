import KsApi
import Library

final class SettingsAccountDataSource: ValueCellDataSource {

  func configureRows() {
    _ = SettingsAccountSectionType.allCases.map { section -> Void in
     self.set(values: section.cellRowsForSection,
              cellClass: SettingsTableViewCell.self, inSection: section.rawValue)
    }
  }

  func cellTypeForIndexPath(indexPath: IndexPath) -> SettingsCellType? {
    return self[indexPath] as? SettingsCellType
  }

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as SettingsTableViewCell, value as SettingsCellType):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized (cell, viewModel) combo.")
    }
  }
}
