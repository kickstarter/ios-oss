import KsApi
import Library

final class SettingsAccountDataSource: ValueCellDataSource {

  func configureRows() {
    SettingsAccountSectionType.allCases
      .forEach { section -> Void in
      let values = section.cellRowsForSection.map { SettingsCellValue(user: nil, cellType: $0) }

      self.set(values: values,
               cellClass: SettingsTableViewCell.self,
               inSection: section.rawValue)
    }
    insertCurrencyCell()
  }

  func insertCurrencyCell() -> IndexPath {
    let cellValue = SettingsCellValue(user: nil, cellType: SettingsAccountCellType.currency)

    return self.insertRow(value: cellValue,
                          cellClass: SettingsCurrencyCell.self, // Make a new cell here
                          atIndex: 1,
                          inSection: SettingsAccountSectionType.payment.rawValue)
  }

  func insertCurrencyPickerRow() -> IndexPath {
    let cellValue = SettingsCellValue(user: nil, cellType: SettingsAccountCellType.currencyPicker)

    return self.appendRow(value: cellValue,
                          cellClass: SettingsCurrencyPickerCell.self,
                          toSection: SettingsAccountSectionType.payment.rawValue)
  }

  func removeCurrencyPickerRow() -> IndexPath {
    let cellValue = SettingsCellValue(user: nil, cellType: SettingsAccountCellType.currencyPicker)

    return self.deleteRow(value: cellValue,
                           cellClass: SettingsCurrencyPickerCell.self,
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
    case let (cell as SettingsCurrencyPickerCell, value as SettingsCellValue):
      cell.configureWith(value: value)
    case let (cell as SettingsCurrencyCell, value as SettingsCellValue):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized (cell, viewModel) combo.")
    }
  }
}
