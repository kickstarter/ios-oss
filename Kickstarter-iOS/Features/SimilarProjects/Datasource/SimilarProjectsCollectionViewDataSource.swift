import Foundation
import KsApi
import Library
import UIKit

final class SimilarProjectsCollectionViewDataSource: ValueCellDataSource {
  func load(_ values: [any SimilarProject], isLoading: Bool = false) {
    guard isLoading == false else {
      return self.set(
        values: [(), ()],
        cellClass: SimilarProjectsLoadingCollectionViewCell.self,
        inSection: 0
      )
    }

    self.set(
      values: values,
      cellClass: SimilarProjectsCollectionViewCell.self,
      inSection: 0
    )
  }

  override func configureCell(collectionCell cell: UICollectionViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as SimilarProjectsLoadingCollectionViewCell, value as Void):
      cell.configureWith(value: value)
    case let (cell as SimilarProjectsCollectionViewCell, value as any SimilarProject):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized (cell, value) combo.")
    }
  }
}
