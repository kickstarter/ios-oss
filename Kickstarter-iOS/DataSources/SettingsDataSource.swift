import Foundation
import KsApi
import Library
import UIKit

final class SettingsDataSource: ValueCellDataSource {
  func configureRows(with user: User) {
    SettingsSectionType.allCases.forEach { section -> Void in
      let values = section.cellRowsForSection.map { SettingsCellValue(cellType: $0, user: user) }

      self.set(
        values: values,
        cellClass: SettingsTableViewCell.self,
        inSection: section.rawValue
      )
    }
  }

  func cellTypeForIndexPath(indexPath: IndexPath) -> SettingsCellType? {
    let value = self[indexPath] as? SettingsCellValue

    return value?.cellType as? SettingsCellType
  }

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as SettingsTableViewCell, value as SettingsCellValue):
      cell.configureWith(value: value)
    case let (cell as FindFriendsCell, value as SettingsCellValue):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized (cell, viewModel) combo.")
    }
  }
}
