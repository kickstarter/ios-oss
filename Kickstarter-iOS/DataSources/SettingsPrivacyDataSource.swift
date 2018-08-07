import Foundation
import Library
import KsApi

internal enum Section: Int {
  case following
  case followingFooter
  case recommendations
  case recommendationsFooter
  case requestData
  case deleteAccount
}

internal final class SettingsPrivacyDataSource: ValueCellDataSource {
  internal func load(user: User) {
    self.set(values: [user],
             cellClass: SettingsPrivacyCell.self,
             inSection: Section.following.rawValue)

    self.set(values: [Strings.When_following_is_on_you_can_follow_the_acticity_of_others()],
             cellClass: SettingsPrivacyStaticCell.self, // change to FollowCell
             inSection: Section.followingFooter.rawValue)

    self.set(values: [user],
             cellClass: SettingsPrivacyRecommendationCell.self,
             inSection: Section.recommendations.rawValue)

    self.set(values: [Strings.We_use_your_activity_internally_to_make_recommendations_for_you()],
             cellClass: SettingsPrivacyStaticCell.self,
             inSection: Section.recommendationsFooter.rawValue)

    self.set(values: [user],
             cellClass: SettingsPrivacyRequestDataCell.self,
             inSection: Section.requestData.rawValue)

    self.set(values: [user],
             cellClass: SettingsPrivacyDeleteAccountCell.self,
             inSection: Section.deleteAccount.rawValue)
  }

  internal override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as SettingsPrivacyCell, value as User):
      cell.configureWith(value: value)
    case let (cell as SettingsPrivacyRecommendationCell, value as User):
      cell.configureWith(value: value)
    case let (cell as SettingsPrivacyRequestDataCell, value as User):
      cell.configureWith(value: value)
    case let (cell as SettingsPrivacyDeleteAccountCell, value as User):
      cell.configureWith(value: value)
    case let (cell as SettingsPrivacyStaticCell, value as String):
      cell.configureWith(value: value)
    default:
      fatalError("Unrecognized combo (\(cell), \(value)).")
    }
  }
}
