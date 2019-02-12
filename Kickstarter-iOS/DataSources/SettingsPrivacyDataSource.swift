import Foundation
import Library
import KsApi

internal enum Section: Int {
  case following
  case followingFooter
  case recommendations
  case recommendationsFooter
  case privateProfile
  case requestData
  case deleteAccount
}

public struct SettingsPrivacyStaticCellValue {
  let cellType: SettingsStaticCellType
  let user: User
}

public struct SettingsPrivacySwitchCellValue {
  let cellType: SettingsSwitchCellType
  let user: User
}

internal final class SettingsPrivacyDataSource: ValueCellDataSource {
  internal func load(user: User) {
    let followingCellValue = SettingsPrivacyStaticCellValue(cellType: .following, user: user)

    self.set(values: [followingCellValue],
             cellClass: SettingsFollowCell.self,
             inSection: Section.following.rawValue)

    self.set(values: [followingCellValue.cellType.description],
             cellClass: SettingsPrivacyStaticCell.self,
             inSection: Section.followingFooter.rawValue)

    let recommendationsCellValue = SettingsPrivacyStaticCellValue(cellType: .recommendations, user: user)

    self.set(values: [recommendationsCellValue],
             cellClass: SettingsPrivacyRecommendationCell.self,
             inSection: Section.recommendations.rawValue)

    self.set(values: [recommendationsCellValue.cellType.description],
             cellClass: SettingsPrivacyStaticCell.self,
             inSection: Section.recommendationsFooter.rawValue)

    if !user.isCreator {
      let cellValue = SettingsPrivacySwitchCellValue(cellType: .privacy, user: user)

      self.set(values: [cellValue],
               cellClass: SettingsPrivacySwitchCell.self,
               inSection: Section.privateProfile.rawValue)
    }

    self.set(values: [user],
             cellClass: SettingsPrivacyRequestDataCell.self,
             inSection: Section.requestData.rawValue)

    self.set(values: [user],
             cellClass: SettingsPrivacyDeleteAccountCell.self,
             inSection: Section.deleteAccount.rawValue)
  }

  internal override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as SettingsFollowCell, value as SettingsPrivacyStaticCellValue):
      cell.configureWith(value: value)
    case let (cell as SettingsPrivacyRecommendationCell, value as SettingsPrivacyStaticCellValue):
      cell.configureWith(value: value)
    case let (cell as SettingsPrivacyRequestDataCell, value as User):
      cell.configureWith(value: value)
    case let (cell as SettingsPrivacyDeleteAccountCell, value as User):
      cell.configureWith(value: value)
    case let (cell as SettingsPrivacyStaticCell, value as String):
      cell.configureWith(value: value)
    case let (cell as SettingsPrivacySwitchCell, value as SettingsPrivacySwitchCellValue):
      cell.configureWith(value: value)
    default:
      fatalError("Unrecognized combo (\(cell), \(value)).")
    }
  }
}
