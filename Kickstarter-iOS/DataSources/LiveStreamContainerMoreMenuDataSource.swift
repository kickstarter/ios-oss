import Library
import LiveStream
import Prelude
import UIKit

fileprivate enum Section: Int {
  case items
}

internal final class LiveStreamContainerMoreMenuDataSource: ValueCellDataSource {
  internal func load(items: [LiveStreamContainerMoreMenuItem]) {
    self.set(values: items,
             cellClass: LiveStreamContainerMoreMenuCell.self,
             inSection: Section.items.rawValue)
  }

  internal override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as LiveStreamContainerMoreMenuCell, value as LiveStreamContainerMoreMenuItem):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized combo: \(cell), \(value)")
    }
  }
}
