import KsApi
import Library

final class SettingsAccountDataSource: ValueCellDataSource {

  func configureRows() {
    SettingsAccountSectionType.allCases.forEach { section -> Void in
      let values = section.cellRowsForSection.map { SettingsCellValue(user: nil, cellType: $0) }

      self.set(values: values,
               cellClass: SettingsTableViewCell.self,
               inSection: section.rawValue)
    }
  }

  func cellTypeForIndexPath(indexPath: IndexPath) -> SettingsAccountCellType? {
    return self[indexPath] as? SettingsAccountCellType
  }

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as SettingsTableViewCell, value as SettingsCellValue):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized (cell, viewModel) combo.")
    }
  }
}
