import Foundation
import KsApi
import Library
import UIKit

internal final class CategorySelectionDataSource: ValueCellDataSource {
  func load(_ categories: [KsApi.Category]) {
    for (index, parent) in categories.enumerated() {
      let subcategories = parent.subcategories?.nodes.compactMap { ($0.name, PillCellStyle.grey) } ?? []
      let allCategories = [("All \(parent.name) Projects", .grey)] + subcategories

      self.set(values: allCategories, cellClass: PillCell.self, inSection: index)
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

  func collectionView(
    _ collectionView: UICollectionView,
    viewForSupplementaryElementOfKind kind: String,
    at indexPath: IndexPath
  ) -> UICollectionReusableView {
    let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "suppView", for: indexPath)
    view.backgroundColor = .red
    return view
  }
}

public class SuppView: UICollectionReusableView {}
