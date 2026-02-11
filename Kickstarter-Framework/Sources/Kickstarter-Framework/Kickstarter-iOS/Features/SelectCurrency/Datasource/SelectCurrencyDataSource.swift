import KsApi
import Library
import UIKit

internal final class SelectCurrencyDataSource: ValueCellDataSource {
  internal enum Section: Int {
    case currencies
  }

  internal func load(currencies: [SelectedCurrencyData]) {
    self.set(
      values: currencies,
      cellClass: SelectCurrencyCell.self,
      inSection: Section.currencies.rawValue
    )
  }

  internal override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as SelectCurrencyCell, value as SelectedCurrencyData):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized combo: \(cell), \(value).")
    }
  }
}
