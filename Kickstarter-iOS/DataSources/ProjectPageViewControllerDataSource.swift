import KsApi
import Library
import UIKit

internal final class ProjectPageViewControllerDataSource: ValueCellDataSource {
  internal enum Section: Int {
    case overviewCreatorHeader
    case overview
    case overviewSubpages
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

  private enum HeaderValue {
    case overview
    case environmentalCommitments
    case faqs
    case risks

    var description: String {
      switch self {
      case .overview:
        return Strings.Overview()
      case .environmentalCommitments:
        return Strings.Environmental_Commitments()
      case .faqs:
        return Strings.Frequently_asked_questions()
      case .risks:
        return Strings.Risks()
      }
    }
  }

  func load(
    navigationSection: NavigationSection,
    project: Project,
    refTag: RefTag?,
    isExpandedStates: [Bool]? = nil
  ) {
    // Clear all sections
    self.clearValues()

    switch navigationSection {
    case .overview:
      if currentUserIsCreator(of: project) {
        self.set(
          values: [project],
          cellClass: ProjectPamphletCreatorHeaderCell.self,
          inSection: Section.overviewCreatorHeader.rawValue
        )
      }

      self.set(
        values: [(project, refTag)],
        cellClass: ProjectPamphletMainCell.self,
        inSection: Section.overview.rawValue
      )

      let values: [ProjectPamphletSubpage] = [
        .comments(project.stats.commentsCount as Int?, .first),
        .updates(project.stats.updatesCount as Int?, .last)
      ]

      self.set(
        values: values,
        cellClass: ProjectPamphletSubpageCell.self,
        inSection: Section.overviewSubpages.rawValue
      )
    case .campaign:
      return
    case .faq:
      self.set(
        values: [HeaderValue.faqs.description],
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

      let projectFAQs = project.extendedProjectProperties?.faqs ?? []

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
      // Risks are mandatory for creators
      let risks = project.extendedProjectProperties?.risks ?? ""

      self.set(
        values: [HeaderValue.risks.description],
        cellClass: ProjectHeaderCell.self,
        inSection: Section.risksHeader.rawValue
      )

      self.set(
        values: [risks],
        cellClass: ProjectRisksCell.self,
        inSection: Section.risks.rawValue
      )

      self.set(
        values: [()],
        cellClass: ProjectRisksDisclaimerCell.self,
        inSection: Section.risksDisclaimer.rawValue
      )
    case .environmentalCommitments:
      let environmentalCommitments = project.extendedProjectProperties?.environmentalCommitments ?? []

      self.set(
        values: [HeaderValue.environmentalCommitments.description],
        cellClass: ProjectHeaderCell.self,
        inSection: Section.environmentalCommitmentsHeader.rawValue
      )

      self.set(
        values: environmentalCommitments,
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
    case let (cell as ProjectPamphletCreatorHeaderCell, value as Project):
      cell.configureWith(value: value)
    case let (cell as ProjectPamphletMainCell, value as ProjectPamphletMainCellData):
      cell.configureWith(value: value)
    case let (cell as ProjectPamphletSubpageCell, value as ProjectPamphletSubpage):
      cell.configureWith(value: value)
    case let (cell as ProjectRisksCell, value as String):
      cell.configureWith(value: value)
    case let (cell as ProjectRisksDisclaimerCell, _):
      cell.configureWith(value: ())
    default:
      assertionFailure("Unrecognized combo: \(cell), \(value)")
    }
  }

  internal func indexPathIsCommentsSubpage(_ indexPath: IndexPath) -> Bool {
    return (self[indexPath] as? ProjectPamphletSubpage)?.isComments == true
  }

  internal func indexPathIsUpdatesSubpage(_ indexPath: IndexPath) -> Bool {
    return (self[indexPath] as? ProjectPamphletSubpage)?.isUpdates == true
  }

  internal func isExpandedValuesForFAQsSection() -> [Bool]? {
    guard let values = self[section: Section.faqs.rawValue] as? [(ProjectFAQ, Bool)] else { return nil }
    return values.map { _, isExpanded in isExpanded }
  }
}
