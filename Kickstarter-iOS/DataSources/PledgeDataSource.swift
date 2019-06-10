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

  enum PledgeInputRow: Equatable {
    case pledgeAmount(amount: Double, currencySymbol: String)
    case shippingLocation(location: String, shippingCost: Double, project: Project)

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

  // MARK: - Load

  func load(data: PledgeTableViewData) {
    self.loadProjectSection(delivery: data.estimatedDelivery)

    self.loadInputsSection(
      amount: data.amount,
      currencySymbol: data.currencySymbol,
      shippingLocation: data.shippingLocation,
      shippingCost: data.shippingCost,
      project: data.project,
      requiresShippingRules: data.requiresShippingRules
    )

    self.loadSummarySection(isLoggedIn: data.isLoggedIn)
  }

  // MARK: - Update Shipping Location Cell

  func loadSelectedShippingRule(data: SelectedShippingRuleData) {
    guard let shippingCellIndex = shippingCellIndexPath(),
      self.numberOfItems(in: PledgeDataSource.Section.inputs.rawValue) > shippingCellIndex.row else {
      return
    }

    self.set(
      value: PledgeInputRow.shippingLocation(
        location: data.location,
        shippingCost: data.shippingCost,
        project: data.project
      ),
      cellClass: PledgeShippingLocationCell.self,
      inSection: Section.inputs.rawValue,
      row: shippingCellIndex.row
    )
  }

  // MARK: - Index

  func shippingCellIndexPath() -> IndexPath? {
    let inputsRowCount = self.numberOfItems(in: PledgeDataSource.Section.inputs.rawValue)
    let shippingIndexPath = IndexPath(
      item: inputsRowCount - 1,
      section: PledgeDataSource.Section.inputs.rawValue
    )

    guard self.indexPathIsShippingLocationCell(shippingIndexPath) else { return nil }

    return shippingIndexPath
  }

  // MARK: - Private

  private func loadProjectSection(delivery: String) {
    self.appendRow(
      value: delivery,
      cellClass: PledgeDescriptionCell.self,
      toSection: Section.project.rawValue
    )
  }

  private func loadInputsSection(
    amount: Double,
    currencySymbol: String,
    shippingLocation: String,
    shippingCost: Double,
    project: Project,
    requiresShippingRules: Bool
  ) {
    self.appendRow(
      value: PledgeInputRow.pledgeAmount(amount: amount, currencySymbol: currencySymbol),
      cellClass: PledgeAmountCell.self,
      toSection: Section.inputs.rawValue
    )

    if requiresShippingRules {
      self.appendRow(
        value: PledgeInputRow.shippingLocation(
          location: shippingLocation,
          shippingCost: shippingCost,
          project: project
        ),
        cellClass: PledgeShippingLocationCell.self,
        toSection: Section.inputs.rawValue
      )
    }
  }

  private func loadSummarySection(isLoggedIn: Bool) {
    self.appendRow(
      value: Strings.Total(),
      cellClass: PledgeRowCell.self,
      toSection: Section.summary.rawValue
    )

    if !isLoggedIn {
      self.appendRow(
        value: (),
        cellClass: PledgeContinueCell.self,
        toSection: Section.summary.rawValue
      )
    }
  }

  private func indexPathIsShippingLocationCell(_ indexPath: IndexPath) -> Bool {
    return (self[indexPath] as? PledgeInputRow)?.isShipping == true
  }

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as PledgeAmountCell, value as PledgeInputRow):
      cell.configureWith(value: value)
    case let (cell as PledgeContinueCell, value as ()):
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
