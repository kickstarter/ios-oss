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

    _ = SettingsNotificationSectionType.allCases
      .filter { filterCreatorForSection($0, user: user) }
      .enumerated()
      .map { index, section -> Void in

        let values = section.cellRowsForSection.map { cellType in
           return SettingsNotificationCellValue(cellType: cellType, user: user)
         }

         self.set(values: values,
                  cellClass: SettingsNotificationCell.self,
                  inSection: index)
    }

    let pledgeActivityEnabled = (user
      |> UserAttribute.notification(.pledgeActivity).lens.view) ?? false

    if pledgeActivityEnabled {
      _ = self.insertEmailFrequencyCell(user: user)
    }
  }

  func insertEmailFrequencyCell(user: User) -> IndexPath {
    let cellValue = SettingsNotificationCellValue(cellType: .emailFrequency, user: user)

    return self.insertRow(value: cellValue,
                          cellClass: SettingsNotificationPickerCell.self,
                          atIndex: 1,
                          inSection: SettingsNotificationSectionType.creator.rawValue)
  }

  func sectionType(section: Int, user: User?) -> SettingsNotificationSectionType? {
    guard let user = user else {
      return nil
    }

    let allSections = SettingsNotificationSectionType.allCases
      .filter { filterCreatorForSection($0, user: user) }

    guard section < allSections.endIndex else {
      return nil
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
    case let (cell as SettingsNotificationPickerCell, value as SettingsNotificationCellValue):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized (cell, viewModel) combo.")
    }
  }

  // MARK: Helpers
  func filterCreatorForSection(_ section: SettingsNotificationSectionType, user: User) -> Bool {
    return user.isCreator ? true : (section != .creator)
  }
}
