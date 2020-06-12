import KsApi
import Library
import UIKit

internal final class DiscoveryProjectsDataSource: ValueCellDataSource {
  internal enum Section: Int {
    case onboarding
    case personalization
    case editorial
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

  func load(projects: [Project],
            params: DiscoveryParams? = nil,
            projectCardVariant: OptimizelyExperiment.Variant = .control) {
    self.clearValues(section: Section.projects.rawValue)

    let values = projects.map { DiscoveryProjectCellRowValue(
      project: $0,
      category: params?.category,
      params: params
    ) }

    if projectCardVariant == .variant1 {
      self.set(
        values: values,
        cellClass: DiscoveryProjectCardCell.self,
        inSection: Section.projects.rawValue
      )
    } else {
      self.set(
        values: values,
        cellClass: DiscoveryPostcardCell.self,
        inSection: Section.projects.rawValue
      )
    }
  }

  func showEditorial(value: DiscoveryEditorialCellValue?) {
    self.set(
      values: [value].compactMap { $0 },
      cellClass: DiscoveryEditorialCell.self,
      inSection: Section.editorial.rawValue
    )
  }

  func show(onboarding: Bool) {
    self.set(
      values: onboarding ? [()] : [],
      cellClass: DiscoveryOnboardingCell.self,
      inSection: Section.onboarding.rawValue
    )
  }

  func showPersonalization(_ show: Bool) {
    self.set(
      values: show ? [()] : [],
      cellClass: PersonalizationCell.self,
      inSection: Section.personalization.rawValue
    )
  }

  internal func activityAtIndexPath(_ indexPath: IndexPath) -> Activity? {
    return self[indexPath] as? Activity
  }

  internal func projectAtIndexPath(_ indexPath: IndexPath) -> Project? {
    return (self[indexPath] as? DiscoveryProjectCellRowValue)?.project
  }

  internal func indexPath(forProjectRow row: Int) -> IndexPath {
    return IndexPath(item: row, section: Section.projects.rawValue)
  }

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as ActivitySampleBackingCell, value as Activity):
      cell.configureWith(value: value)
    case let (cell as ActivitySampleFollowCell, value as Activity):
      cell.configureWith(value: value)
    case let (cell as ActivitySampleProjectCell, value as Activity):
      cell.configureWith(value: value)
    case let (cell as DiscoveryPostcardCell, value as DiscoveryProjectCellRowValue):
      cell.configureWith(value: value)
    case let (cell as DiscoveryProjectCardCell, value as DiscoveryProjectCellRowValue):
      cell.configureWith(value: value)
    case let (cell as DiscoveryOnboardingCell, value as Void):
      cell.configureWith(value: value)
    case let (cell as DiscoveryEditorialCell, value as DiscoveryEditorialCellValue):
      cell.configureWith(value: value)
    case let (cell as PersonalizationCell, value as Void):
      cell.configureWith(value: value)
    case (is StaticTableViewCell, is Void):
      return
    default:
      assertionFailure("Unrecognized combo: \(cell), \(value)")
    }
  }
}
