import KsApi
import Library

final class SettingsAccountDataSource: ValueCellDataSource {

  private var filteredSections: [SettingsAccountSectionType] = []

  func configureRows(currency: Currency?,
                     shouldHideEmailWarning: Bool,
                     shouldHideEmailPasswordSection: Bool) {

    self.filteredSections = shouldHideEmailPasswordSection
      ? SettingsAccountSectionType.allCases.filter { $0 != .changeEmailPassword }
      : SettingsAccountSectionType.allCases.filter { $0 != .createPassword }

    self.clearValues()

    self.filteredSections.forEach { section -> Void in
      let values = section.cellRowsForSection.map { SettingsCellValue(cellType: $0) }

      self.filteredSections.append(section)

      guard let index = self.index(of: section) else { return }

      self.set(values: values,
               cellClass: SettingsTableViewCell.self,
               inSection: index)

      if section == .changeEmailPassword {
        self.insertChangeEmailCell(shouldHideEmailWarning)
      }
    }

    _ = self.insertCurrencyCell(with: currency)
  }

  func insertChangeEmailCell(_ shouldHideEmailWarning: Bool) {
    guard let section = self.index(of: .changeEmailPassword) else { return }

    self.insertRow(value: shouldHideEmailWarning,
                   cellClass: SettingsAccountWarningCell.self,
                   atIndex: 0,
                   inSection: section)
  }

  func insertCurrencyCell(with currency: Currency?) -> IndexPath? {
    guard let section = self.index(of: .payment) else { return nil }

    let cellValue = SettingsCurrencyCellValue(cellType: SettingsAccountCellType.currency, currency: currency)

    return self.appendRow(value: cellValue,
                          cellClass: SettingsCurrencyCell.self,
                          toSection: section)
  }

  func insertCurrencyPickerRow(with currency: Currency) -> IndexPath? {
    guard let section = self.index(of: .payment) else { return nil }

    let cellValue = SettingsCellValue(cellType: SettingsAccountCellType.currencyPicker, currency: currency)

    return self.appendRow(value: cellValue,
                          cellClass: SettingsCurrencyPickerCell.self,
                          toSection: section)
  }

  func removeCurrencyPickerRow() -> IndexPath? {
    guard let section = self.index(of: .payment) else { return nil }

    let endIndex = self.numberOfItems(in: section)

    guard endIndex > 0 else { return nil }

    let cellValue = SettingsCellValue(cellType: SettingsAccountCellType.currencyPicker)

    return self.deleteRow(value: cellValue,
                          cellClass: SettingsCurrencyPickerCell.self,
                          atIndex: endIndex - 1,
                          inSection: section)
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

  private func index(of section: SettingsAccountSectionType) -> Int? {
    return self.filteredSections.index(of: section)
  }
}
