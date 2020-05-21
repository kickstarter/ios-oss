import Library
import UIKit

final class DiscoveryProjectTagsCollectionViewDataSource: ValueCellDataSource {
  weak var collectionView: UICollectionView?

  func load(with tags: [DiscoveryProjectTagPillCellValue]) {
    self.clearValues(section: 0)

    self.set(values: tags, cellClass: DiscoveryProjectTagPillCell.self, inSection: 0)
  }

  override func configureCell(collectionCell cell: UICollectionViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as DiscoveryProjectTagPillCell, value as DiscoveryProjectTagPillCellValue):
      self.configureCellWidth(cell)

      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized combo: \(cell), \(value)")
    }
  }

  private func configureCellWidth(_ cell: DiscoveryProjectTagPillCell) {
    guard let collectionView = self.collectionView else { return }

    let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
    let leftRightInsets = (layout?.sectionInset.left ?? 0) + (layout?.sectionInset.right ?? 0)
    let leftRightContentInsets = collectionView.contentInset.left + collectionView.contentInset.right

    cell.stackViewWidthConstraint?.constant = collectionView.bounds
      .width - leftRightInsets - leftRightContentInsets
  }
}
