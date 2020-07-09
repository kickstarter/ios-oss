import Foundation
import KsApi
import Library
import Prelude
import UIKit

final class RewardAddOnSelectionDataSource: ValueCellDataSource {
  func load(_ values: [RewardAddOnCellData]) {
    self.set(
      values: values,
      cellClass: RewardAddOnCell.self,
      inSection: 0
    )
  }

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as RewardAddOnCell, value as RewardAddOnCellData):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized (cell, value) combo.")
    }
  }
}
