import Library
import LiveStream
import Prelude
import UIKit

private enum Section: Int {
  case messages
}

internal final class LiveStreamChatDataSource: ValueCellDataSource {
  internal func add(_ chatMessages: [LiveStreamChatMessage]) -> [IndexPath] {
    let indexPaths = chatMessages.map {
      self.prependRow(value: $0, cellClass:
        LiveStreamChatMessageCell.self, toSection: Section.messages.rawValue)
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

  internal var chatMessagesSection: Int {
    return Section.messages.rawValue
  }
}
