import Foundation
import KsApi
import Library
import Prelude
import UIKit

final class PledgePaymentMethodsDataSource: ValueCellDataSource {

  func load(creditCards: [GraphUserCreditCard.CreditCard]) {
    self.set(
      values: creditCards,
      cellClass: PledgeCreditCardCell.self,
      inSection: 0
    )
  }

  override func configureCell(collectionCell cell: UICollectionViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as PledgeCreditCardCell, value as GraphUserCreditCard.CreditCard):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized (cell, viewModel) combo.")
    }
  }
}
