import Library
import KsApi
import UIKit

internal final class DiscoveryProjectsDataSource: ValueCellDataSource {
  internal enum Section: Int {
    case onboarding
    case activitySample
    case projects
  }

  func load(activities: [Activity]) {
    let section = Section.activitySample.rawValue

    self.clearValues(section: section)

    activities.forEach { activity in
      switch activity.category {
      case .backing:
        self.set(values: [activity], cellClass: ActivitySampleBackingCell.self, inSection: section)
      case .follow:
        self.set(values: [activity], cellClass: ActivitySampleFollowCell.self, inSection: section)
      default:
        self.set(values: [activity], cellClass: ActivitySampleProjectCell.self, inSection: section)
      }
    }
  }

  func load(projects: [Project]) {
    self.clearValues(section: Section.projects.rawValue)

    projects.forEach { project in
      self.appendRow(
        value: project,
        cellClass: DiscoveryPostcardCell.self,
        toSection: Section.projects.rawValue
      )
    }
  }

  func show(onboarding: Bool) {
    self.set(values: onboarding ? [()] : [],
             cellClass: DiscoveryOnboardingCell.self,
             inSection: Section.onboarding.rawValue)
  }

  internal func activityAtIndexPath(_ indexPath: IndexPath) -> Activity? {
    return self[indexPath] as? Activity
  }

  internal func projectAtIndexPath(_ indexPath: IndexPath) -> Project? {
    return self[indexPath] as? Project
  }

  internal func indexPath(for projectRow: Int) -> IndexPath {
    return IndexPath(item: projectRow, section: Section.projects.rawValue)
  }

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {

    switch (cell, value) {
    case let (cell as ActivitySampleBackingCell, value as Activity):
      cell.configureWith(value: value)
    case let (cell as ActivitySampleFollowCell, value as Activity):
      cell.configureWith(value: value)
    case let (cell as ActivitySampleProjectCell, value as Activity):
      cell.configureWith(value: value)
    case let (cell as DiscoveryPostcardCell, value as Project):
      cell.configureWith(value: value)
    case let (cell as DiscoveryOnboardingCell, value as Void):
      cell.configureWith(value: value)
    case (is StaticTableViewCell, is Void):
      return
    default:
      assertionFailure("Unrecognized combo: \(cell), \(value)")
    }
  }
}
