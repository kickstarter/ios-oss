import Foundation
import KsApi
import Library
import UIKit

internal final class ProjectSummaryCarouselDataSource: ValueCellDataSource {
  internal enum Section: Int {
    case summary
  }

  func load(_ values: [ProjectSummaryEnvelope.ProjectSummaryItem]) {
    self.set(
      values: values,
      cellClass: ProjectSummaryCarouselCell.self,
      inSection: Section.summary.rawValue
    )
  }

  override func configureCell(collectionCell cell: UICollectionViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as ProjectSummaryCarouselCell, value as ProjectSummaryEnvelope.ProjectSummaryItem):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized (cell, value) combo.")
    }
  }
}
