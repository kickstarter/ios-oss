import Foundation
import KDS
import KsApi
import Library
import Prelude
import UIKit

final class RewardsCollectionViewDataSource: ValueCellDataSource {
  func load(_ values: [RewardCardViewData]) {
    self.set(
      values: values,
      cellClass: RewardCell.self,
      inSection: 0
    )
  }

  func isLoading(rewardsCount: Int) {
    let values = (0..<rewardsCount).map { _ in true }
    self.set(
      values: values,
      cellClass: RewardCardLoadingCell.self,
      inSection: 0
    )
  }

  override func configureCell(collectionCell cell: UICollectionViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as RewardCell, value as RewardCardViewData):
      cell.configureWith(value: value)
    case let (cell as RewardCardLoadingCell, value as Bool):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized (cell, value) combo.")
    }
  }
}
