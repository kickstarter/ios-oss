import Foundation
import KsApi
import Library
import UIKit

internal final class CategorySelectionDataSource: ValueCellDataSource {
  internal func load(categories: [KsApi.Category]) {
    self.set(values: categories, cellClass: CategorySelectionCell.self, inSection: 0)
  }

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as CategorySelectionCell, value as KsApi.Category):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized (cell, viewModel) combo.")
    }
  }
}
