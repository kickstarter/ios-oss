import Foundation
import KsApi
import Library
import UIKit

internal final class CategorySelectionDataSource: ValueCellDataSource {
  private var categorySectionTitles: [String] = []

  func load(_ sectionTitles: [String], categories: [[(String, PillCellStyle)]]) {
    self.categorySectionTitles = sectionTitles

    for (section, subcategories) in categories.enumerated() {
      let indexedSubcategories = subcategories.enumerated().map { index, value in
        return (value.0, value.1, IndexPath(item: index, section: section))
      }

      self.set(values: indexedSubcategories, cellClass: PillCell.self, inSection: section)
    }
  }

  override func configureCell(collectionCell cell: UICollectionViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as PillCell, value as (String, PillCellStyle, IndexPath)):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized (cell, value) combo.")
    }
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
