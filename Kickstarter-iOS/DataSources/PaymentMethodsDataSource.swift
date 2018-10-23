import KsApi
import Library
import UIKit

final class PaymentMethodsDataSource: ValueCellDataSource {

  func load(creditCards: [GraphUserCreditCard.CreditCard]) {

    self.set(values: creditCards,
             cellClass: CreditCardCell.self,
             inSection: 0)
  }

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as CreditCardCell, value as GraphUserCreditCard.CreditCard):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized (cell, viewModel) combo.")
    }
  }
}
