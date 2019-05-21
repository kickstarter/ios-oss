import Foundation
import KsApi
import Library
import UIKit

final class PledgeDataSource: ValueCellDataSource {
  enum Section: Int {
    case project
    case inputs
    case summary
  }

  enum PledgeInputRow {
    case shippingLocation(location: String, amount: Double, currencyCode: String)
    case pledgeAmount(amount: Double, currency: String)

    var isShipping: Bool {
      switch self {
      case .shippingLocation: return true
      default: return false
      }
    }

    var isPledgeAmount: Bool {
      switch self {
      case .pledgeAmount: return true
      default: return false
      }
    }
  }

  func load(data: PledgeTableViewData) {
    self.loadProjectSection(delivery: data.delivery)

    self.loadInputsSection(amount: data.amount, currency: data.currency, currencyCode: data.currencyCode,
                           rate: 7.50, requiresShippingRules: data.requiresShippingRules)

    self.loadSummarySection(isLoggedIn: data.isLoggedIn)
  }

  func loadSelectedShippingRule(data: SelectedShippingRuleData) {
    self.set(value: PledgeInputRow.shippingLocation(location: data.location, amount: data.amount,
                                                    currencyCode: data.currencyCode),
             cellClass: PledgeShippingLocationCell.self,
             inSection: Section.inputs.rawValue,
             row: 1)
  }

  func shippingCellIndexPath() -> IndexPath? {
    let inputsRowCount = self.numberOfItems(in: PledgeDataSource.Section.inputs.rawValue)

    guard inputsRowCount > 0 else { return nil }

    let shippingIndexPath = IndexPath(item: inputsRowCount - 1,
                                      section: PledgeDataSource.Section.inputs.rawValue)

    guard self.indexPathIsShippingLocationCell(shippingIndexPath) else { return nil }

    return shippingIndexPath
  }

  private func loadProjectSection(delivery: String) {
    self.appendRow(
      value: delivery,
      cellClass: PledgeDescriptionCell.self,
      toSection: Section.project.rawValue
    )
  }

  private func loadInputsSection(amount: Double, currency: String, currencyCode: String, rate: Double,
                                 requiresShippingRules: Bool) {
    self.appendRow(
      value: PledgeInputRow.pledgeAmount(amount: amount, currency: currency),
      cellClass: PledgeAmountCell.self,
      toSection: Section.inputs.rawValue
    )

    if requiresShippingRules {
      self.appendRow(
        value: PledgeInputRow.shippingLocation(location: "", amount: 0.0, currencyCode: currencyCode),
        cellClass: PledgeShippingLocationCell.self,
        toSection: Section.inputs.rawValue
      )
    }
  }

  private func loadSummarySection(isLoggedIn: Bool) {
    self.appendRow(
      value: "Total",
      cellClass: PledgeRowCell.self,
      toSection: Section.summary.rawValue
    )

    if !isLoggedIn {
      self.appendRow(value: (),
                     cellClass: PledgeContinueCell.self,
                     toSection: Section.summary.rawValue)
    }
  }

  internal func indexPathIsShippingLocationCell(_ indexPath: IndexPath) -> Bool {
    return (self[indexPath] as? PledgeInputRow)?.isShipping == true
  }

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as PledgeAmountCell, value as PledgeInputRow):
      cell.configureWith(value: value)
    case let (cell as PledgeDescriptionCell, value as String):
      cell.configureWith(value: value)
    case let (cell as PledgeRowCell, value as String):
      cell.configureWith(value: value)
    case let (cell as PledgeShippingLocationCell, value as PledgeInputRow):
      cell.configureWith(value: value)
    case let (cell as PledgeContinueCell, value as ()):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized (cell, viewModel) combo.")
    }
  }
}
