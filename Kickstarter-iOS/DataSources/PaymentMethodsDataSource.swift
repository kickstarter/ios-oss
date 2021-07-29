import KsApi
import Library
import UIKit

final class PaymentMethodsDataSource: ValueCellDataSource {
  public var deletionHandler: ((UserCreditCards.CreditCard) -> Void)?

  func load(creditCards: [UserCreditCards.CreditCard]) {
    self.set(
      values: creditCards,
      cellClass: CreditCardCell.self,
      inSection: 0
    )
  }

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as CreditCardCell, value as UserCreditCards.CreditCard):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized (cell, viewModel) combo.")
    }
  }

  func tableView(
    _ tableView: UITableView, commit _: UITableViewCell.EditingStyle,
    forRowAt indexPath: IndexPath
  ) {
    guard let creditCard = self[indexPath] as? UserCreditCards.CreditCard else { return }

    _ = self.deleteRow(
      value: creditCard, cellClass: CreditCardCell.self,
      atIndex: indexPath.row, inSection: indexPath.section
    )
    tableView.deleteRows(at: [indexPath], with: .left)

    self.deletionHandler?(creditCard)
  }
}
