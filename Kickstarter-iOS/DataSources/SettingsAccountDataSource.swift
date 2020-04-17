import Foundation
import KsApi
import Library
import UIKit

final class SettingsAccountDataSource: ValueCellDataSource {
  private var filteredSections: [SettingsAccountSectionType] = []

  func configureRows(
    currency: Currency?,
    shouldHideEmailWarning: Bool,
    shouldHideEmailPasswordSection: Bool,
    isAppleConnected: Bool
  ) {
    if isAppleConnected {
      self.filteredSections = SettingsAccountSectionType.allCases
        .filter { $0 != .changeEmailPassword && $0 != .createPassword }
    } else {
      self.filteredSections = shouldHideEmailPasswordSection
        ? SettingsAccountSectionType.allCases.filter { $0 != .changeEmailPassword }
        : SettingsAccountSectionType.allCases.filter { $0 != .createPassword }
    }

    self.clearValues()

    self.filteredSections.forEach { section -> Void in
      let values = section.cellRowsForSection.map { SettingsCellValue(cellType: $0) }

      self.filteredSections.append(section)

      guard let index = self.index(of: section) else { return }

      self.set(
        values: values,
        cellClass: SettingsTableViewCell.self,
        inSection: index
      )

      if section == .changeEmailPassword {
        self.insertChangeEmailCell(shouldHideEmailWarning)
      }
    }

    _ = self.insertCurrencyCell(with: currency)
  }

  func insertChangeEmailCell(_ shouldHideEmailWarning: Bool) {
    guard let section = self.index(of: .changeEmailPassword) else { return }

    self.insertRow(
      value: shouldHideEmailWarning,
      cellClass: SettingsAccountWarningCell.self,
      atIndex: 0,
      inSection: section
    )
  }

  func insertCurrencyCell(with currency: Currency?) -> IndexPath? {
    guard let section = self.index(of: .payment) else { return nil }

    let cellType = SettingsAccountCellType.currency(currency)

    let cellValue = SettingsCellValue(cellType: cellType)

    return self.appendRow(
      value: cellValue,
      cellClass: SettingsTableViewCell.self,
      toSection: section
    )
  }

  func cellTypeForIndexPath(indexPath: IndexPath) -> SettingsAccountCellType? {
    if let value = self[indexPath] as? SettingsCellValue {
      return value.cellType as? SettingsAccountCellType
    } else if let currencyValue = self[indexPath] as? SettingsCellValue {
      return currencyValue.cellType as? SettingsAccountCellType
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
    default:
      assertionFailure("Unrecognized (cell, viewModel) combo.")
    }
  }

  private func index(of section: SettingsAccountSectionType) -> Int? {
    return self.filteredSections.firstIndex(of: section)
  }
}
