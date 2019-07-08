import Foundation
import KsApi
import Library
import UIKit

final class PledgeDataSource: ValueCellDataSource {
  enum Section: Int {
    case project
    case inputs
    case summary
    case paymentMethods
  }

  // MARK: - Load

  func load(data: PledgeViewData) {
    self.clearValues()

    self.appendRow(
      value: data.reward,
      cellClass: PledgeDescriptionCell.self,
      toSection: Section.project.rawValue
    )

    self.appendRow(
      value: (data.project, data.reward),
      cellClass: PledgeAmountCell.self,
      toSection: Section.inputs.rawValue
    )

    if data.shipping.isEnabled {
      self.appendRow(
        value: (data.shipping.isLoading, data.project, data.shipping.selectedRule),
        cellClass: PledgeShippingLocationCell.self,
        toSection: Section.inputs.rawValue
      )
    }

    self.appendRow(
      value: (data.project, data.pledgeTotal),
      cellClass: PledgeSummaryCell.self,
      toSection: Section.summary.rawValue
    )

    if !data.isLoggedIn {
      self.appendRow(
        value: (),
        cellClass: PledgeContinueCell.self,
        toSection: Section.summary.rawValue
      )
    } else {
      self.appendRow(
        value: [GraphUserCreditCard.template],
        cellClass: PledgePaymentMethodsCell.self,
        toSection: Section.paymentMethods.rawValue
      )
    }
  }

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as PledgeAmountCell, value as (Project, Reward)):
      cell.configureWith(value: value)
    case let (cell as PledgeContinueCell, value as ()):
      cell.configureWith(value: value)
    case let (cell as PledgeDescriptionCell, value as Reward):
      cell.configureWith(value: value)
    case let (cell as PledgeSummaryCell, value as PledgeSummaryCellData):
      cell.configureWith(value: value)
    case let (cell as PledgeShippingLocationCell, value as (Bool, Project, ShippingRule?)):
      cell.configureWith(value: value)
    case let (cell as PledgeContinueCell, value as ()):
      cell.configureWith(value: value)
    case let (cell as PledgePaymentMethodsCell, value as [GraphUserCreditCard]):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized (cell, viewModel) combo.")
    }
  }
}
