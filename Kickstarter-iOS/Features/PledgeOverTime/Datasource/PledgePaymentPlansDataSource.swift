import Library
import UIKit

internal final class PledgePaymentPlansDataSource: ValueCellDataSource {
  
  internal func load(_ data: PledgePaymentPlansAndSelectionData) {
    self.clearValues()
    
    let isPledgeInFullSelected = data.selectedPlan == PledgePaymentPlansType.PledgeinFull
    
    self.set(
      values: [isPledgeInFullSelected],
      cellClass: PledgePaymentPlanInFullCell.self,
      inSection: PledgePaymentPlansType.PledgeinFull.rawValue
    )
    
    self.set(
      values: [!isPledgeInFullSelected],
      cellClass: PledgePaymentPlanPlotCell.self,
      inSection: PledgePaymentPlansType.PledgeOverTime.rawValue
    )
  }
  
  internal override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as PledgePaymentPlanInFullCell, value as Bool):
      cell.configureWith(value: value)
    case let (cell as PledgePaymentPlanPlotCell, value as Bool):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized combo: \(cell), \(value).")
    }
  }
}
