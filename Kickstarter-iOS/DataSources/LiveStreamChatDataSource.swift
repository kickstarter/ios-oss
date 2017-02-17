import Library
import LiveStream
import Prelude
import UIKit

internal final class LiveStreamChatDataSource: ValueCellDataSource {
  internal override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as LiveStreamChatMessageCell, value as LiveStreamChatMessage):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized combo: \(cell), \(value)")
    }
  }
}
