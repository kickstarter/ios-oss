import Foundation
import KsApi
import Library
import Prelude
import UIKit

final class SimilarProjectsCollectionViewDataSource: ValueCellDataSource {
  func load(_ values: [Project]) {
    self.set(
      values: values,
      cellClass: SimilarProjectsCollectionViewCell.self,
      inSection: 0
    )
  }

  override func configureCell(collectionCell cell: UICollectionViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as SimilarProjectsCollectionViewCell, value as Project):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized (cell, value) combo.")
    }
  }
}
