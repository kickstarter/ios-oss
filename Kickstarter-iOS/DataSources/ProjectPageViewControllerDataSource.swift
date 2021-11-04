import KsApi
import Library
import UIKit

internal final class ProjectPageViewControllerDataSource: ValueCellDataSource {
  internal enum Section: Int {
    case overview
    case campaign
    case faqsHeader
    case faqsEmpty
    case faqs
    case faqsAskAQuestion
    case environmentalCommitmentsHeader
    case environmentalCommitments
    case environmentalCommitmentsDisclaimer
  }

  func load(
    navigationSection: NavigationSection,
    projectProperties: ExtendedProjectProperties,
    isExpandedStates: [Bool]? = nil
  ) {
    // Clear all sections
    self.clearValues()

    switch navigationSection {
    case .overview, .campaign:
      return
    case .faq:
      self.set(
        values: [()],
        cellClass: ProjectFAQsHeaderCell.self,
        inSection: Section.faqsHeader.rawValue
      )

      // Only render this cell for logged in users
      if AppEnvironment.current.currentUser != nil {
        self.set(
          values: [()],
          cellClass: ProjectFAQsAskAQuestionCell.self,
          inSection: Section.faqsAskAQuestion.rawValue
        )
      }

      let projectFAQs = projectProperties.faqs

      guard !projectFAQs.isEmpty else {
        self.set(
          values: [()],
          cellClass: ProjectFAQsEmptyStateCell.self,
          inSection: Section.faqsEmpty.rawValue
        )

        return
      }

      guard let _isExpandedStates = isExpandedStates else { return }

      let values = projectFAQs.enumerated().map { idx, faq in
        (faq, _isExpandedStates[idx])
      }

      self.set(
        values: values,
        cellClass: ProjectFAQsCell.self,
        inSection: Section.faqs.rawValue
      )
    case .environmentalCommitments:
      self.set(
        values: [()],
        cellClass: ProjectEnvironmentalCommitmentHeaderCell.self,
        inSection: Section.environmentalCommitmentsHeader.rawValue
      )

      self.set(
        values: projectProperties.environmentalCommitments,
        cellClass: ProjectEnvironmentalCommitmentCell.self,
        inSection: Section.environmentalCommitments.rawValue
      )

      self.set(
        values: [()],
        cellClass: ProjectEnvironmentalCommitmentDisclaimerCell.self,
        inSection: Section.environmentalCommitmentsDisclaimer.rawValue
      )
    }
  }

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as ProjectEnvironmentalCommitmentCell, value as ProjectEnvironmentalCommitment):
      cell.configureWith(value: value)
    case let (cell as ProjectEnvironmentalCommitmentDisclaimerCell, _):
      cell.configureWith(value: ())
    case let (cell as ProjectEnvironmentalCommitmentHeaderCell, _):
      cell.configureWith(value: ())
    case let (cell as ProjectFAQsAskAQuestionCell, _):
      cell.configureWith(value: ())
    case let (cell as ProjectFAQsCell, value as (ProjectFAQ, Bool)):
      cell.configureWith(value: value)
    case let (cell as ProjectFAQsEmptyStateCell, _):
      cell.configureWith(value: ())
    case let (cell as ProjectFAQsHeaderCell, _):
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
