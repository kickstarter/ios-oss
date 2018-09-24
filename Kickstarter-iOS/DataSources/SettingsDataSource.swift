import Library
import KsApi

public struct SettingsCellValue {
  let user: User?
  let cellType: SettingsCellTypeProtocol
}

final class SettingsDataSource: ValueCellDataSource {
  func configureRows(with user: User) {

    SettingsDataSource.sections.forEach { section -> Void in
      let values = section.cellRowsForSection.map { SettingsCellValue(user: user, cellType: $0) }

      switch section {
      case .findFriends:
        self.set(values: values,
                 cellClass: FindFriendsCell.self,
                 inSection: SettingsSectionType.findFriends.rawValue)
      default:
        self.set(values: values,
                 cellClass: SettingsTableViewCell.self,
                 inSection: section.rawValue)
      }
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

  private static var sections: [SettingsSectionType] {
    return AppEnvironment.current.mainBundle.isRelease ?
      SettingsSectionType.allCases.filter { $0 != .account } : SettingsSectionType.allCases
  }
}
