import Library
import LiveStream
import Prelude
import UIKit

internal final class LiveStreamChatDataSource: ValueCellDataSource {
  internal func add(_ chatMessages: [LiveStreamChatMessage], toSection section: Int) -> [IndexPath] {
    let indexPaths = chatMessages.map {
      self.prependRow(value: $0, cellClass:
        LiveStreamChatMessageCell.self, toSection: section)
    }

    return indexPaths
  }

  internal override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as LiveStreamChatMessageCell, value as LiveStreamChatMessage):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized combo: \(cell), \(value)")
    }
  }
}
