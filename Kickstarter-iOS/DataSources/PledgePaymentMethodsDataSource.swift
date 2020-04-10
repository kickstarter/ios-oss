import KsApi
import Library
import Prelude
import UIKit

internal final class PledgePaymentMethodsDataSource: ValueCellDataSource {
  internal func load(_ cards: [PledgePaymentMethodCellData]) {
    self.set(
      values: cards,
      cellClass: PledgePaymentMethodCell.self,
      inSection: PaymentMethodsTableViewSection.paymentMethods.rawValue
    )

    self.set(
      values: [()],
      cellClass: PledgePaymentMethodAddCell.self,
      inSection: PaymentMethodsTableViewSection.addNewCard.rawValue
    )
  }

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as PledgePaymentMethodCell, value as PledgePaymentMethodCellData):
      cell.configureWith(value: value)
    case let (cell as PledgePaymentMethodAddCell, value as Void):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized combo: \(cell), \(value)")
    }
  }
}
