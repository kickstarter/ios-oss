import Foundation
import KsApi
import Library
import UIKit

internal final class CategorySelectionDataSource: ValueCellDataSource {
  private var categorySectionTitles: [String] = []

  weak var collectionView: UICollectionView?

  func load(_ sectionTitles: [String], categories: [[CategorySectionData]]) {
    self.categorySectionTitles = sectionTitles

    for (section, subcategories) in categories.enumerated() {
      let indexedSubcategories = subcategories.enumerated().map { index, value in
        CategoryPillCellValue(
          name: value.displayName,
          category: value.category,
          indexPath: IndexPath(item: index, section: section)
        )
      }

      self.set(values: indexedSubcategories, cellClass: CategoryPillCell.self, inSection: section)
    }
  }

  override func configureCell(collectionCell cell: UICollectionViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as CategoryPillCell, value as CategoryPillCellValue):
      cell.configureWith(value: value)

      self.configureCellWidth(cell)
    default:
      assertionFailure("Unrecognized (cell, value) combo.")
    }
  }

  private func configureCellWidth(_ cell: CategoryPillCell) {
    guard let collectionView = self.collectionView else { return }
    let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
    let leftRightInsets = (layout?.sectionInset.left ?? 0) + (layout?.sectionInset.right ?? 0)

    cell.buttonWidthConstraint?.constant = collectionView.bounds.width - leftRightInsets
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    viewForSupplementaryElementOfKind kind: String,
    at indexPath: IndexPath
  ) -> UICollectionReusableView {
    guard let view = collectionView
      .dequeueReusableSupplementaryView(
        ofKind: kind,
        withReuseIdentifier: CategoryCollectionViewSectionHeaderView.defaultReusableId,
        for: indexPath
      ) as? CategoryCollectionViewSectionHeaderView else {
      assertionFailure("Unknown supplementary view type")
      return UICollectionReusableView(frame: .zero)
    }

    view.configure(with: self.categorySectionTitles[indexPath.section])

    return view
  }
}
