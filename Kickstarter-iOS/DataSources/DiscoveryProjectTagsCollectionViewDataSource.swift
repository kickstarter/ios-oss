import Library
import UIKit

final class DiscoveryProjectTagsCollectionViewDataSource: ValueCellDataSource {
  weak var collectionView: UICollectionView?

  func load(with tags: [DiscoveryProjectTagPillCellValue]) {
    self.set(values: tags, cellClass: DiscoveryProjectTagPillCell.self, inSection: 0)
  }

  override func configureCell(collectionCell cell: UICollectionViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as DiscoveryProjectTagPillCell, value as DiscoveryProjectTagPillCellValue):
      cell.configureWith(value: value)

      self.configureCellWidth(cell)
    default:
      assertionFailure("Unrecognized combo: \(cell), \(value)")
    }
  }

  private func configureCellWidth(_ cell: DiscoveryProjectTagPillCell) {
    guard let collectionView = self.collectionView else { return }

    let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
    let leftRightInsets = (layout?.sectionInset.left ?? 0) + (layout?.sectionInset.right ?? 0)

    cell.stackViewWidthConstraint?.constant = collectionView.bounds.width - leftRightInsets - 5
  }
}
