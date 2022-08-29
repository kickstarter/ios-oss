import KsApi
import Library
import Prelude
import UIKit

internal final class PledgePaymentMethodsDataSource: ValueCellDataSource {
  internal func load(
    _ cards: [PledgePaymentMethodCellData],
    paymentSheetCards: [PaymentSheetPaymentMethodCellData],
    isLoading: Bool = false
  ) {
    self.clearValues()

    guard isLoading == false else {
      return self.set(
        values: [()],
        cellClass: PledgePaymentMethodLoadingCell.self,
        inSection: PaymentMethodsTableViewSection.loading.rawValue
      )
    }

    let paymentSheetCardsAvailable = paymentSheetCards.count > 0

    switch paymentSheetCardsAvailable {
    case true:
      self.set(
        values: paymentSheetCards,
        cellClass: PledgePaymentSheetPaymentMethodCell.self,
        inSection: PaymentMethodsTableViewSection.paymentMethods.rawValue
      )

      cards.forEach { cardData in
        self
          .appendRow(
            value: cardData,
            cellClass: PledgePaymentMethodCell.self,
            toSection: PaymentMethodsTableViewSection.paymentMethods.rawValue
          )
      }
    case false:
      self.set(
        values: cards,
        cellClass: PledgePaymentMethodCell.self,
        inSection: PaymentMethodsTableViewSection.paymentMethods.rawValue
      )
    }

    self.set(
      values: [false],
      cellClass: PledgePaymentMethodAddCell.self,
      inSection: PaymentMethodsTableViewSection.addNewCard.rawValue
    )
  }

  func updateAddNewPaymentCardLoad(state: Bool) {
    self.set(
      values: [state],
      cellClass: PledgePaymentMethodAddCell.self,
      inSection: PaymentMethodsTableViewSection.addNewCard.rawValue
    )
  }

  func isLoadingStateCell(indexPath: IndexPath) -> Bool {
    guard let value = self[indexPath] as? Bool,
      value else {
      return false
    }

    return true
  }

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (
      cell as PledgePaymentMethodCell,
      value as PledgePaymentMethodCellData
    ):
      cell.configureWith(value: value)
    case let (
      cell as PledgePaymentSheetPaymentMethodCell,
      value as PaymentSheetPaymentMethodCellData
    ):
      cell.configureWith(value: value)
    case let (cell as PledgePaymentMethodAddCell, value as Bool):
      cell.configureWith(value: value)
    case let (cell as PledgePaymentMethodLoadingCell, value as Void):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized combo: \(cell), \(value)")
    }
  }
}
