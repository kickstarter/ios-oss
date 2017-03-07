import Library
import KsApi
import UIKit

internal final class ProfileBackedProjectsDataSource: ValueCellDataSource {
  internal enum Section: Int {
    case emptyState
  }

  internal func emptyState(visible: Bool, message: String, showIcon: Bool) {
    self.set(values: visible ? [(message, showIcon)] : [],
             cellClass: ProfileEmptyStateCell.self,
             inSection: Section.emptyState.rawValue)
  }

  internal override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {

    switch (cell, value) {
    case let (cell as ProfileEmptyStateCell, value as (String, Bool)):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized (cell, viewModel) combo.")
    }
  }
}
