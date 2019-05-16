import Foundation
import KsApi
import Library
import UIKit

final class RewardsCollectionViewDataSource: ValueCellDataSource {
  func load(rewards: [Reward]) {
    self.set(values: rewards,
             cellClass: RewardCell.self,
             inSection: 0)
  }

  override func configureCell(collectionCell cell: UICollectionViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as RewardCell, value as Reward):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized (cell, value) combo.")
    }
  }
}
