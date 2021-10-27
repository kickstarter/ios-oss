import KsApi
import Library
import UIKit

internal final class ProjectFAQsDataSource: ValueCellDataSource {
  internal enum Section: Int {
    case empty
    case faqs
    case askAQuestion
  }

  func load(projectFAQs: [ProjectFAQ], isExpandedStates: [Bool]) {
    // Clear all sections
    self.clearValues()

    // Only render this cell for logged in users
    if AppEnvironment.current.currentUser != nil {
      self.set(
        values: [()],
        cellClass: ProjectFAQsAskAQuestionCell.self,
        inSection: Section.askAQuestion.rawValue
      )
    }

    guard !projectFAQs.isEmpty else {
      self.set(
        values: [()],
        cellClass: ProjectFAQsEmptyStateCell.self,
        inSection: Section.empty.rawValue
      )

      return
    }

    let values = projectFAQs.enumerated().map { idx, faq in
      (faq, isExpandedStates[idx])
    }

    self.set(
      values: values,
      cellClass: ProjectFAQsCell.self,
      inSection: Section.faqs.rawValue
    )
  }

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as ProjectFAQsEmptyStateCell, _):
      cell.configureWith(value: ())
    case let (cell as ProjectFAQsCell, value as (ProjectFAQ, Bool)):
      cell.configureWith(value: value)
    case let (cell as ProjectFAQsAskAQuestionCell, _):
      cell.configureWith(value: ())
    default:
      assertionFailure("Unrecognized combo: \(cell), \(value)")
    }
  }

  func isExpandedValuesForFAQsSection() -> [Bool]? {
    guard let values = self[section: Section.faqs.rawValue] as? [(ProjectFAQ, Bool)] else { return nil }
    return values.map { _, isExpanded in isExpanded }
  }
}
