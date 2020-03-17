import Foundation
import Library
import UIKit

final class PillCollectionViewDataSource: ValueCellDataSource {
  func load(_ values: [String]) {
    self.set(
      values: values,
      cellClass: PillCell.self,
      inSection: 0
    )
  }

  override func configureCell(collectionCell cell: UICollectionViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as PillCell, value as String):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized (cell, value) combo.")
    }
  }
}
