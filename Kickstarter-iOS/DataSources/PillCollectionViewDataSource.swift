import Foundation
import Library
import UIKit

final class PillCollectionViewDataSource: ValueCellDataSource {
  func load(_ values: [(String, PillCellStyle)]) {
    let indexedValues = values.map { value -> (String, PillCellStyle, IndexPath?) in
      return (value.0, value.1, nil)
    }

    self.set(
      values: indexedValues,
      cellClass: PillCell.self,
      inSection: 0
    )
  }

  override func configureCell(collectionCell cell: UICollectionViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as PillCell, value as (String, PillCellStyle, IndexPath?)):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized (cell, value) combo.")
    }
  }
}
