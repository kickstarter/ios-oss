import KsApi
import Library
import UIKit

internal final class ProjectFAQsDataSource: ValueCellDataSource {
  internal enum Section: Int {
    case empty
    case faqs
  }

  func load(project: Project) {
    // Clear all sections
    self.clearValues()

    guard let faqs = project.extendedProjectProperties?.faqs else {
      self.set(
        values: [()],
        cellClass: ProjectFAQsEmptyStateCell.self,
        inSection: Section.empty.rawValue
      )
      return
    }

    self.set(
      values: faqs,
      cellClass: ProjectFAQsCell.self,
      inSection: Section.faqs.rawValue
    )
  }

//  internal func indexPath(forProjectRow row: Int) -> IndexPath {
//    return IndexPath(item: row, section: Section.faqs.rawValue)
//  }

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as ProjectFAQsEmptyStateCell, _):
      cell.configureWith(value: ())
    case let (cell as ProjectFAQsCell, value as ProjectFAQ):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized combo: \(cell), \(value)")
    }
  }
}
