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
    case risksHeader
    case risks
    case risksDisclaimer
    case environmentalCommitmentsHeader
    case environmentalCommitments
    case environmentalCommitmentsDisclaimer
  }

  // TODO: Internationalize strings
  private enum HeaderValue: String {
    case environmentalCommitments = "Environmental commitments"
    case faqs = "Frequently asked questions"
    case risks = "Risks and challenges"
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
        values: [HeaderValue.faqs.rawValue],
        cellClass: ProjectHeaderCell.self,
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

      guard let isExpandedStates = isExpandedStates else { return }

      let values = projectFAQs.enumerated().map { idx, faq in
        (faq, isExpandedStates[idx])
      }

      self.set(
        values: values,
        cellClass: ProjectFAQsCell.self,
        inSection: Section.faqs.rawValue
      )
    case .risks:
      self.set(
        values: [HeaderValue.risks.rawValue],
        cellClass: ProjectHeaderCell.self,
        inSection: Section.risksHeader.rawValue
      )

      self.set(
        values: [projectProperties.risks],
        cellClass: ProjectRisksCell.self,
        inSection: Section.risks.rawValue
      )

      self.set(
        values: [()],
        cellClass: ProjectRisksDisclaimerCell.self,
        inSection: Section.risksDisclaimer.rawValue
      )
    case .environmentalCommitments:
      self.set(
        values: [HeaderValue.environmentalCommitments.rawValue],
        cellClass: ProjectHeaderCell.self,
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
    case let (cell as ProjectHeaderCell, value as String):
      cell.configureWith(value: value)
    case let (cell as ProjectFAQsAskAQuestionCell, _):
      cell.configureWith(value: ())
    case let (cell as ProjectFAQsCell, value as (ProjectFAQ, Bool)):
      cell.configureWith(value: value)
    case let (cell as ProjectFAQsEmptyStateCell, _):
      cell.configureWith(value: ())
    case let (cell as ProjectRisksCell, value as String):
      cell.configureWith(value: value)
    case let (cell as ProjectRisksDisclaimerCell, _):
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
