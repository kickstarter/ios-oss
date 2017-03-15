import Library
import LiveStream
import Prelude
import UIKit

fileprivate enum Section: Int {
  case items
}

internal final class LiveStreamContainerMoreMenuDataSource: ValueCellDataSource {
  internal func load(items: [LiveStreamContainerMoreMenuItem]) {

    items.forEach { menuItem in
      switch menuItem {
      case .hideChat, .share:
        self.appendRow(value: menuItem,
                       cellClass: LiveStreamContainerMoreMenuIconTextCell.self,
                       toSection: Section.items.rawValue)
      case .cancel:
        self.appendRow(value: menuItem,
                       cellClass: LiveStreamContainerMoreMenuCancelCell.self,
                       toSection: Section.items.rawValue)
      }
    }
  }

  internal override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as LiveStreamContainerMoreMenuIconTextCell, value as LiveStreamContainerMoreMenuItem):
      cell.configureWith(value: value)
    case let (cell as LiveStreamContainerMoreMenuCancelCell, value as LiveStreamContainerMoreMenuItem):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized combo: \(cell), \(value)")
    }
  }
}
