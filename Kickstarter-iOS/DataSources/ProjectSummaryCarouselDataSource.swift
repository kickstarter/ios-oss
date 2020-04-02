import Foundation
import KsApi
import Library
import UIKit

internal final class ProjectSummaryCarouselDataSource: ValueCellDataSource {
  public private(set) var greatestCombinedTextHeight: CGFloat = 0

  internal enum Section: Int {
    case summary
  }

  func load(_ values: [ProjectSummaryEnvelope.ProjectSummaryItem]) {
    self.greatestCombinedTextHeight = self.greatestCombinedTextHeightForItems(values)

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

  private func greatestCombinedTextHeightForItems(
    _ items: [ProjectSummaryEnvelope.ProjectSummaryItem]
  ) -> CGFloat {
    return items.reduce(0) { (current, item) -> CGFloat in
      let size = CGSize(
        width: ProjectSummaryCarouselCell.Layout.MaxInnerWidth.size,
        height: .greatestFiniteMagnitude / 2
      )

      let titleHeight = (item.question.rawValue as NSString).boundingRect(
        with: size,
        options: [.usesLineFragmentOrigin, .usesFontLeading],
        attributes: [.font: ProjectSummaryCarouselCell.Style.Title.font()],
        context: nil
      )
      .height

      let bodyHeight = (item.response as NSString).boundingRect(
        with: size,
        options: [.usesLineFragmentOrigin, .usesFontLeading],
        attributes: [.font: ProjectSummaryCarouselCell.Style.Body.font()],
        context: nil
      )
      .height

      let totalHeight = titleHeight + bodyHeight

      return max(current, ceil(totalHeight))
    }
  }
}
