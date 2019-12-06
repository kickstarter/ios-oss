import Foundation
import KsApi
import Library
import UIKit

final class ErroredBackingsDataSource: ValueCellDataSource {
  // MARK: - Load

  func load(_ values: [GraphBacking]) {
    self.set(
      values: values,
      cellClass: ErroredBackingCell.self,
      inSection: 0
    )
  }

  // MARK: - Configure

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as ErroredBackingCell, value as GraphBacking):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized (cell, viewModel) combo.")
    }
  }
}
