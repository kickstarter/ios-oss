import Library
import KsApi

internal final class MessageThreadsDataSource: ValueCellDataSource {
  fileprivate enum Section: Int {
    case emptyState
    case messageThreads
  }

  internal static let emptyStateCellIdentifier = String(describing: MessageThreadEmptyStateCell.self)

  internal func load(messageThreads: [MessageThread]) {
    self.set(values: messageThreads,
             cellClass: MessageThreadCell.self,
             inSection: Section.messageThreads.rawValue)
  }

  internal func emptyState(isVisible: Bool) {
    self.set(cellIdentifiers: isVisible ? [MessageThreadsDataSource.emptyStateCellIdentifier] : [],
             inSection: Section.emptyState.rawValue)
  }

  internal override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {

    switch (cell, value) {
    case let (cell as MessageThreadCell, value as MessageThread):
      cell.configureWith(value: value)
    case (is MessageThreadEmptyStateCell, is Void):
      return
    default:
      assertionFailure("Unrecognized combo: \(cell), \(value).")
    }
  }
}
