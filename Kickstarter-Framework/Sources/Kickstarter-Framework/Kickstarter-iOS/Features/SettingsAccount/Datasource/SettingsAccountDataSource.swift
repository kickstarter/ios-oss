import Foundation
import KsApi
import Library
import UIKit

final class SettingsAccountDataSource: ValueCellDataSource {
  private var filteredSections: [SettingsAccountSectionType] = []

  func configureRows(
    currency: Currency?,
    isAppleConnected _: Bool
  ) {
    self.filteredSections = SettingsAccountSectionType.allCases

    self.clearValues()

    self.filteredSections.forEach { section in
      let values = section.cellRowsForSection.map { SettingsCellValue(cellType: $0) }

      self.filteredSections.append(section)

      guard let index = self.index(of: section) else { return }

      self.set(
        values: values,
        cellClass: SettingsTableViewCell.self,
        inSection: index
      )
    }

    _ = self.insertCurrencyCell(with: currency)
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
    } else {
      return nil
    }
  }

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
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
