import KsApi
import Library
import Prelude
import UIKit

internal final class PledgePaymentMethodsDataSource: ValueCellDataSource {
  fileprivate enum Section: Int {
    case paymentMethods
    case addNewCard
    case loading
  }

  internal func load(_ cards: [PledgePaymentMethodCellData]) {
    self.set(
      values: cards,
      cellClass: PledgePaymentMethodCell.self,
      inSection: Section.paymentMethods.rawValue
    )
  }

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as PledgePaymentMethodCell, value as PledgePaymentMethodCellData):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized combo: \(cell), \(value)")
    }
  }
}
