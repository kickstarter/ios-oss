import Foundation
import Library
import UIKit

final class VideoFeedDataSource: ValueCellDataSource {
  func load(_ items: [VideoFeedItem]) {
    self.set(
      values: items,
      cellClass: VideoFeedCell.self,
      inSection: 0
    )
  }

  override func configureCell(collectionCell cell: UICollectionViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as VideoFeedCell, value as VideoFeedItem):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized (cell, value) combo.")
    }
  }
}
