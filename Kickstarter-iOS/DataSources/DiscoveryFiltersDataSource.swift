import Library
import UIKit

internal final class DiscoveryFiltersDataSource: ValueCellDataSource {
  internal enum Section: Int {
    case topFilters
    case favorites
    case categories
  }

  internal func load(topRows rows: [SelectableRow]) {
    self.set(values: rows,
             cellClass: DiscoverySelectableRowCell.self,
             inSection: Section.topFilters.rawValue)
  }

  internal func load(categoryRows rows: [ExpandableRow]) {
    self.set(cellIdentifiers: rows.isEmpty ? [] : ["CategorySeparator"],
             inSection: Section.categories.rawValue)

    for row in rows {
      self.appendRow(
        value: row,
        cellClass: DiscoveryExpandableRowCell.self,
        toSection: Section.categories.rawValue
      )

      if row.isExpanded {
        for selectableRow in row.selectableRows {
          self.appendRow(
            value: selectableRow,
            cellClass: DiscoveryExpandedSelectableRowCell.self,
            toSection: Section.categories.rawValue
          )
        }
      }
    }
  }

  internal func selectableRow(indexPath indexPath: NSIndexPath) -> SelectableRow? {
    return self[indexPath] as? SelectableRow
  }

  internal func expandableRow(indexPath indexPath: NSIndexPath) -> ExpandableRow? {
    return self[indexPath] as? ExpandableRow
  }

  internal override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as DiscoverySelectableRowCell, value as SelectableRow):
      cell.configureWith(value: value)
    case let (cell as DiscoveryExpandableRowCell, value as ExpandableRow):
      cell.configureWith(value: value)
    case let (cell as DiscoveryExpandedSelectableRowCell, value as SelectableRow):
      cell.configureWith(value: value)
    case (is StaticTableViewCell, is Void):
      return
    default:
      fatalError("Unrecognized combo (\(cell), \(value)).")
    }
  }
}
