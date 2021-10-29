import KsApi
import Library
import UIKit

internal final class ProjectEnvironmentalCommitmentsDataSource: ValueCellDataSource {
  internal enum Section: Int {
    case environmentalCommitments
    case footer
  }

  func load(environmentalCommitments: [ProjectEnvironmentalCommitment]) {
    // Clear all sections
    self.clearValues()

    self.set(
      values: environmentalCommitments,
      cellClass: ProjectEnvironmentalCommitmentCell.self,
      inSection: Section.environmentalCommitments.rawValue
    )

    self.set(
      values: [()],
      cellClass: ProjectEnvironmentalCommitmentFooterCell.self,
      inSection: Section.footer.rawValue
    )
  }

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as ProjectEnvironmentalCommitmentCell, value as ProjectEnvironmentalCommitment):
      cell.configureWith(value: value)
    case let (cell as ProjectEnvironmentalCommitmentFooterCell, _):
      cell.configureWith(value: ())
    default:
      assertionFailure("Unrecognized combo: \(cell), \(value)")
    }
  }
}
