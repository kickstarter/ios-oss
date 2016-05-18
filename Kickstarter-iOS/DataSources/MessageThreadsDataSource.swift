import Library
import Models

internal final class MessageThreadsDataSource: ValueCellDataSource {
  // swiftlint:disable type_name
  private enum Section: Int {
    case emptyState
    case messageThreads
  }
  // swiftlint:enable type_name

  internal func load(messageThreads messageThreads: [MessageThread]) {
    self.set(values: messageThreads,
             cellClass: MessageThreadCell.self,
             inSection: Section.messageThreads.rawValue)
  }

  internal func emptyState(isVisible isVisible: Bool) {
    self.set(cellIdentifiers: isVisible ? ["MessageThreadsEmptyState"] : [],
             inSection: Section.emptyState.rawValue)
  }

  internal override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {

    switch (cell, value) {
    case let (cell as MessageThreadCell, value as MessageThread):
      cell.configureWith(value: value)
    case (is StaticTableViewCell, is Void):
      return
    default:
      assertionFailure("Unrecognized combo: \(cell), \(value).")
    }
  }
}
