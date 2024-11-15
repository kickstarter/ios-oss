import Library
import UIKit

internal final class PledgePaymentPlansDataSource: ValueCellDataSource {
  internal func load(_ data: PledgePaymentPlansAndSelectionData) {
    self.clearValues()

    let isPledgeInFullSelected = data.selectedPlan == PledgePaymentPlansType.pledgeinFull

    let pledgeInFullOption = PledgePaymentPlanCellData(
      type: PledgePaymentPlansType.pledgeinFull,
      isSelected: isPledgeInFullSelected
    )
    let pledgeOverTimeOption = PledgePaymentPlanCellData(
      type: PledgePaymentPlansType.pledgeOverTime,
      isSelected: !isPledgeInFullSelected
    )

    self.set(
      values: [pledgeInFullOption, pledgeOverTimeOption],
      cellClass: PledgePaymentPlanCell.self,
      inSection: 0
    )
  }

  internal override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as PledgePaymentPlanCell, value as PledgePaymentPlanCellData):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized combo: \(cell), \(value).")
    }
  }
}
