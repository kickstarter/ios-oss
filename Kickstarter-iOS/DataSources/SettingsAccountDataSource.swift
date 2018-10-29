import KsApi
import Library

public struct SettingsCurrencyCellValue {
  public let cellType: SettingsCellTypeProtocol
  public let currency: Currency
}

final class SettingsAccountDataSource: ValueCellDataSource {
  func configureRows(user: User, currency: Currency) {
    clearValues()
    SettingsAccountSectionType.allCases
      .forEach { section -> Void in
      let values = section.cellRowsForSection.map { SettingsCellValue(user: nil, cellType: $0) }

      self.set(values: values,
               cellClass: SettingsTableViewCell.self,
               inSection: section.rawValue)
    }
    _ = insertCurrencyCell(currency: currency)
  }

  func insertCurrencyCell(currency: Currency) -> IndexPath {
    let cellValue = SettingsCurrencyCellValue(cellType: SettingsAccountCellType.currency, currency: currency )

    return self.insertRow(value: cellValue,
                          cellClass: SettingsCurrencyCell.self,
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
    if let value = self[indexPath] as? SettingsCellValue {
      return value.cellType as? SettingsAccountCellType
    } else if let currencyValue = self[indexPath] as? SettingsCurrencyCellValue {
      return currencyValue.cellType as? SettingsAccountCellType
    } else {
      return nil
    }
  }

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as SettingsTableViewCell, value as SettingsCellValue):
      cell.configureWith(value: value)
    case let (cell as SettingsCurrencyPickerCell, value as SettingsCellValue):
      cell.configureWith(value: value)
    case let (cell as SettingsCurrencyCell, value as SettingsCurrencyCellValue):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized (cell, viewModel) combo.")
    }
  }
}
