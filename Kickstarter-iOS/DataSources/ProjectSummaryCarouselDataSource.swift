import Foundation
import KsApi
import Library
import UIKit

internal final class ProjectSummaryCarouselDataSource: ValueCellDataSource {
  public private(set) var greatestCombinedTextHeight: CGFloat = 0

  internal enum Section: Int {
    case summary
  }

  func load(_ values: [ProjectSummaryItem]) {
    // TODO: iterate over values, calculate greatest item height and cache it

    self.greatestCombinedTextHeight = 300

    self.set(
      values: values,
      cellClass: ProjectSummaryCarouselCell.self,
      inSection: Section.summary.rawValue
    )
  }

  override func configureCell(collectionCell cell: UICollectionViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as ProjectSummaryCarouselCell, value as Int):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized (cell, value) combo.")
    }
  }
}
