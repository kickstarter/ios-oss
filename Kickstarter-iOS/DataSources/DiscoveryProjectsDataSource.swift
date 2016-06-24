import Library
import KsApi
import UIKit

internal final class DiscoveryProjectsDataSource: ValueCellDataSource {
  internal enum Section: Int {
    case onboarding
    case projects
  }

  func load(projects projects: [Project]) {
    self.clearValues(section: Section.projects.rawValue)

    projects.forEach { project in
      self.appendRow(
        value: project,
        cellClass: DiscoveryProjectCell.self,
        toSection: Section.projects.rawValue
      )
      self.appendStaticRow(cellIdentifier: "Padding", toSection: Section.projects.rawValue)
    }
  }

  func show(onboarding onboarding: Bool) {
    self.set(values: onboarding ? [()] : [],
             cellClass: DiscoveryOnboardingCell.self,
             inSection: Section.onboarding.rawValue)
  }

  internal func projectAtIndexPath(indexPath: NSIndexPath) -> Project? {
    return self[indexPath] as? Project
  }

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {

    switch (cell, value) {
    case let (cell as DiscoveryProjectCell, value as Project):
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
