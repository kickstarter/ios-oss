import Library
import KsApi

final class HelpDataSource: ValueCellDataSource {
  func configureRows() {
    _ = HelpSectionType.allCases.map { section -> Void in
      let values = section.cellRowsForSection.map { SettingsCellValue(user: nil, cellType: $0) }
      self.set(values: values,
               cellClass: SettingsTableViewCell.self,
               inSection: section.rawValue)
    }
  }

  func cellTypeForIndexPath(indexPath: IndexPath) -> HelpType? {
    let value = self[indexPath] as? SettingsCellValue
    return value?.cellType as? HelpType
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
