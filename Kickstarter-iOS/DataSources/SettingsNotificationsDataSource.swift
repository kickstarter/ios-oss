import Library
import KsApi
import Prelude

public struct SettingsNotificationCellValue {
  let cellType: SettingsNotificationCellType
  let user: User
}

final class SettingsNotificationsDataSource: ValueCellDataSource {
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

//  func settingsCellValue(for cellType: SettingsNotificationCellType, user: User) -> SettingsNotificationCellValue {
//    switch cellType {
//    case .projectUpdates:
//      return SettingsNotificationCellValue(cellType: .projectUpdates,
//                                           pushNotificationsEnabled: user
//                                            |> UserAttribute.notification(.mobileUpdates).lens.view,
//                                           emailNotificationsEnabled: user
//                                            |> UserAttribute.notification(.updates).lens.view)
//    case .projectNotifications:
//      return SettingsNotificationCellValue(cellType: .projectNotifications,
//                                           pushNotificationsEnabled: nil,
//                                           emailNotificationsEnabled: nil,
//                                           projectCount: Format.wholeNumber(user.stats.backedProjectsCount
//                                            ?? 0)
//      )
//    case .pledgeActivity:
//      // TODO: what is pledge activity?
//      return SettingsNotificationCellValue(cellType: .pledgeActivity,
//                                           pushNotificationsEnabled: user |> UserAttribute.notification(.creatorDigest).lens.view,
//                                           emailNotificationsEnabled: user |> UserAttribute.notification(.creatorDigest).lens.view)
//    case .newComments:
//      return SettingsNotificationCellValue(cellType: .newComments,
//                                           pushNotificationsEnabled: user
//                                            |> UserAttribute.notification(.comments).lens.view,
//                                           emailNotificationsEnabled: user
//                                            |> UserAttribute.notification(.mobileComments).lens.view)
//    case .newLikes:
//      return SettingsNotificationCellValue(cellType: .newLikes,
//                                           pushNotificationsEnabled: user
//                                            |> UserAttribute.notification(.postLikes).lens.view,
//                                           emailNotificationsEnabled: user
//                                            |> UserAttribute.notification(.mobilePostLikes).lens.view)
//    case .creatorTips:
//      return SettingsNotificationCellValue(cellType: .creatorTips,
//                                           pushNotificationsEnabled: nil,
//                                           emailNotificationsEnabled: user
//                                            |> UserAttribute.notification(.creatorTips).lens.view)
//    case .messages:
//      return SettingsNotificationCellValue(cellType: .messages,
//                                           pushNotificationsEnabled: user
//                                            |> UserAttribute.notification(.messages).lens.view,
//                                           emailNotificationsEnabled: user
//                                            |> UserAttribute.notification(.mobileMessages).lens.view)
//    case .newFollowers:
//      return SettingsNotificationCellValue(cellType: .newFollowers,
//                                           pushNotificationsEnabled: user
//                                            |> UserAttribute.notification(.follower).lens.view,
//                                           emailNotificationsEnabled: user
//                                            |> UserAttribute.notification(.mobileFollower).lens.view)
//    case .friendBacksProject:
//      return SettingsNotificationCellValue(cellType: .friendBacksProject,
//                                           pushNotificationsEnabled: user
//                                            |> UserAttribute.notification(.friendActivity).lens.view,
//                                           emailNotificationsEnabled: user
//                                            |> UserAttribute.notification(.mobileFriendActivity).lens.view)
//    default:
//      return SettingsNotificationCellValue(cellType: cellType)
//    }
//  }

  func cellTypeForIndexPath(indexPath: IndexPath) -> SettingsNotificationCellType? {
    let value = self[indexPath] as? SettingsNotificationCellValue

    return value?.cellType
  }

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as SettingsNotificationCell, value as SettingsNotificationCellValue):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized (cell, viewModel) combo.")
    }
  }
}

