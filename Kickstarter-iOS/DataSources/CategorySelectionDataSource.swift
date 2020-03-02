import Foundation
import KsApi
import Library
import UIKit

internal final class CategorySelectionDataSource: ValueCellDataSource {
  private var categorySectionTitles: [String] = []
  func load(_ sectionTitles: [String], categories: [[(String, PillCellStyle)]]) {
    self.categorySectionTitles = sectionTitles

    for (index, subcategories) in categories.enumerated() {
      self.set(values: subcategories, cellClass: PillCell.self, inSection: index)
    }
  }

  override func configureCell(collectionCell cell: UICollectionViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as PillCell, value as (String, PillCellStyle)):
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
