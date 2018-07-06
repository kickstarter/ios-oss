import KsApi
import Library
import Prelude
import UIKit

internal final class ActivitiesDataSource: ValueCellDataSource {
  internal enum Section: Int {
    case surveys
    case facebookConnect
    case findFriends
    case activities
  }

  internal func facebookConnect(source: FriendsSource, visible: Bool) {
    self.set(values: visible ? [source] : [],
             cellClass: FindFriendsFacebookConnectCell.self,
             inSection: Section.facebookConnect.rawValue)
  }

  internal func findFriends(source: FriendsSource, visible: Bool) {
    self.set(values: visible ? [source] : [],
             cellClass: FindFriendsHeaderCell.self,
             inSection: Section.findFriends.rawValue)
  }

  internal func removeFacebookConnectRows() -> [IndexPath] {
    self.clearValues(section: Section.facebookConnect.rawValue)

    return [IndexPath(row: 0, section: Section.facebookConnect.rawValue)]
  }

  internal func removeFindFriendsRows() -> [IndexPath] {
    self.clearValues(section: Section.findFriends.rawValue)

    return [IndexPath(row: 0, section: Section.findFriends.rawValue)]
  }

  internal func load(surveys: [SurveyResponse]) {
    let surveysWithPosition = surveys.enumerated().map { idx, survey in
      (surveyResponse: survey, count: surveys.count, position: idx)
    }

    self.set(values: surveysWithPosition,
             cellClass: ActivitySurveyResponseCell.self,
             inSection: Section.surveys.rawValue)
  }

  internal func load(activities: [Activity]) {
    let section = Section.activities.rawValue

    self.clearValues(section: section)

    activities.forEach { activity in
      switch activity.category {
      case .backing:
        self.appendRow(value: activity, cellClass: ActivityFriendBackingCell.self, toSection: section)
      case .update:
        self.appendRow(value: activity, cellClass: ActivityUpdateCell.self, toSection: section)
      case .follow:
        self.appendRow(value: activity, cellClass: ActivityFriendFollowCell.self, toSection: section)
      case .cancellation, .failure, .launch, .success, .suspension:
        self.appendRow(value: activity, cellClass: ActivityProjectStatusCell.self, toSection: section)
      default:
        assertionFailure("Unsupported activity: \(activity)")
      }
    }
  }

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as ActivityUpdateCell, activity as Activity):
      cell.configureWith(value: activity)
    case let (cell as ActivityFriendBackingCell, activity as Activity):
      cell.configureWith(value: activity)
    case let (cell as ActivityFriendFollowCell, activity as Activity):
      cell.configureWith(value: activity)
    case let (cell as ActivityProjectStatusCell, activity as Activity):
      cell.configureWith(value: activity)
    case let (cell as FindFriendsFacebookConnectCell, value as FriendsSource):
      cell.configureWith(value: value)
    case let (cell as FindFriendsHeaderCell, value as FriendsSource):
      cell.configureWith(value: value)
    case let (cell as ActivitySurveyResponseCell, value as (SurveyResponse, Int, Int)):
      cell.configureWith(value: value)
    case (is StaticTableViewCell, is Void):
      return
    default:
      assertionFailure("Unrecognized combo: \(cell), \(value)")
    }
  }
}
