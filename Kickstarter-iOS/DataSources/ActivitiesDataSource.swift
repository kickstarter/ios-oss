import KsApi
import Library
import Prelude
import UIKit

internal final class ActivitiesDataSource: ValueCellDataSource {
  internal enum Section: Int {
    case survey
    case facebookConnect
    case findFriends
    case activities
  }

  internal func facebookConnect(source source: FriendsSource, visible: Bool) {
    self.set(values: visible ? [source] : [],
             cellClass: FindFriendsFacebookConnectCell.self,
             inSection: Section.facebookConnect.rawValue)

    if visible {
      self.appendStaticRow(cellIdentifier: "HalfPaddingCell", toSection: Section.facebookConnect.rawValue)
    }
  }

  internal func findFriends(source source: FriendsSource, visible: Bool) {
    self.set(values: visible ? [source] : [],
             cellClass: FindFriendsHeaderCell.self,
             inSection: Section.findFriends.rawValue)

    if visible {
      self.appendStaticRow(cellIdentifier: "HalfPaddingCell", toSection: Section.findFriends.rawValue)
    }
  }

  internal func removeFacebookConnectRows() -> [NSIndexPath] {
    self.clearValues(section: Section.facebookConnect.rawValue)

    return [NSIndexPath(forRow: 0, inSection: Section.facebookConnect.rawValue),
            NSIndexPath(forRow: 1, inSection: Section.facebookConnect.rawValue)]
  }

  internal func removeFindFriendsRows() -> [NSIndexPath] {
    self.clearValues(section: Section.findFriends.rawValue)

    return [NSIndexPath(forRow: 0, inSection: Section.findFriends.rawValue),
            NSIndexPath(forRow: 1, inSection: Section.findFriends.rawValue)]
  }

  internal func load(surveyResponse surveyResponse: SurveyResponse?) {

    if let response = surveyResponse {
      self.set(values: [response],
               cellClass: ActivitySurveyResponseCell.self,
               inSection: Section.survey.rawValue)
      self.appendStaticRow(cellIdentifier: "HalfPaddingCell", toSection: Section.survey.rawValue)
    } else {
      self.set(values: [],
               cellClass: ActivitySurveyResponseCell.self,
               inSection: Section.survey.rawValue)
    }
  }

  internal func load(activities activities: [Activity]) {
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

// swiftlint:disable cyclomatic_complexity
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
    case let (cell as ActivitySurveyResponseCell, value as SurveyResponse):
      cell.configureWith(value: value)
    case (is StaticTableViewCell, is Void):
      return
    default:
      assertionFailure("Unrecognized combo: \(cell), \(value)")
    }
  }
// swiftlint:enable cyclomatic_complexity
}
