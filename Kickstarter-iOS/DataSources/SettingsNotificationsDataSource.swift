import Library
import KsApi
import Prelude

public struct SettingsNotificationCellValue {
  let cellType: SettingsNotificationCellType
  let user: User
}

final class SettingsNotificationsDataSource: ValueCellDataSource {
  weak var cellDelegate: SettingsNotificationCellDelegate?

  func load(user: User) {
    let isCreator = user.isCreator

    _ = SettingsNotificationSectionType.allCases.filter { section -> Bool in
      return isCreator ? true : (section != .creator)
    }.enumerated().map { index, section -> Void in
      let values = section.cellRowsForSection.map { cellType in
        return SettingsNotificationCellValue(cellType: cellType, user: user)
      }

      self.set(values: values,
               cellClass: SettingsNotificationCell.self,
               inSection: index)
    }
  }

  func sectionType(section: Int, isCreator: Bool) -> SettingsNotificationSectionType? {
    let allSections = SettingsNotificationSectionType.allCases.filter { section -> Bool in
      return isCreator ? true : (section != .creator)
    }

    return allSections[section]
  }

  func cellTypeForIndexPath(indexPath: IndexPath) -> SettingsNotificationCellType? {
    let value = self[indexPath] as? SettingsNotificationCellValue

    return value?.cellType
  }

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as SettingsNotificationCell, value as SettingsNotificationCellValue):
      cell.configureWith(value: value)
      cell.delegate = cellDelegate
    default:
      assertionFailure("Unrecognized (cell, viewModel) combo.")
    }
  }
}

