import KsApi
import Library

final class SettingsAccountDataSource: ValueCellDataSource {
  func configureRows(currency: Currency?, shouldHideEmailWarning: Bool) {
    clearValues()
    SettingsAccountSectionType.allCases
      .forEach { section -> Void in
      let values = section.cellRowsForSection.map { SettingsCellValue(user: nil, cellType: $0) }

      self.set(values: values,
               cellClass: SettingsTableViewCell.self,
               inSection: section.rawValue)
    }

    self.insertChangeEmailCell(shouldHideEmailWarning)

    _ = self.insertCurrencyCell(currency: currency)
  }

  func insertChangeEmailCell(_ shouldHideEmailWarning: Bool) {
    self.insertRow(value: shouldHideEmailWarning,
                   cellClass: SettingsAccountWarningCell.self,
                   atIndex: 0,
                   inSection: SettingsAccountSectionType.emailPassword.rawValue)
  }

  func insertCurrencyCell(currency: Currency?) -> IndexPath {
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
      //swiftlint:disable unused_optional_binding
    } else if let _ = self[indexPath] as? Bool {
      return SettingsAccountCellType.changeEmail
    } else {
      return nil
    }
  }

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as SettingsAccountWarningCell, value as Bool):
      cell.configureWith(value: value)
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
