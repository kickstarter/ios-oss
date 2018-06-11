import UIKit
import KsApi
import Library

internal final class ThanksProjectsDataSource: ValueCellDataSource {
  internal func loadData(projects: [Project], category: KsApi.Category) {
    let values = projects.map { (project) -> DiscoveryProjectCellRowValue in
      return DiscoveryProjectCellRowValue(project: project, category: category)
    }

    self.set(values: values, cellClass: DiscoveryPostcardCell.self, inSection: 0)

    self.appendRow(
      value: category,
      cellClass: ThanksCategoryCell.self,
      toSection: 0
    )
  }

  override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as DiscoveryPostcardCell, value as DiscoveryProjectCellRowValue):
      cell.configureWith(value: value)
    case let (cell as ThanksCategoryCell, value as KsApi.Category):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized (cell, viewModel) combo.")
    }
  }

  internal func projectAtIndexPath(_ indexPath: IndexPath) -> Project? {
    let discoveryProjectCellRowValue = self[indexPath] as? DiscoveryProjectCellRowValue
    
    return discoveryProjectCellRowValue?.project
  }

  internal func categoryAtIndexPath(_ indexPath: IndexPath) -> KsApi.Category? {
    return self[indexPath] as? KsApi.Category
  }
}
