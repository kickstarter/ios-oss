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

  func insertCurrencyPickerCell() -> IndexPath {
    let cellValue = SettingsCellValue(user: nil, cellType: SettingsAccountCellType.currency)

    return self.appendRow(value: cellValue,
                          cellClass: SettingsAccountPickerCell.self,
                          toSection: SettingsAccountSectionType.payment.rawValue)
  }

  func removeCurrencyPickerRow() -> IndexPath {
    let cellValue = SettingsCellValue(user: nil, cellType: SettingsAccountCellType.currency)

    return self.deleteRow(value: cellValue,
                           cellClass: SettingsAccountPickerCell.self,
                           atIndex: 2,
                           inSection: SettingsAccountSectionType.payment.rawValue)
  }

  func cellTypeForIndexPath(indexPath: IndexPath) -> SettingsAccountCellType? {
    let value = self[indexPath] as? SettingsCellValue

    return value?.cellType as? SettingsAccountCellType
  }

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as SettingsTableViewCell, value as SettingsCellValue):
      cell.configureWith(value: value)
    case let (cell as SettingsAccountPickerCell, value as SettingsCellValue):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized (cell, viewModel) combo.")
    }
  }
}
