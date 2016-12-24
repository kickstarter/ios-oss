import Library
import KsApi
import UIKit

internal final class ProjectActivitiesDataSource: ValueCellDataSource {

  internal enum Section: Int {
    case emptyState
    case activities
  }

  internal func emptyState(visible: Bool) {
    self.set(values: visible ? [()] : [],
             cellClass: ProjectActivityEmptyStateCell.self,
             inSection: Section.emptyState.rawValue)
  }

  internal func load(projectActivityData: ProjectActivityData) {
    let section = Section.activities.rawValue

    self.clearValues(section: section)

    projectActivityData.activities
      .groupedBy { activity in
        return AppEnvironment.current.calendar.startOfDayForDate(
          Date(timeIntervalSince1970: activity.createdAt)
        )
      }
      .sort { $0.0.timeIntervalSince1970 > $1.0.timeIntervalSince1970 }
      .forEach { date, activitiesForDate in

        if projectActivityData.groupedDates {
          appendDateRow(date: date, section: section)
        }

        activitiesForDate
          .sorted(comparator: Activity.lens.createdAt.comparator.reversed)
          .forEach { activity in
            if !projectActivityData.groupedDates {
              appendDateRow(date: date, section: section)
            }
            appendActivityRow(activity: activity, project: projectActivityData.project, section: section)
        }
    }
  }

  internal override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {

    switch (cell, value) {
    case let (cell as ProjectActivityBackingCell, value as (Activity, Project)):
      cell.configureWith(value: value)
    case let (cell as ProjectActivityCommentCell, value as (Activity, Project)):
      cell.configureWith(value: value)
    case let (cell as ProjectActivityDateCell, value as Date):
      cell.configureWith(value: value)
    case let (cell as ProjectActivityEmptyStateCell, value as Void):
      cell.configureWith(value: value)
    case let (cell as ProjectActivityLaunchCell, value as (Activity, Project)):
      cell.configureWith(value: value)
    case let (cell as ProjectActivityNegativeStateChangeCell, value as (Activity, Project)):
      cell.configureWith(value: value)
    case let (cell as ProjectActivitySuccessCell, value as (Activity, Project)):
      cell.configureWith(value: value)
    case let (cell as ProjectActivityUpdateCell, value as (Activity, Project)):
      cell.configureWith(value: value)
    case (is StaticTableViewCell, is Void):
      return
    default:
      assertionFailure("Unrecognized combo: \(cell), \(value)")
    }
  }

  internal func appendDateRow(date: Date, section: Int) {
    self.appendRow(value: date, cellClass: ProjectActivityDateCell.self, toSection: section)
  }

  internal func appendActivityRow(activity: Activity, project: Project, section: Int) {
    switch activity.category {
    case .backing, .backingAmount, .backingCanceled, .backingReward:
      self.appendRow(
        value: (activity, project),
        cellClass: ProjectActivityBackingCell.self,
        toSection: section
      )
    case .cancellation, .failure, .suspension:
      self.appendRow(
        value: (activity, project),
        cellClass: ProjectActivityNegativeStateChangeCell.self,
        toSection: section
      )
    case .commentPost, .commentProject:
      self.appendRow(
        value: (activity, project),
        cellClass: ProjectActivityCommentCell.self,
        toSection: section
      )
    case .launch:
      self.appendRow(
        value: (activity, project),
        cellClass: ProjectActivityLaunchCell.self,
        toSection: section
      )
    case .success:
      self.appendRow(
        value: (activity, project),
        cellClass: ProjectActivitySuccessCell.self,
        toSection: section
      )
    case .update:
      self.appendRow(
        value: (activity, project),
        cellClass: ProjectActivityUpdateCell.self,
        toSection: section
      )
    case .backingDropped, .follow, .funding, .watch, .unknown:
      assertionFailure("Unsupported activity: \(activity)")
    }
  }

  internal func activityAndProjectAtIndexPath(_ indexPath: NSIndexPath) -> (Activity, Project)? {
    guard let value = self[indexPath as IndexPath] as? (Activity, Project) else { return nil }
    return value
  }
}
