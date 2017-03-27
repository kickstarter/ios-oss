import Library
import LiveStream
import Prelude
import UIKit

internal final class LiveStreamChatDataSource: ValueCellDataSource {
  internal enum Section: Int {
    case chats
  }

  internal func add(chatMessages: [LiveStreamChatMessage]) -> [IndexPath] {
    chatMessages.forEach {
      self.prependRow(value: $0, cellClass: LiveStreamChatMessageCell.self, toSection: Section.chats.rawValue)
    }

    return (0..<chatMessages.count).map { IndexPath.init(row: $0, section: Section.chats.rawValue) }
  }

  internal var chatMessagesSection: Int {
    return Section.messages.rawValue
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
