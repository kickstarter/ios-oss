import Foundation
import Library
import KsApi

internal final class SettingsPrivacyDataSource: ValueCellDataSource {
  fileprivate enum Section: Int {
    case following
    case followingFooter
    case recommendations
    case recommendationsFooter
    case downloadData
    case downloadDataFooter
    case deleteAccount
  }

  internal func loadFollowCell(user: User) {
    let this = [user]
    self.set(values: this.map { $0 } ,
               cellClass: SettingsPrivacyCell.self,
               inSection: Section.following.rawValue)
  }

  internal func loadFollowFooter() {
    self.set(values: [Strings.When_following_is_on_you_can_follow_the_acticity_of_others()],
             cellClass: SettingsPrivacyStaticCell.self, // change to FollowCell
             inSection: Section.followingFooter.rawValue)
  }

  internal func loadRecommendationsCell(user: User) {
    let this = [user]
    self.set(values: this.map { $0 } ,
             cellClass: SettingsPrivacyRecommendationCell.self,
             inSection: Section.recommendations.rawValue)
  }

  internal func loadRecommendationsFooter() {
    self.set(values: [Strings.We_use_your_activity_internally_to_make_recommendations_for_you()],
             cellClass: SettingsPrivacyStaticCell.self,
             inSection: Section.recommendationsFooter.rawValue)
  }

  internal func loadDownloadDataCell(user: User) {
    let this = [user]
    self.set(values: this.map { $0 } ,
             cellClass: SettingsPrivacyRequestDataCell.self,
             inSection: Section.downloadData.rawValue)
  }

  internal func loadDownloadDataFooter() {
    self.set(values: ["DOWNLOAD DATA COPY"],
             cellClass: SettingsPrivacyStaticCell.self, // might be it's own cell
             inSection: Section.downloadDataFooter.rawValue)
  }

  internal func loadDeleteAccountCell(user: User) {
    let this = [user]
    self.set(values: this.map { $0 } ,
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
