import KsApi
import Library

final class SettingsAccountDataSource: ValueCellDataSource {

  func configureRows(currency: Currency?,
                     shouldHideEmailWarning: Bool,
                     shouldHideEmailPasswordSection: Bool) {

    let filteredSections = shouldHideEmailPasswordSection
      ? SettingsAccountSectionType.allCases.filter { $0 != .emailPassword }
      : SettingsAccountSectionType.allCases

    self.clearValues()

    filteredSections.enumerated().forEach { idx, section -> Void in

      let values = section.cellRowsForSection.map { SettingsCellValue(cellType: $0) }

        self.set(values: values,
                 cellClass: SettingsTableViewCell.self,
                 inSection: section.rawValue)

        if section == .emailPassword {
          self.insertChangeEmailCell(shouldHideEmailWarning)
        }
    }

    _ = self.insertCurrencyCell(with: currency)
  }

  func insertChangeEmailCell(_ shouldHideEmailWarning: Bool) {
    self.insertRow(value: shouldHideEmailWarning,
                   cellClass: SettingsAccountWarningCell.self,
                   atIndex: 0,
                   inSection: SettingsAccountSectionType.emailPassword.rawValue)
  }

  func insertCurrencyCell(with currency: Currency?) -> IndexPath {
    let cellValue = SettingsCurrencyCellValue(cellType: SettingsAccountCellType.currency, currency: currency )

    return self.appendRow(value: cellValue,
                          cellClass: SettingsCurrencyCell.self,
                          toSection: SettingsAccountSectionType.payment.rawValue)
  }

  func insertCurrencyPickerRow(with currency: Currency) -> IndexPath {
    let cellValue = SettingsCellValue(cellType: SettingsAccountCellType.currencyPicker, currency: currency)

    return self.appendRow(value: cellValue,
                          cellClass: SettingsCurrencyPickerCell.self,
                          toSection: SettingsAccountSectionType.payment.rawValue)
  }

  func removeCurrencyPickerRow() -> IndexPath? {
    let endIndex = self.numberOfItems(in: SettingsAccountSectionType.payment.rawValue)

    guard endIndex > 0 else { return nil }

    let cellValue = SettingsCellValue(cellType: SettingsAccountCellType.currencyPicker)

    return self.deleteRow(value: cellValue,
                          cellClass: SettingsCurrencyPickerCell.self,
                          atIndex: endIndex - 1,
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
